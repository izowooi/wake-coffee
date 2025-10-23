//
//  WorkSchedule.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation

// 교대 근무 패턴 정의
struct ShiftPattern: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let description: String
    let cycle: [ShiftTime]  // 반복되는 근무 패턴 (예: [.day, .day, .night, .night, .off, .off])

    var cycleDays: Int {
        return cycle.count
    }

    // 특정 날짜의 근무 시간대 계산
    func getShiftTime(daysSinceStart: Int) -> ShiftTime {
        guard cycleDays > 0 else { return .off }
        let position = daysSinceStart % cycleDays
        return cycle[position]
    }

    // 패턴의 간략한 표시 (예: "주2야2휴2")
    var shortPattern: String {
        var result = ""
        var currentType: ShiftTime?
        var count = 0

        for shift in cycle {
            if shift == currentType {
                count += 1
            } else {
                if let type = currentType {
                    result += "\(type.shortName)\(count)"
                }
                currentType = shift
                count = 1
            }
        }

        if let type = currentType {
            result += "\(type.shortName)\(count)"
        }

        return result
    }
}

// 미리 정의된 교대 근무 패턴들
extension ShiftPattern {
    static let presets: [ShiftPattern] = [
        // 5조2교대
        ShiftPattern(
            id: "5_2_shift_1",
            name: "5조2교대",
            description: "주2,휴3,야2,휴3",
            cycle: [.day, .day, .off, .off, .off, .night, .night, .off, .off, .off]
        ),

        // 4조2교대 변형들
        ShiftPattern(
            id: "4_2_shift_1",
            name: "4조2교대",
            description: "주2,야2,휴4",
            cycle: [.day, .day, .night, .night, .off, .off, .off, .off]
        ),
        ShiftPattern(
            id: "4_2_shift_2",
            name: "4조2교대",
            description: "주2,휴2,야2,휴2",
            cycle: [.day, .day, .off, .off, .night, .night, .off, .off]
        ),
        ShiftPattern(
            id: "4_2_shift_3",
            name: "4조2교대",
            description: "주3,휴3,야3,휴3",
            cycle: [.day, .day, .day, .off, .off, .off, .night, .night, .night, .off, .off, .off]
        ),

        // 3조2교대 변형들
        ShiftPattern(
            id: "3_2_shift_1",
            name: "3조2교대",
            description: "주4,휴2,야4,휴2",
            cycle: [.day, .day, .day, .day, .off, .off, .night, .night, .night, .night, .off, .off]
        ),
        ShiftPattern(
            id: "3_2_shift_2",
            name: "3조2교대",
            description: "주야휴",
            cycle: [.day, .night, .off]
        ),
        ShiftPattern(
            id: "3_2_shift_3",
            name: "3조2교대",
            description: "주2,야2,휴2",
            cycle: [.day, .day, .night, .night, .off, .off]
        ),
        ShiftPattern(
            id: "3_2_shift_4",
            name: "3조2교대",
            description: "주3,야1,휴1,야1,휴1",
            cycle: [.day, .day, .day, .night, .off, .night, .off]
        ),
        ShiftPattern(
            id: "3_2_shift_5",
            name: "3조2교대",
            description: "주2,휴1,야2,휴1",
            cycle: [.day, .day, .off, .night, .night, .off]
        ),
    ]

    static let `default` = presets[2] // 4조2교대 (주2,야2,휴4)를 기본값으로
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

    var shortName: String {
        switch self {
        case .day: return "주"
        case .night: return "야"
        case .evening: return "석"
        case .off: return "휴"
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
    var pattern: ShiftPattern
    var startDate: Date  // 패턴 시작일
    var dayShiftStart: Date
    var dayShiftEnd: Date
    var nightShiftStart: Date
    var nightShiftEnd: Date
    var eveningShiftStart: Date
    var eveningShiftEnd: Date

    init(
        pattern: ShiftPattern = ShiftPattern.default,
        startDate: Date = Date(),
        dayShiftStart: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        dayShiftEnd: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!,
        nightShiftStart: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!,
        nightShiftEnd: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        eveningShiftStart: Date = Calendar.current.date(from: DateComponents(hour: 15, minute: 0))!,
        eveningShiftEnd: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0))!
    ) {
        self.pattern = pattern
        self.startDate = startDate
        self.dayShiftStart = dayShiftStart
        self.dayShiftEnd = dayShiftEnd
        self.nightShiftStart = nightShiftStart
        self.nightShiftEnd = nightShiftEnd
        self.eveningShiftStart = eveningShiftStart
        self.eveningShiftEnd = eveningShiftEnd
    }

    // 특정 날짜의 근무 시간대 계산
    func getShiftTime(for date: Date) -> ShiftTime {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        return pattern.getShiftTime(daysSinceStart: daysSinceStart)
    }

    // 근무 시간대별 시작/종료 시간 가져오기
    func getShiftStartTime(for shiftTime: ShiftTime) -> Date {
        switch shiftTime {
        case .day: return dayShiftStart
        case .night: return nightShiftStart
        case .evening: return eveningShiftStart
        case .off: return Date()
        }
    }

    func getShiftEndTime(for shiftTime: ShiftTime) -> Date {
        switch shiftTime {
        case .day: return dayShiftEnd
        case .night: return nightShiftEnd
        case .evening: return eveningShiftEnd
        case .off: return Date()
        }
    }
}

// 샘플 데이터
extension ShiftWorkSchedule {
    static let sample = ShiftWorkSchedule(
        pattern: ShiftPattern.default,
        startDate: Date()
    )
}
