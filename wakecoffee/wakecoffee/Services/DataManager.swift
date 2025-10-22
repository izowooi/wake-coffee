//
//  DataManager.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation

class DataManager {
    static let shared = DataManager()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let regularAlarms = "regular_alarms"
        static let shiftAlarms = "shift_alarms"
        static let regularWorkSchedule = "regular_work_schedule"
        static let shiftWorkSchedule = "shift_work_schedule"
        static let statistics = "statistics"
        static let settings = "settings"
    }

    private init() {}

    // MARK: - Alarms

    func saveRegularAlarms(_ alarms: [Alarm]) {
        if let encoded = try? JSONEncoder().encode(alarms) {
            defaults.set(encoded, forKey: Keys.regularAlarms)
        }
    }

    func loadRegularAlarms() -> [Alarm] {
        guard let data = defaults.data(forKey: Keys.regularAlarms),
              let alarms = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return []
        }
        return alarms
    }

    func saveShiftAlarms(_ alarms: [Alarm]) {
        if let encoded = try? JSONEncoder().encode(alarms) {
            defaults.set(encoded, forKey: Keys.shiftAlarms)
        }
    }

    func loadShiftAlarms() -> [Alarm] {
        guard let data = defaults.data(forKey: Keys.shiftAlarms),
              let alarms = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return []
        }
        return alarms
    }

    func deleteAllAlarms() {
        defaults.removeObject(forKey: Keys.regularAlarms)
        defaults.removeObject(forKey: Keys.shiftAlarms)
    }

    // MARK: - Work Schedules

    func saveRegularWorkSchedule(_ schedule: RegularWorkSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.regularWorkSchedule)
        }
    }

    func loadRegularWorkSchedule() -> RegularWorkSchedule {
        guard let data = defaults.data(forKey: Keys.regularWorkSchedule),
              let schedule = try? JSONDecoder().decode(RegularWorkSchedule.self, from: data) else {
            return RegularWorkSchedule()
        }
        return schedule
    }

    func saveShiftWorkSchedule(_ schedule: ShiftWorkSchedule) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            defaults.set(encoded, forKey: Keys.shiftWorkSchedule)
        }
    }

    func loadShiftWorkSchedule() -> ShiftWorkSchedule {
        guard let data = defaults.data(forKey: Keys.shiftWorkSchedule),
              let schedule = try? JSONDecoder().decode(ShiftWorkSchedule.self, from: data) else {
            return ShiftWorkSchedule()
        }
        return schedule
    }

    // MARK: - Statistics

    func saveStatistics(_ statistics: AlarmStatistics) {
        if let encoded = try? JSONEncoder().encode(statistics) {
            defaults.set(encoded, forKey: Keys.statistics)
        }
    }

    func loadStatistics() -> AlarmStatistics {
        guard let data = defaults.data(forKey: Keys.statistics),
              let statistics = try? JSONDecoder().decode(AlarmStatistics.self, from: data) else {
            return AlarmStatistics()
        }
        return statistics
    }

    func addAlarmRecord(_ record: AlarmRecord) {
        var statistics = loadStatistics()
        statistics.records.append(record)
        saveStatistics(statistics)
    }

    func deleteAllStatistics() {
        defaults.removeObject(forKey: Keys.statistics)
    }

    // MARK: - Settings

    struct AppSettings: Codable {
        var notificationsEnabled: Bool = true
        var soundEnabled: Bool = true
        var vibrationEnabled: Bool = true
        var defaultStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
        var defaultEndTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!
    }

    func saveSettings(_ settings: AppSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: Keys.settings)
        }
    }

    func loadSettings() -> AppSettings {
        guard let data = defaults.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    // MARK: - Clear All Data

    func clearAllData() {
        defaults.removeObject(forKey: Keys.regularAlarms)
        defaults.removeObject(forKey: Keys.shiftAlarms)
        defaults.removeObject(forKey: Keys.regularWorkSchedule)
        defaults.removeObject(forKey: Keys.shiftWorkSchedule)
        defaults.removeObject(forKey: Keys.statistics)
        defaults.removeObject(forKey: Keys.settings)
    }
}
