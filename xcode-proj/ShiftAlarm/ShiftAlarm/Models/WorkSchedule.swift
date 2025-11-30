//
//  WorkSchedule.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import Foundation
import SwiftData

@Model
final class WorkSchedule {
    var date: Date
    var shiftType: ShiftType
    var isActive: Bool

    init(date: Date, shiftType: ShiftType, isActive: Bool = true) {
        self.date = date
        self.shiftType = shiftType
        self.isActive = isActive
    }

    // 계산 속성: 실제 알람 시간들
    var effectiveAlarmTimes: [Date] {
        guard isActive else { return [] }
        return shiftType.alarmTimes(for: date)
    }

    // 날짜의 시작 시간 (00:00:00)
    var dateStart: Date {
        Calendar.current.startOfDay(for: date)
    }
}
