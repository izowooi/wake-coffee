//
//  Alarm.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import Foundation

// 알람 목적 타입
enum AlarmPurpose: String, CaseIterable, Codable {
    case water = "물 마시기"
    case stretch = "스트레칭"
    case medicine = "영양제"
    case coffee = "커피 브레이크"
    case eyeRest = "눈 운동"
    case walk = "산책"

    var icon: String {
        switch self {
        case .water: return "💧"
        case .stretch: return "🤸"
        case .medicine: return "💊"
        case .coffee: return "☕"
        case .eyeRest: return "👁️"
        case .walk: return "🚶"
        }
    }
}

// 근무 구간 (일반근무용)
enum WorkPeriod: String, Codable {
    case beforeWork = "출근 전"
    case duringWork = "근무 중"
    case afterWork = "퇴근 후"
}

// 알람 모델
struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date  // 알람 시간
    var purpose: AlarmPurpose  // 알람 목적
    var isEnabled: Bool  // 활성화 여부
    var repeatDays: Set<Int>  // 반복 요일 (1=일요일, 2=월요일, ..., 7=토요일)
    var workPeriod: WorkPeriod?  // 일반근무일 경우 구간

    init(
        id: UUID = UUID(),
        time: Date,
        purpose: AlarmPurpose,
        isEnabled: Bool = true,
        repeatDays: Set<Int> = [2, 3, 4, 5, 6], // 기본값: 월~금
        workPeriod: WorkPeriod? = nil
    ) {
        self.id = id
        self.time = time
        self.purpose = purpose
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.workPeriod = workPeriod
    }

    // 시간만 추출 (HH:mm 형식)
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}

// 샘플 데이터
extension Alarm {
    static let sampleAlarms: [Alarm] = [
        Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!,
            purpose: .water,
            workPeriod: .beforeWork
        ),
        Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 10, minute: 0))!,
            purpose: .stretch,
            workPeriod: .duringWork
        ),
        Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 12, minute: 0))!,
            purpose: .water,
            workPeriod: .duringWork
        ),
        Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 14, minute: 0))!,
            purpose: .water,
            workPeriod: .duringWork
        ),
        Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 19, minute: 0))!,
            purpose: .medicine,
            workPeriod: .afterWork
        )
    ]
}
