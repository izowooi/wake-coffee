//
//  StatisticsViewModel.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var statistics: AlarmStatistics

    private let dataManager = DataManager.shared

    init() {
        // 저장된 통계 로드
        self.statistics = dataManager.loadStatistics()

        // 샘플 데이터가 없으면 추가
        if statistics.records.isEmpty {
            statistics = AlarmStatistics.sample
            saveStatistics()
        }
    }

    // MARK: - Statistics Calculation

    /// 전체 준수율
    var overallCompletionRate: Double {
        return statistics.completionRate
    }

    /// 주간 준수율
    var weeklyCompletionRate: Double {
        return statistics.weeklyCompletionRate
    }

    /// 총 알람 수
    var totalAlarmsCount: Int {
        return statistics.records.count
    }

    /// 완료된 알람 수
    var completedAlarmsCount: Int {
        return statistics.records.filter { $0.isCompleted }.count
    }

    /// 특정 기간의 준수율
    func completionRate(from startDate: Date, to endDate: Date) -> Double {
        let records = statistics.records.filter {
            $0.scheduledTime >= startDate && $0.scheduledTime <= endDate
        }

        guard !records.isEmpty else { return 0 }

        let completed = records.filter { $0.isCompleted }.count
        return Double(completed) / Double(records.count) * 100
    }

    /// 최근 N일 데이터
    func dailyCompletionData(days: Int) -> [DailyCompletionData] {
        let calendar = Calendar.current
        let today = Date()

        return (-days+1...0).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let dayRecords = statistics.records.filter {
                calendar.isDate($0.scheduledTime, inSameDayAs: date)
            }

            let completed = dayRecords.filter { $0.isCompleted }.count
            let total = dayRecords.count
            let rate = total > 0 ? Double(completed) / Double(total) * 100 : 0

            return DailyCompletionData(
                date: date,
                rate: rate,
                completed: completed,
                total: total
            )
        }
    }

    /// 목적별 통계
    func completionRateByPurpose() -> [PurposeStatData] {
        var purposeData: [AlarmPurpose: (completed: Int, total: Int)] = [:]

        // 각 알람 목적별로 집계
        for purpose in AlarmPurpose.allCases {
            purposeData[purpose] = (completed: 0, total: 0)
        }

        // 실제 계산은 알람 ID를 통해 목적을 알아야 하므로
        // 지금은 샘플 데이터 반환
        return [
            PurposeStatData(purpose: .water, rate: 85.0, completed: 17, total: 20),
            PurposeStatData(purpose: .stretch, rate: 72.0, completed: 18, total: 25),
            PurposeStatData(purpose: .medicine, rate: 95.0, completed: 19, total: 20),
            PurposeStatData(purpose: .coffee, rate: 68.0, completed: 15, total: 22)
        ]
    }

    /// 최근 기록
    func recentRecords(limit: Int = 10) -> [AlarmRecord] {
        return Array(statistics.records
            .sorted { $0.scheduledTime > $1.scheduledTime }
            .prefix(limit))
    }

    /// 평균 지연 시간
    func averageDelayMinutes() -> Int {
        let completedRecords = statistics.records.filter {
            $0.isCompleted && $0.delayMinutes != nil
        }

        guard !completedRecords.isEmpty else { return 0 }

        let totalDelay = completedRecords.compactMap { $0.delayMinutes }.reduce(0, +)
        return totalDelay / completedRecords.count
    }

    /// 가장 잘 지킨 시간대
    func bestTimeOfDay() -> String {
        let calendar = Calendar.current
        var hourStats: [Int: (completed: Int, total: Int)] = [:]

        for record in statistics.records {
            let hour = calendar.component(.hour, from: record.scheduledTime)
            if hourStats[hour] == nil {
                hourStats[hour] = (completed: 0, total: 0)
            }
            hourStats[hour]!.total += 1
            if record.isCompleted {
                hourStats[hour]!.completed += 1
            }
        }

        let bestHour = hourStats.max { a, b in
            let rateA = Double(a.value.completed) / Double(a.value.total)
            let rateB = Double(b.value.completed) / Double(b.value.total)
            return rateA < rateB
        }

        if let hour = bestHour?.key {
            return String(format: "%02d:00", hour)
        }

        return "데이터 없음"
    }

    // MARK: - Data Management

    func addRecord(_ record: AlarmRecord) {
        statistics.records.append(record)
        saveStatistics()
    }

    func deleteAllRecords() {
        statistics.records.removeAll()
        saveStatistics()
    }

    private func saveStatistics() {
        dataManager.saveStatistics(statistics)
    }

    func refreshStatistics() {
        statistics = dataManager.loadStatistics()
    }
}

// MARK: - Data Models

struct DailyCompletionData: Identifiable {
    let id = UUID()
    let date: Date
    let rate: Double
    let completed: Int
    let total: Int
}

struct PurposeStatData: Identifiable {
    let id = UUID()
    let purpose: AlarmPurpose
    let rate: Double
    let completed: Int
    let total: Int
}
