//
//  AddShiftAlarmSheet.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct AddShiftAlarmSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alarms: [Alarm]

    @State private var selectedPurpose: AlarmPurpose = .water
    @State private var intervalHours: Int = 2
    @State private var offsetMinutes: Int = 0

    let schedule: ShiftWorkSchedule

    var body: some View {
        NavigationView {
            Form {
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

                // 간격 설정
                Section {
                    Picker("간격", selection: $intervalHours) {
                        ForEach([1, 2, 3, 4], id: \.self) { hour in
                            Text("\(hour)시간").tag(hour)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("근무 시작 후")
                            .foregroundColor(.gray)
                        Spacer()
                        Picker("시작 후", selection: $offsetMinutes) {
                            Text("바로").tag(0)
                            Text("30분").tag(30)
                            Text("1시간").tag(60)
                            Text("1시간 30분").tag(90)
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("알람 간격")
                } footer: {
                    Text(intervalDescription)
                        .font(.caption)
                }

                // 미리보기
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(previewAlarms, id: \.self) { time in
                            HStack {
                                Text(selectedPurpose.icon)
                                    .font(.title3)
                                Text(time)
                                    .font(.body)
                                Spacer()
                                Text(selectedPurpose.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("알람 미리보기 (주간 근무 기준)")
                }

                // 설명
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(
                            icon: "info.circle.fill",
                            text: "근무일에만 알람이 울립니다"
                        )
                        infoRow(
                            icon: "clock.fill",
                            text: "근무 시작 시간을 기준으로 자동 계산됩니다"
                        )
                        infoRow(
                            icon: "bell.fill",
                            text: "주간/야간/저녁 근무 시간에 맞춰 조정됩니다"
                        )
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                        saveAlarms()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var intervalDescription: String {
        let offsetText = offsetMinutes == 0 ? "근무 시작 직후" : "근무 시작 \(offsetMinutes)분 후"
        return "\(offsetText)부터 매 \(intervalHours)시간마다 알람이 울립니다."
    }

    private var previewAlarms: [String] {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: schedule.dayShiftStart)
        let startMinute = calendar.component(.minute, from: schedule.dayShiftStart)
        let endHour = calendar.component(.hour, from: schedule.dayShiftEnd)

        var times: [String] = []
        var currentMinutes = startHour * 60 + startMinute + offsetMinutes
        let endMinutes = endHour * 60

        while currentMinutes < endMinutes {
            let hour = currentMinutes / 60
            let minute = currentMinutes % 60
            times.append(String(format: "%02d:%02d", hour, minute))
            currentMinutes += intervalHours * 60
        }

        return times
    }

    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
        }
    }

    private func saveAlarms() {
        // 실제 로직은 Phase 5에서 구현
        // 지금은 간단히 샘플 알람만 추가
        let calendar = Calendar.current
        for timeString in previewAlarms {
            let components = timeString.split(separator: ":")
            if let hour = Int(components[0]), let minute = Int(components[1]) {
                let time = calendar.date(from: DateComponents(hour: hour, minute: minute))!
                let alarm = Alarm(
                    time: time,
                    purpose: selectedPurpose,
                    isEnabled: true,
                    repeatDays: [1, 2, 3, 4, 5, 6, 7], // 교대근무는 패턴에 따라 동작
                    workPeriod: .duringWork,
                    intervalHours: intervalHours
                )
                alarms.append(alarm)
            }
        }
    }
}

#Preview {
    AddShiftAlarmSheet(
        alarms: .constant([]),
        schedule: ShiftWorkSchedule.sample
    )
}
