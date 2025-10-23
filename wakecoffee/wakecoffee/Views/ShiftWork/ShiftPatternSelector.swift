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
    @State private var showingPatternSelector = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Text("🔄")
                    .font(.title2)
                Text("교대 패턴 설정")
                    .font(.headline)
            }

            // 현재 선택된 패턴 표시
            Button(action: {
                showingPatternSelector = true
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("교대 유형")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text(schedule.pattern.name)
                            .font(.headline)
                        Spacer()
                        Text(schedule.pattern.shortPattern)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }

                    Text(schedule.pattern.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())

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

                    if schedule.pattern.cycle.contains(.night) {
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

                    if schedule.pattern.cycle.contains(.evening) {
                        HStack {
                            Text("🌆")
                            Text("저녁")
                                .font(.subheadline)
                            Spacer()
                            Text("\(timeString(schedule.eveningShiftStart)) - \(timeString(schedule.eveningShiftEnd))")
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
        .sheet(isPresented: $showingPatternSelector) {
            PatternSelectorSheet(selectedPattern: $schedule.pattern)
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// 패턴 선택 시트
struct PatternSelectorSheet: View {
    @Binding var selectedPattern: ShiftPattern
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredPatterns: [ShiftPattern] {
        if searchText.isEmpty {
            return ShiftPattern.presets
        }
        return ShiftPattern.presets.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredPatterns) { pattern in
                    Button(action: {
                        selectedPattern = pattern
                        dismiss()
                    }) {
                        PatternRow(
                            pattern: pattern,
                            isSelected: pattern.id == selectedPattern.id
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "패턴 검색")
            .navigationTitle("교대 패턴 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 패턴 행
struct PatternRow: View {
    let pattern: ShiftPattern
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pattern.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .blue : .primary)

                    Text(pattern.shortPattern)
                        .font(.caption)
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((isSelected ? Color.blue : Color.gray).opacity(0.1))
                        .cornerRadius(4)
                }

                Text(pattern.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 패턴 시각화
                HStack(spacing: 2) {
                    ForEach(Array(pattern.cycle.enumerated()), id: \.offset) { index, shift in
                        Text(shift.icon)
                            .font(.system(size: 12))
                    }
                }
                .padding(.top, 4)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
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
                if schedule.pattern.cycle.contains(.day) {
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
                }

                if schedule.pattern.cycle.contains(.night) {
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

                if schedule.pattern.cycle.contains(.evening) {
                    Section {
                        DatePicker(
                            "시작",
                            selection: $schedule.eveningShiftStart,
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "종료",
                            selection: $schedule.eveningShiftEnd,
                            displayedComponents: .hourAndMinute
                        )
                    } header: {
                        HStack {
                            Text("🌆")
                            Text("저녁 근무")
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
