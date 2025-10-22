//
//  ShiftPatternSelector.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct ShiftPatternSelector: View {
    @Binding var schedule: ShiftWorkSchedule
    @State private var showingDatePicker = false
    @State private var showingTimeSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Text("🔄")
                    .font(.title2)
                Text("교대 패턴 설정")
                    .font(.headline)
            }

            // 교대 유형 선택
            VStack(alignment: .leading, spacing: 8) {
                Text("교대 유형")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Picker("교대 유형", selection: $schedule.shiftType) {
                    ForEach(ShiftType.allCases.filter { $0 != .custom }, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // 패턴 설명
                Text(shiftTypeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Divider()

            // 시작일 선택
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("시작일")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(schedule.startDate, style: .date)
                        .font(.headline)
                }

                Spacer()

                Button(action: {
                    showingDatePicker = true
                }) {
                    Text("변경")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }

            Divider()

            // 근무 시간 설정
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("근무시간")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: {
                        showingTimeSettings = true
                    }) {
                        Text("설정")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🌞")
                        Text("주간")
                            .font(.subheadline)
                        Spacer()
                        Text("\(timeString(schedule.dayShiftStart)) - \(timeString(schedule.dayShiftEnd))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if schedule.shiftType != .twoShift {
                        HStack {
                            Text("🌙")
                            Text("야간")
                                .font(.subheadline)
                            Spacer()
                            Text("\(timeString(schedule.nightShiftStart)) - \(timeString(schedule.nightShiftEnd))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(startDate: $schedule.startDate)
        }
        .sheet(isPresented: $showingTimeSettings) {
            ShiftTimeSettingsSheet(schedule: $schedule)
        }
    }

    private var shiftTypeDescription: String {
        switch schedule.shiftType {
        case .twoShift:
            return "2일 주간 근무 → 2일 휴무 반복"
        case .threeShift:
            return "2일 주간 → 2일 야간 → 2일 휴무 반복"
        case .fourShift:
            return "2일 주간 → 2일 야간 → 2일 저녁 → 2일 휴무 반복"
        case .custom:
            return "사용자 정의 패턴"
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// 시작일 선택 시트
struct DatePickerSheet: View {
    @Binding var startDate: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "시작일",
                    selection: $startDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("완료") {
                    dismiss()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()

                Spacer()
            }
            .navigationTitle("시작일 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 근무 시간 설정 시트
struct ShiftTimeSettingsSheet: View {
    @Binding var schedule: ShiftWorkSchedule
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "시작",
                        selection: $schedule.dayShiftStart,
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "종료",
                        selection: $schedule.dayShiftEnd,
                        displayedComponents: .hourAndMinute
                    )
                } header: {
                    HStack {
                        Text("🌞")
                        Text("주간 근무")
                    }
                }

                if schedule.shiftType != .twoShift {
                    Section {
                        DatePicker(
                            "시작",
                            selection: $schedule.nightShiftStart,
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "종료",
                            selection: $schedule.nightShiftEnd,
                            displayedComponents: .hourAndMinute
                        )
                    } header: {
                        HStack {
                            Text("🌙")
                            Text("야간 근무")
                        }
                    }
                }
            }
            .navigationTitle("근무 시간 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ShiftPatternSelector(schedule: .constant(ShiftWorkSchedule.sample))
        .padding()
}
