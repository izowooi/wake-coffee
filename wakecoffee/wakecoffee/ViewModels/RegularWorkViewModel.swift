//
//  RegularWorkViewModel.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation
import Combine

@MainActor
class RegularWorkViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var workSchedule: RegularWorkSchedule
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared

    init() {
        // 저장된 데이터 로드
        self.workSchedule = dataManager.loadRegularWorkSchedule()
        self.alarms = dataManager.loadRegularAlarms()

        // 샘플 데이터가 없으면 추가
        if alarms.isEmpty {
            alarms = Alarm.sampleAlarms
            saveAlarms()
        }
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

    func updateWorkSchedule(_ schedule: RegularWorkSchedule) {
        self.workSchedule = schedule
        dataManager.saveRegularWorkSchedule(schedule)
        scheduleNotifications()
    }

    // MARK: - Data Persistence

    private func saveAlarms() {
        dataManager.saveRegularAlarms(alarms)
    }

    // MARK: - Notifications

    private func scheduleNotifications() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                // 모든 알람에 대해 알림 스케줄링
                for alarm in alarms {
                    try await notificationManager.scheduleAlarm(alarm)
                }
            } catch {
                errorMessage = "알림 설정 중 오류가 발생했습니다: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    func requestNotificationPermission() async -> Bool {
        return await notificationManager.requestAuthorization()
    }

    // MARK: - Alarm Sorting

    func sortedAlarms() -> [Alarm] {
        return alarms.sorted { $0.time < $1.time }
    }

    func alarmsByPeriod(_ period: WorkPeriod) -> [Alarm] {
        return alarms.filter { $0.workPeriod == period }.sorted { $0.time < $1.time }
    }

    // MARK: - Statistics

    func recordAlarmCompletion(alarmId: UUID, completedAt: Date) {
        let record = AlarmRecord(
            alarmId: alarmId,
            scheduledTime: Date(), // 실제로는 스케줄된 시간을 사용해야 함
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
