//
//  AlarmCard.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct AlarmCard: View {
    let alarm: Alarm
    var onToggle: ((Bool) -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // 시간
            Text(alarm.timeString)
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 70, alignment: .leading)

            // 목적 아이콘 및 이름
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alarm.purpose.icon)
                        .font(.title3)
                    Text(alarm.purpose.rawValue)
                        .font(.body)
                }

                // 반복 요일
                Text(repeatDaysString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // 토글 스위치
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    onToggle?(newValue)
                }
            ))
            .labelsHidden()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    private var repeatDaysString: String {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let sortedDays = alarm.repeatDays.sorted()

        if sortedDays == [2, 3, 4, 5, 6] {
            return "월~금"
        } else if sortedDays == [1, 2, 3, 4, 5, 6, 7] {
            return "매일"
        } else if sortedDays.isEmpty {
            return "반복 없음"
        } else {
            return sortedDays.map { weekdays[$0 - 1] }.joined(separator: ", ")
        }
    }
}

#Preview {
    VStack {
        AlarmCard(alarm: Alarm.sampleAlarms[0])
        AlarmCard(alarm: Alarm.sampleAlarms[1])
        AlarmCard(alarm: Alarm(
            time: Calendar.current.date(from: DateComponents(hour: 15, minute: 30))!,
            purpose: .coffee,
            isEnabled: false,
            repeatDays: [1, 2, 3, 4, 5, 6, 7]
        ))
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
