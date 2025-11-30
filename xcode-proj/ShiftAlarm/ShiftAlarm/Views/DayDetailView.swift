//
//  DayDetailView.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var schedules: [WorkSchedule]

    let date: Date
    let notificationManager: NotificationManager

    @State private var selectedShiftType: ShiftType = .dayShift
    @State private var isAnnualLeave: Bool = false
    @State private var existingSchedule: WorkSchedule?
    @State private var isLoading = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            List {
                // 날짜 섹션
                Section {
                    HStack {
                        Text("날짜")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(dateString)
                            .fontWeight(.semibold)
                    }
                }

                // 근무 유형 선택
                Section("근무 유형") {
                    Picker("근무 유형", selection: $selectedShiftType) {
                        ForEach(ShiftType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundStyle(type.color)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 연차 토글 (근무일인 경우에만 표시)
                if selectedShiftType != .off {
                    Section {
                        Toggle(isOn: $isAnnualLeave) {
                            HStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundStyle(.red)
                                Text("연차")
                                    .fontWeight(.medium)
                            }
                        }
                        .tint(.red)

                        if isAnnualLeave {
                            Text("연차로 설정하면 이 날의 모든 알람이 비활성화됩니다.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // 알람 시간 목록
                if !selectedShiftType.alarmHours.isEmpty && !isAnnualLeave {
                    Section("알람 시간") {
                        ForEach(selectedShiftType.alarmHours, id: \.self) { hour in
                            HStack {
                                Image(systemName: "alarm.fill")
                                    .foregroundStyle(.orange)
                                    .font(.caption)

                                Text(String(format: "%02d:00", hour))
                                    .font(.body)
                            }
                        }
                    }
                } else {
                    Section {
                        Text("휴무일에는 알람이 없습니다")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }

                // 삭제 버튼 (기존 스케줄이 있는 경우)
                if existingSchedule != nil {
                    Section {
                        Button(role: .destructive, action: deleteSchedule) {
                            HStack {
                                Spacer()
                                Text("스케줄 삭제")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("일정 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveSchedule()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadExistingSchedule()
            }
        }
    }

    // MARK: - Helper Functions

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    private func loadExistingSchedule() {
        let dateStart = calendar.startOfDay(for: date)
        existingSchedule = schedules.first { schedule in
            calendar.isDate(schedule.dateStart, inSameDayAs: dateStart)
        }

        if let schedule = existingSchedule {
            selectedShiftType = schedule.shiftType
            isAnnualLeave = !schedule.isActive
        }
    }

    private func saveSchedule() {
        isLoading = true

        let dateStart = calendar.startOfDay(for: date)

        if let existing = existingSchedule {
            // 기존 스케줄 업데이트
            existing.shiftType = selectedShiftType
            existing.isActive = !isAnnualLeave
        } else {
            // 새 스케줄 생성
            let newSchedule = WorkSchedule(date: dateStart, shiftType: selectedShiftType, isActive: !isAnnualLeave)
            modelContext.insert(newSchedule)
        }

        // 저장
        do {
            try modelContext.save()

            // 알람 재설정
            Task {
                await notificationManager.scheduleAllNotifications(for: schedules)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            }
        } catch {
            print("Error saving schedule: \(error)")
            isLoading = false
        }
    }

    private func deleteSchedule() {
        guard let schedule = existingSchedule else { return }

        isLoading = true

        // 스케줄 삭제
        modelContext.delete(schedule)

        do {
            try modelContext.save()

            // 알람 재설정
            Task {
                await notificationManager.cancelNotifications(for: schedule)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            }
        } catch {
            print("Error deleting schedule: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    DayDetailView(date: Date(), notificationManager: NotificationManager.shared)
        .modelContainer(for: WorkSchedule.self, inMemory: true)
}
