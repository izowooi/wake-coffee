//
//  NotificationManager.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import Foundation
import Combine
import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Scheduling Notifications

    /// 모든 스케줄에 대해 알람 재설정
    func scheduleAllNotifications(for schedules: [WorkSchedule]) async {
        // 기존 알람 모두 제거
        notificationCenter.removeAllPendingNotificationRequests()

        // 현재 날짜
        let now = Date()
        let calendar = Calendar.current

        // 현재 월과 다음 월의 스케줄만 필터링 (64개 제한 고려)
        let twoMonthsLater = calendar.date(byAdding: .month, value: 2, to: now) ?? now

        let filteredSchedules = schedules.filter { schedule in
            schedule.date >= now && schedule.date <= twoMonthsLater
        }

        // 각 스케줄에 대해 알람 등록
        for schedule in filteredSchedules {
            await scheduleNotifications(for: schedule)
        }

        // 등록된 알람 개수 확인 (디버깅용)
        let pendingNotifications = await notificationCenter.pendingNotificationRequests()
        print("✅ Total scheduled notifications: \(pendingNotifications.count)")
    }

    /// 특정 스케줄에 대한 알람 설정
    func scheduleNotifications(for schedule: WorkSchedule) async {
        guard schedule.isActive else {
            // 비활성화된 스케줄은 알람 취소
            await cancelNotifications(for: schedule)
            return
        }

        let alarmTimes = schedule.effectiveAlarmTimes

        for alarmTime in alarmTimes {
            await scheduleNotification(for: schedule, at: alarmTime)
        }
    }

    /// 개별 알람 설정
    private func scheduleNotification(for schedule: WorkSchedule, at alarmTime: Date) async {
        // 과거 시간은 알람 등록 안 함
        let now = Date()
        if alarmTime <= now {
            print("⏭️ Skipped (past time): \(alarmTime)")
            return
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmTime)

        // 알람 ID: "shift_YYYYMMDD_HHMM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let identifier = "shift_" + dateFormatter.string(from: alarmTime)

        // 알람 내용
        let content = UNMutableNotificationContent()
        content.title = "ShiftAlarm"

        let hour = components.hour ?? 0
        switch schedule.shiftType {
        case .dayShift:
            content.body = "근무 시간입니다 (\(String(format: "%02d:00", hour)))"
        case .nightShift:
            content.body = "야간 근무 알림 (\(String(format: "%02d:00", hour)))"
        case .off:
            return // 휴무는 알람 없음
        }

        content.sound = .default
        content.badge = 1

        // Time Sensitive 설정 (iOS 15+)
        // Focus 모드 우회 및 화면 즉시 점등
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        // 트리거 설정 (매일 반복하지 않고 특정 날짜/시간에만)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // 요청 생성
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled: \(identifier) - \(schedule.shiftType.displayName) at \(alarmTime)")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }

    // MARK: - Canceling Notifications

    /// 특정 스케줄의 모든 알람 취소
    func cancelNotifications(for schedule: WorkSchedule) async {
        let calendar = Calendar.current
        let alarmTimes = schedule.shiftType.alarmTimes(for: schedule.date)

        let identifiers = alarmTimes.map { alarmTime -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmm"
            return "shift_" + dateFormatter.string(from: alarmTime)
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Canceled notifications for: \(schedule.date)")
    }

    /// 특정 날짜의 모든 알람 취소
    func cancelNotifications(for date: Date) async {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        let dateEnd = calendar.date(byAdding: .day, value: 1, to: dateStart) ?? dateStart

        let pendingNotifications = await notificationCenter.pendingNotificationRequests()

        let identifiersToRemove = pendingNotifications.compactMap { request -> String? in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let triggerDate = trigger.nextTriggerDate() else {
                return nil
            }

            if triggerDate >= dateStart && triggerDate < dateEnd {
                return request.identifier
            }
            return nil
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }

    // MARK: - Utility

    /// 등록된 알람 목록 가져오기 (디버깅용)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
