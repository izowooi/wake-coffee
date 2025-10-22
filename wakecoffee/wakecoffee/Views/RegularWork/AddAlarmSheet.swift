//
//  AddAlarmSheet.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct AddAlarmSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alarms: [Alarm]

    @State private var selectedTime = Date()
    @State private var selectedPurpose: AlarmPurpose = .water
    @State private var selectedPeriod: WorkPeriod = .duringWork
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // 월~금

    let workSchedule: RegularWorkSchedule

    var body: some View {
        NavigationView {
            Form {
                // 시간 선택
                Section {
                    DatePicker(
                        "알람 시간",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                } header: {
                    Text("시간")
                }

                // 알람 목적 선택
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AlarmPurpose.allCases, id: \.self) { purpose in
                                PurposeButton(
                                    purpose: purpose,
                                    isSelected: selectedPurpose == purpose
                                ) {
                                    selectedPurpose = purpose
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("목적")
                }

                // 근무 구간 선택
                Section {
                    Picker("근무 구간", selection: $selectedPeriod) {
                        ForEach([WorkPeriod.beforeWork, .duringWork, .afterWork], id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("근무 구간")
                } footer: {
                    Text(periodHint)
                        .font(.caption)
                }

                // 반복 요일 선택
                Section {
                    VStack(spacing: 12) {
                        // 빠른 선택
                        HStack(spacing: 8) {
                            QuickSelectButton(title: "월~금") {
                                selectedDays = [2, 3, 4, 5, 6]
                            }
                            QuickSelectButton(title: "매일") {
                                selectedDays = [1, 2, 3, 4, 5, 6, 7]
                            }
                            QuickSelectButton(title: "주말") {
                                selectedDays = [1, 7]
                            }
                        }

                        Divider()

                        // 개별 요일 선택
                        HStack(spacing: 8) {
                            ForEach(1...7, id: \.self) { day in
                                WeekdayToggle(
                                    day: day,
                                    isSelected: selectedDays.contains(day)
                                ) {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("반복")
                }
            }
            .navigationTitle("알람 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveAlarm()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedDays.isEmpty)
                }
            }
        }
    }

    private var periodHint: String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: workSchedule.startTime)
        let endHour = calendar.component(.hour, from: workSchedule.endTime)

        switch selectedPeriod {
        case .beforeWork:
            return "출근 전 시간대입니다. (출근: \(String(format: "%02d:00", hour)))"
        case .duringWork:
            return "근무 중 시간대입니다. (\(String(format: "%02d:00", hour))~\(String(format: "%02d:00", endHour)))"
        case .afterWork:
            return "퇴근 후 시간대입니다. (퇴근: \(String(format: "%02d:00", endHour)))"
        }
    }

    private func saveAlarm() {
        let newAlarm = Alarm(
            time: selectedTime,
            purpose: selectedPurpose,
            isEnabled: true,
            repeatDays: selectedDays,
            workPeriod: selectedPeriod
        )
        alarms.append(newAlarm)
    }
}

// 목적 선택 버튼
struct PurposeButton: View {
    let purpose: AlarmPurpose
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(purpose.icon)
                    .font(.system(size: 36))
                Text(purpose.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// 빠른 선택 버튼
struct QuickSelectButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
                .foregroundColor(.blue)
        }
    }
}

// 요일 토글 버튼
struct WeekdayToggle: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        Button(action: action) {
            Text(weekdays[day - 1])
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    AddAlarmSheet(
        alarms: .constant([]),
        workSchedule: RegularWorkSchedule()
    )
}
