//
//  SchedulePreview.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct SchedulePreview: View {
    let schedule: ShiftWorkSchedule
    let daysToShow: Int

    init(schedule: ShiftWorkSchedule, daysToShow: Int = 7) {
        self.schedule = schedule
        self.daysToShow = daysToShow
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text("📅")
                    .font(.title2)
                Text("다음 \(daysToShow)일 스케줄")
                    .font(.headline)
            }

            // 스케줄 리스트
            VStack(spacing: 8) {
                ForEach(0..<daysToShow, id: \.self) { dayOffset in
                    scheduleRow(for: dayOffset)
                }
            }

            // 범례 - 패턴에 포함된 근무 시간대만 표시
            HStack(spacing: 16) {
                if schedule.pattern.cycle.contains(.day) {
                    legendItem(icon: "🌞", label: "주간")
                }
                if schedule.pattern.cycle.contains(.night) {
                    legendItem(icon: "🌙", label: "야간")
                }
                if schedule.pattern.cycle.contains(.evening) {
                    legendItem(icon: "🌆", label: "저녁")
                }
                if schedule.pattern.cycle.contains(.off) {
                    legendItem(icon: "⚪", label: "휴무")
                }
            }
            .font(.caption)
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }

    @ViewBuilder
    private func scheduleRow(for dayOffset: Int) -> some View {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
        let shiftTime = schedule.getShiftTime(for: date)
        let isToday = Calendar.current.isDateInToday(date)

        HStack(spacing: 12) {
            // 날짜
            VStack(alignment: .leading, spacing: 2) {
                Text(date, format: .dateTime.month().day())
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                Text(weekdayString(for: date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 50, alignment: .leading)

            // 구분선
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 30)

            // 근무 타입
            HStack(spacing: 8) {
                Text(shiftTime.icon)
                    .font(.title3)
                Text(shiftTime.rawValue)
                    .font(.body)
                    .fontWeight(isToday ? .semibold : .regular)
            }
            .foregroundColor(isToday ? .primary : .secondary)

            Spacer()

            // 근무 시간
            if shiftTime != .off {
                Text(shiftTimeString(for: shiftTime))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorForShiftTime(shiftTime).opacity(0.2))
                    )
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.blue.opacity(0.05) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func legendItem(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(icon)
            Text(label)
                .foregroundColor(.gray)
        }
    }

    private func weekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return "(\(formatter.string(from: date)))"
    }

    private func shiftTimeString(for shiftTime: ShiftTime) -> String {
        let calendar = Calendar.current
        let startTime = schedule.getShiftStartTime(for: shiftTime)
        let endTime = schedule.getShiftEndTime(for: shiftTime)

        if shiftTime == .off {
            return ""
        }

        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)

        return "\(String(format: "%02d:%02d", startHour, startMinute))-\(String(format: "%02d:%02d", endHour, endMinute))"
    }

    private func colorForShiftTime(_ shiftTime: ShiftTime) -> Color {
        switch shiftTime {
        case .day: return .yellow
        case .night: return .purple
        case .evening: return .orange
        case .off: return .gray
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            SchedulePreview(schedule: ShiftWorkSchedule.sample)
                .padding()

            SchedulePreview(
                schedule: ShiftWorkSchedule(pattern: ShiftPattern.presets[5]),
                daysToShow: 14
            )
            .padding()
        }
    }
}
