//
//  ShiftWorkViewModel.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation
import Combine

@MainActor
class ShiftWorkViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var schedule: ShiftWorkSchedule
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared

    init() {
        // 저장된 데이터 로드
        self.schedule = dataManager.loadShiftWorkSchedule()
        self.alarms = dataManager.loadShiftAlarms()
    }

    // MARK: - Alarm Management

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        saveAlarms()
        scheduleNotifications()
    }

    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            saveAlarms()
            scheduleNotifications()
        }
    }

    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            scheduleNotifications()
        }
    }

    func deleteAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()

        Task {
            await notificationManager.removeAlarm(alarm)
        }
    }

    func deleteAllAlarms() {
        alarms.removeAll()
        saveAlarms()

        Task {
            await notificationManager.removeAllAlarms()
        }
    }

    // MARK: - Schedule Management

    func updateSchedule(_ newSchedule: ShiftWorkSchedule) {
        self.schedule = newSchedule
        dataManager.saveShiftWorkSchedule(newSchedule)
        scheduleNotifications()
    }

    // MARK: - Data Persistence

    private func saveAlarms() {
        dataManager.saveShiftAlarms(alarms)
    }

    // MARK: - Notifications

    private func scheduleNotifications() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                // 교대근무 알람 스케줄링
                try await notificationManager.scheduleShiftAlarms(alarms, schedule: schedule)
            } catch {
                errorMessage = "알림 설정 중 오류가 발생했습니다: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    func requestNotificationPermission() async -> Bool {
        return await notificationManager.requestAuthorization()
    }

    // MARK: - Schedule Preview

    func getScheduleForDays(_ days: Int) -> [(date: Date, shiftTime: ShiftTime)] {
        var result: [(Date, ShiftTime)] = []
        let calendar = Calendar.current

        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                let shiftTime = schedule.getShiftTime(for: date)
                result.append((date, shiftTime))
            }
        }

        return result
    }

    func isWorkDay(date: Date) -> Bool {
        return schedule.getShiftTime(for: date) != .off
    }

    // MARK: - Alarm Calculation

    /// 근무 시간 기준으로 알람 시간 계산
    func calculateAlarmTimes(
        intervalHours: Int,
        offsetMinutes: Int,
        shiftTime: ShiftTime
    ) -> [Date] {
        let calendar = Calendar.current
        let startTime = getShiftStartTime(for: shiftTime)
        let endTime = getShiftEndTime(for: shiftTime)

        guard let startComponents = calendar.dateComponents([.hour, .minute], from: startTime) as DateComponents?,
              let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endComponents = calendar.dateComponents([.hour, .minute], from: endTime) as DateComponents?,
              let endHour = endComponents.hour else {
            return []
        }

        var times: [Date] = []
        var currentMinutes = startHour * 60 + startMinute + offsetMinutes
        let endMinutes = endHour * 60

        while currentMinutes < endMinutes {
            let hour = currentMinutes / 60
            let minute = currentMinutes % 60

            if let time = calendar.date(from: DateComponents(hour: hour, minute: minute)) {
                times.append(time)
            }

            currentMinutes += intervalHours * 60
        }

        return times
    }

    private func getShiftStartTime(for shiftTime: ShiftTime) -> Date {
        return schedule.getShiftStartTime(for: shiftTime)
    }

    private func getShiftEndTime(for shiftTime: ShiftTime) -> Date {
        return schedule.getShiftEndTime(for: shiftTime)
    }

    // MARK: - Statistics

    func recordAlarmCompletion(alarmId: UUID, completedAt: Date) {
        let record = AlarmRecord(
            alarmId: alarmId,
            scheduledTime: Date(),
            actualTime: completedAt,
            isCompleted: true
        )
        dataManager.addAlarmRecord(record)
    }

    func recordAlarmMissed(alarmId: UUID, scheduledTime: Date) {
        let record = AlarmRecord(
            alarmId: alarmId,
            scheduledTime: scheduledTime,
            actualTime: nil,
            isCompleted: false
        )
        dataManager.addAlarmRecord(record)
    }
}
