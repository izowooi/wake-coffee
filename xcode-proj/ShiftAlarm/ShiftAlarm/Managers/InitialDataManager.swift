//
//  InitialDataManager.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import Foundation
import SwiftData

@MainActor
class InitialDataManager {

    /// 앱 첫 실행 시 12월 근무표 자동 생성
    static func setupInitialScheduleIfNeeded(modelContext: ModelContext) async {
        // 이미 데이터가 있는지 확인
        let descriptor = FetchDescriptor<WorkSchedule>()
        let existingSchedules = (try? modelContext.fetch(descriptor)) ?? []

        if !existingSchedules.isEmpty {
            print("📅 기존 스케줄이 있습니다. 초기 데이터 생성을 건너뜁니다.")
            return
        }

        print("📅 12월 근무표를 자동으로 생성합니다...")

        // 2025년 12월 기준
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2025
        components.month = 12

        // PRD.txt의 근무표에 따라 스케줄 생성
        let scheduleData: [(day: Int, shiftType: ShiftType, isActive: Bool)] = [
            // 주간 근무 (1, 6, 7, 12, 13, 18, 19, 24, 25, 30, 31)
            (1, .dayShift, false),   // 연차
            (6, .dayShift, true),
            (7, .dayShift, true),
            (12, .dayShift, true),
            (13, .dayShift, true),
            (17, .dayShift, true),   // 대체 근무
            (18, .dayShift, true),
            (19, .dayShift, false),  // 연차
            (24, .dayShift, true),
            (25, .dayShift, true),
            (30, .dayShift, true),
            (31, .dayShift, true),

            // 야간 근무 (2, 3, 8, 9, 14, 15, 20, 21, 26, 27)
            (2, .nightShift, true),
            (3, .nightShift, true),
            (8, .nightShift, true),
            (9, .nightShift, true),
            (14, .nightShift, true),
            (15, .nightShift, true),
            (20, .nightShift, true),
            (21, .nightShift, true),
            (26, .nightShift, true),
            (27, .nightShift, false), // 연차

            // 휴무 (4, 5, 10, 11, 16, 22, 23, 28, 29)
            (4, .off, true),
            (5, .off, true),
            (10, .off, true),
            (11, .off, true),
            (16, .off, true),
            (22, .off, true),
            (23, .off, true),
            (28, .off, true),
            (29, .off, true)
        ]

        // 스케줄 생성
        for data in scheduleData {
            components.day = data.day
            if let date = calendar.date(from: components) {
                let schedule = WorkSchedule(
                    date: calendar.startOfDay(for: date),
                    shiftType: data.shiftType,
                    isActive: data.isActive
                )
                modelContext.insert(schedule)
            }
        }

        // 저장
        do {
            try modelContext.save()
            print("✅ 12월 근무표가 성공적으로 생성되었습니다.")

            // 알람 스케줄링
            let allSchedules = (try? modelContext.fetch(descriptor)) ?? []
            await NotificationManager.shared.scheduleAllNotifications(for: allSchedules)
            print("✅ 알람이 성공적으로 등록되었습니다.")
        } catch {
            print("❌ 스케줄 저장 실패: \(error)")
        }
    }
}
