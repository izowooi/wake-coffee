//
//  AlarmStatistics.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation

// 알람 기록
struct AlarmRecord: Identifiable, Codable {
    let id: UUID
    let alarmId: UUID
    let scheduledTime: Date
    var actualTime: Date?  // 실제로 확인한 시간 (nil이면 놓침)
    var isCompleted: Bool  // 완료 여부

    init(
        id: UUID = UUID(),
        alarmId: UUID,
        scheduledTime: Date,
        actualTime: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.alarmId = alarmId
        self.scheduledTime = scheduledTime
        self.actualTime = actualTime
        self.isCompleted = isCompleted
    }

    // 지연 시간 (분)
    var delayMinutes: Int? {
        guard let actualTime = actualTime else { return nil }
        return Calendar.current.dateComponents([.minute], from: scheduledTime, to: actualTime).minute
    }
}

// 통계 데이터
struct AlarmStatistics: Codable {
    var records: [AlarmRecord]

    init(records: [AlarmRecord] = []) {
        self.records = records
    }

    // 전체 준수율
    var completionRate: Double {
        guard !records.isEmpty else { return 0 }
        let completed = records.filter { $0.isCompleted }.count
        return Double(completed) / Double(records.count) * 100
    }

    // 최근 7일 준수율
    var weeklyCompletionRate: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentRecords = records.filter { $0.scheduledTime >= weekAgo }
        guard !recentRecords.isEmpty else { return 0 }
        let completed = recentRecords.filter { $0.isCompleted }.count
        return Double(completed) / Double(recentRecords.count) * 100
    }

    // 목적별 준수율 (나중에 구현)
    func completionRate(for purpose: AlarmPurpose) -> Double {
        // TODO: 알람 ID를 통해 목적별 통계 계산
        return 0
    }
}

// 샘플 데이터
extension AlarmStatistics {
    static let sample: AlarmStatistics = {
        let now = Date()
        let calendar = Calendar.current

        var sampleRecords: [AlarmRecord] = []

        // 최근 7일간의 샘플 데이터 생성
        for dayOffset in -6...0 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: now)!

            // 하루에 3개의 알람 기록
            for hour in [10, 14, 18] {
                let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)!
                let isCompleted = Bool.random()  // 랜덤으로 완료 여부 결정

                let record = AlarmRecord(
                    alarmId: UUID(),
                    scheduledTime: scheduledTime,
                    actualTime: isCompleted ? calendar.date(byAdding: .minute, value: Int.random(in: 0...15), to: scheduledTime) : nil,
                    isCompleted: isCompleted
                )
                sampleRecords.append(record)
            }
        }

        return AlarmStatistics(records: sampleRecords)
    }()
}
