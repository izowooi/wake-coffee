//
//  ShiftWorkView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct ShiftWorkView: View {
    @Binding var currentWorkMode: WorkMode
    @StateObject private var viewModel = ShiftWorkViewModel()
    @State private var showingAddAlarm = false
    @State private var showingStatistics = false
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HeaderBar(
                onStatistics: {
                    showingStatistics = true
                },
                onSettings: {
                    showingSettings = true
                }
            )

            ScrollView {
                VStack(spacing: 20) {
                    // 교대 패턴 설정
                    ShiftPatternSelector(schedule: $viewModel.schedule)
                        .onChange(of: viewModel.schedule) { _, newValue in
                            viewModel.updateSchedule(newValue)
                        }

                    // 스케줄 프리뷰
                    SchedulePreview(schedule: viewModel.schedule)

                    // 근무 중 알람 설정
                    VStack(alignment: .leading, spacing: 12) {
                        Text("근무 중 알람 설정")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.alarms.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "bell.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("설정된 알람이 없습니다")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.alarms) { alarm in
                                    ShiftAlarmCard(alarm: alarm) {
                                        viewModel.deleteAlarm(alarm)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }

            // 알람 추가 버튼
            Button(action: {
                showingAddAlarm = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("알람 추가")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .sheet(isPresented: $showingAddAlarm) {
            AddShiftAlarmSheet(alarms: $viewModel.alarms, schedule: viewModel.schedule)
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(currentWorkMode: $currentWorkMode)
        }
    }
}

// 교대근무용 알람 카드
struct ShiftAlarmCard: View {
    let alarm: Alarm
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(alarm.purpose.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.purpose.rawValue)
                    .font(.body)
                    .fontWeight(.medium)

                Text(intervalText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Toggle("", isOn: .constant(alarm.isEnabled))
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    private var intervalText: String {
        if let interval = alarm.intervalHours {
            return "근무 중 \(interval)시간마다"
        }
        return "근무 중"
    }
}

#Preview {
    ShiftWorkView(currentWorkMode: .constant(.shift))
}
