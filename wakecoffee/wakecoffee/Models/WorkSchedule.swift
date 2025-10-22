//
//  WorkSchedule.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation

// 교대 근무 유형
enum ShiftType: String, CaseIterable, Codable {
    case twoShift = "2교대"
    case threeShift = "3교대"
    case fourShift = "4교대"
    case custom = "커스텀"

    // 각 교대의 기본 사이클 (일 단위)
    var cycleDays: Int {
        switch self {
        case .twoShift: return 4  // 2일 주간, 2일 휴무
        case .threeShift: return 6  // 2일 주간, 2일 야간, 2일 휴무
        case .fourShift: return 8  // 2일 주간, 2일 야간, 2일 저녁, 2일 휴무
        case .custom: return 0
        }
    }
}

// 근무 시간대
enum ShiftTime: String, Codable {
    case day = "주간"
    case night = "야간"
    case evening = "저녁"
    case off = "휴무"

    var icon: String {
        switch self {
        case .day: return "🌞"
        case .night: return "🌙"
        case .evening: return "🌆"
        case .off: return "⚪"
        }
    }

    var startHour: Int {
        switch self {
        case .day: return 9
        case .night: return 21
        case .evening: return 15
        case .off: return 0
        }
    }

    var endHour: Int {
        switch self {
        case .day: return 21
        case .night: return 9
        case .evening: return 23
        case .off: return 0
        }
    }
}

// 일반 근무 스케줄 (9 to 6 직장인)
struct RegularWorkSchedule: Codable, Equatable {
    var startTime: Date  // 출근 시간
    var endTime: Date    // 퇴근 시간

    init(
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        endTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!
    ) {
        self.startTime = startTime
        self.endTime = endTime
    }

    // 시간만 추출
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }
}

// 교대 근무 스케줄
struct ShiftWorkSchedule: Codable, Equatable {
    var shiftType: ShiftType
    var startDate: Date  // 패턴 시작일
    var dayShiftStart: Date
    var dayShiftEnd: Date
    var nightShiftStart: Date
    var nightShiftEnd: Date

    init(
        shiftType: ShiftType = .twoShift,
        startDate: Date = Date(),
        dayShiftStart: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        dayShiftEnd: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!,
        nightShiftStart: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!,
        nightShiftEnd: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
    ) {
        self.shiftType = shiftType
        self.startDate = startDate
        self.dayShiftStart = dayShiftStart
        self.dayShiftEnd = dayShiftEnd
        self.nightShiftStart = nightShiftStart
        self.nightShiftEnd = nightShiftEnd
    }

    // 특정 날짜의 근무 시간대 계산 (샘플 로직)
    func getShiftTime(for date: Date) -> ShiftTime {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        let cyclePosition = daysSinceStart % shiftType.cycleDays

        switch shiftType {
        case .twoShift:
            // 2일 주간, 2일 휴무
            if cyclePosition < 2 { return .day }
            else { return .off }

        case .threeShift:
            // 2일 주간, 2일 야간, 2일 휴무
            if cyclePosition < 2 { return .day }
            else if cyclePosition < 4 { return .night }
            else { return .off }

        case .fourShift:
            // 2일 주간, 2일 야간, 2일 저녁, 2일 휴무
            if cyclePosition < 2 { return .day }
            else if cyclePosition < 4 { return .night }
            else if cyclePosition < 6 { return .evening }
            else { return .off }

        case .custom:
            return .off
        }
    }
}

// 샘플 데이터
extension ShiftWorkSchedule {
    static let sample = ShiftWorkSchedule(
        shiftType: .twoShift,
        startDate: Date()
    )
}
