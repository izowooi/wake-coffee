//
//  NotificationManager.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Schedule Alarms

    /// 일반 알람 스케줄링
    func scheduleAlarm(_ alarm: Alarm) async throws {
        guard alarm.isEnabled else { return }

        // 기존 알람 제거
        await removeAlarm(alarm)

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: alarm.time)
        let minute = calendar.component(.minute, from: alarm.time)

        // 각 반복 요일에 대해 알림 생성
        for weekday in alarm.repeatDays {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = weekday

            let content = UNMutableNotificationContent()
            content.title = "Wake Coffee"
            content.body = "\(alarm.purpose.icon) \(alarm.purpose.rawValue)"
            content.sound = .default
            content.categoryIdentifier = "ALARM_CATEGORY"
            content.userInfo = ["alarmId": alarm.id.uuidString]

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)-\(weekday)",
                content: content,
                trigger: trigger
            )

            try await UNUserNotificationCenter.current().add(request)
        }
    }

    /// 교대근무 알람 스케줄링
    func scheduleShiftAlarms(_ alarms: [Alarm], schedule: ShiftWorkSchedule) async throws {
        // 교대근무는 다음 30일간의 알람을 생성
        let calendar = Calendar.current
        let today = Date()

        for alarm in alarms where alarm.isEnabled {
            await removeAlarm(alarm)

            for dayOffset in 0..<30 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                    continue
                }

                let shiftTime = schedule.getShiftTime(for: date)

                // 휴무일이면 건너뛰기
                if shiftTime == .off {
                    continue
                }

                // 근무 시작 시간 가져오기 (향후 간격 계산에 사용 가능)
                _ = getShiftStartTime(for: shiftTime, schedule: schedule)
                let alarmHour = calendar.component(.hour, from: alarm.time)
                let alarmMinute = calendar.component(.minute, from: alarm.time)

                // 알람 시간 계산
                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = alarmHour
                components.minute = alarmMinute

                guard let alarmDate = calendar.date(from: components) else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = "Wake Coffee"
                content.body = "\(alarm.purpose.icon) \(alarm.purpose.rawValue)"
                content.sound = .default
                content.categoryIdentifier = "ALARM_CATEGORY"
                content.userInfo = ["alarmId": alarm.id.uuidString]

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate),
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-\(dayOffset)",
                    content: content,
                    trigger: trigger
                )

                try await UNUserNotificationCenter.current().add(request)
            }
        }
    }

    private func getShiftStartTime(for shiftTime: ShiftTime, schedule: ShiftWorkSchedule) -> Date {
        switch shiftTime {
        case .day:
            return schedule.dayShiftStart
        case .night:
            return schedule.nightShiftStart
        case .evening:
            return Calendar.current.date(from: DateComponents(hour: 15, minute: 0))!
        case .off:
            return Date()
        }
    }

    // MARK: - Remove Alarms

    func removeAlarm(_ alarm: Alarm) async {
        let identifiers = (1...7).map { "\(alarm.id.uuidString)-\($0)" } +
                          (0..<30).map { "\(alarm.id.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeAllAlarms() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Get Pending Alarms

    func getPendingAlarms() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - Test Notification (for debugging)

    func scheduleTestNotification(after seconds: TimeInterval = 5) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Wake Coffee 테스트"
        content.body = "알림이 정상적으로 작동합니다!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Notification Categories

extension NotificationManager {
    func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "완료",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "5분 후 다시 알림",
            options: []
        )

        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
}
