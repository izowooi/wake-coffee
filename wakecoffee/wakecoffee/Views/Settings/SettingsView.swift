//
//  SettingsView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var defaultStartTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
    @State private var defaultEndTime = Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!
    @State private var showingNotificationAlert = false

    var body: some View {
        NavigationView {
            Form {
                // 알림 설정
                Section {
                    Toggle("알림 허용", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }

                    if notificationsEnabled {
                        Toggle("소리", isOn: $soundEnabled)
                        Toggle("진동", isOn: $vibrationEnabled)
                    }
                } header: {
                    Label("알림", systemImage: "bell.fill")
                } footer: {
                    Text("알람이 울릴 때 알림을 받으려면 알림 허용이 필요합니다.")
                }

                // 일반 근무 기본값
                Section {
                    DatePicker(
                        "출근시간",
                        selection: $defaultStartTime,
                        displayedComponents: .hourAndMinute
                    )

                    DatePicker(
                        "퇴근시간",
                        selection: $defaultEndTime,
                        displayedComponents: .hourAndMinute
                    )
                } header: {
                    Label("일반 근무 기본값", systemImage: "briefcase.fill")
                } footer: {
                    Text("새로운 일반 근무 알람을 만들 때 사용되는 기본 시간입니다.")
                }

                // 앱 정보
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        showingNotificationAlert = true
                    }) {
                        HStack {
                            Text("알림 권한 설정")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Label("앱 정보", systemImage: "info.circle.fill")
                }

                // 데이터 관리
                Section {
                    Button(role: .destructive) {
                        // TODO: 모든 알람 삭제
                    } label: {
                        Text("모든 알람 삭제")
                    }

                    Button(role: .destructive) {
                        // TODO: 통계 데이터 초기화
                    } label: {
                        Text("통계 데이터 초기화")
                    }
                } header: {
                    Label("데이터 관리", systemImage: "trash.fill")
                } footer: {
                    Text("삭제된 데이터는 복구할 수 없습니다.")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("알림 권한", isPresented: $showingNotificationAlert) {
                Button("설정으로 이동") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("알림 권한을 변경하려면 설정 앱에서 Wake Coffee의 알림 설정을 변경해주세요.")
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
