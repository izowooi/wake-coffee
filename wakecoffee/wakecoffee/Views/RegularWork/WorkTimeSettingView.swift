//
//  WorkTimeSettingView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct WorkTimeSettingView: View {
    @Binding var workSchedule: RegularWorkSchedule
    @State private var showingTimePicker = false
    @State private var editingStartTime = true

    var body: some View {
        HStack(spacing: 20) {
            // 출근 시간
            Button(action: {
                editingStartTime = true
                showingTimePicker = true
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("출근시간")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(workSchedule.startTimeString)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                )
            }

            // 화살표
            Image(systemName: "arrow.right")
                .foregroundColor(.gray)

            // 퇴근 시간
            Button(action: {
                editingStartTime = false
                showingTimePicker = true
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("퇴근시간")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(workSchedule.endTimeString)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(
                time: editingStartTime ? $workSchedule.startTime : $workSchedule.endTime,
                title: editingStartTime ? "출근시간 설정" : "퇴근시간 설정"
            )
            .presentationDetents([.height(350)])
        }
    }
}

// 시간 선택 시트
struct TimePickerSheet: View {
    @Binding var time: Date
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

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
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WorkTimeSettingView(workSchedule: .constant(RegularWorkSchedule()))
}
