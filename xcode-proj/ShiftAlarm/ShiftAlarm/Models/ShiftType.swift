//
//  ShiftType.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import Foundation
import SwiftUI

enum ShiftType: String, Codable, CaseIterable {
    case dayShift = "주간"
    case nightShift = "야간"
    case off = "휴무"

    var displayName: String {
        return self.rawValue
    }

    var color: Color {
        switch self {
        case .dayShift:
            return .yellow
        case .nightShift:
            return .purple
        case .off:
            return .red
        }
    }

    var icon: String {
        switch self {
        case .dayShift:
            return "sun.max.fill"
        case .nightShift:
            return "moon.stars.fill"
        case .off:
            return "bed.double.fill"
        }
    }

    // 각 근무 유형의 알람 시간 (시간 단위)
    var alarmHours: [Int] {
        switch self {
        case .dayShift:
            return [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
        case .nightShift:
            return [20, 21, 22]
        case .off:
            return []
        }
    }

    // 특정 날짜에 대한 알람 시간들을 Date 배열로 반환
    func alarmTimes(for date: Date) -> [Date] {
        let calendar = Calendar.current
        return alarmHours.compactMap { hour in
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)
        }
    }
}
