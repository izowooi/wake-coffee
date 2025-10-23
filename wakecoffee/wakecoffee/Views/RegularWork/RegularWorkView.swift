//
//  RegularWorkView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct RegularWorkView: View {
    @Binding var currentWorkMode: WorkMode
    @StateObject private var viewModel = RegularWorkViewModel()
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

            // 출퇴근 시간 설정
            WorkTimeSettingView(workSchedule: $viewModel.workSchedule)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
                .onChange(of: viewModel.workSchedule) { _, newValue in
                    viewModel.updateWorkSchedule(newValue)
                }

            // 타임라인
            TimelineView(
                alarms: viewModel.alarms,
                workSchedule: viewModel.workSchedule,
                onToggleAlarm: { alarm, _ in
                    viewModel.toggleAlarm(alarm)
                },
                onDeleteAlarm: { alarm in
                    viewModel.deleteAlarm(alarm)
                }
            )

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
            AddAlarmSheet(alarms: $viewModel.alarms, workSchedule: viewModel.workSchedule)
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(currentWorkMode: $currentWorkMode)
        }
    }
}

#Preview {
    RegularWorkView(currentWorkMode: .constant(.regular))
}
