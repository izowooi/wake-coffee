//
//  OnboardingView.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-12-04.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var notificationManager: NotificationManager
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentPage = 0
    @State private var isRequestingPermission = false

    var body: some View {
        VStack(spacing: 0) {
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)

            // 페이지 내용
            TabView(selection: $currentPage) {
                welcomePage
                    .tag(0)

                notificationPermissionPage
                    .tag(1)

                constraintsPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // 하단 버튼
            VStack(spacing: 16) {
                if currentPage < 2 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("다음")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("시작하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }

                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Text("이전")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 페이지들

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "alarm.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("ShiftAlarm에 오신 것을 환영합니다")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("3교대 근무자를 위한\n스마트 알람 앱")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "calendar", text: "근무 일정 관리")
                FeatureRow(icon: "bell.badge.fill", text: "자동 알람 설정")
                FeatureRow(icon: "moon.fill", text: "주간/야간 근무 지원")
            }
            .padding(.top, 32)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var notificationPermissionPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)

            Text("알림 권한이 필요합니다")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("근무 시간에 알람을 받기 위해\n알림 권한을 허용해주세요")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            if isRequestingPermission {
                ProgressView()
                    .padding(.top, 32)
            } else if notificationManager.authorizationStatus == .authorized {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("권한이 허용되었습니다")
                        .foregroundColor(.green)
                }
                .padding(.top, 32)
            } else {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("알림 권한 허용하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.top, 32)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var constraintsPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("iOS 제약사항 안내")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    ConstraintCard(
                        icon: "speaker.wave.2.fill",
                        title: "매너모드 (Ring/Silent Switch)",
                        description: "• 매너모드 ON: 진동만 발생\n• 매너모드 OFF: 소리 + 진동\n• Apple 정책으로 매너모드 강제 우회 불가"
                    )

                    ConstraintCard(
                        icon: "clock.fill",
                        title: "알람 지속 시간",
                        description: "• Apple 정책으로 알람 소리는 약 30초 지속됩니다"
                    )

                    ConstraintCard(
                        icon: "hand.raised.fill",
                        title: "권장 설정",
                        description: "• 중요한 알람은 매너모드 해제 권장\n• Focus 모드에서 ShiftAlarm 허용 설정\n• 시스템 설정 > 알림 > ShiftAlarm 확인"
                    )
                }

                Text("Time Sensitive Notifications를 사용하여 Focus 모드를 우회하고 화면이 즉시 점등됩니다.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Helper Views

    private struct FeatureRow: View {
        let icon: String
        let text: String

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)

                Text(text)
                    .font(.body)
            }
        }
    }

    private struct ConstraintCard: View {
        let icon: String
        let title: String
        let description: String

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.orange)

                    Text(title)
                        .font(.headline)
                }

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Actions

    private func requestNotificationPermission() {
        isRequestingPermission = true
        Task {
            _ = await notificationManager.requestAuthorization()
            await MainActor.run {
                isRequestingPermission = false
            }
        }
    }
}

#Preview {
    OnboardingView(
        notificationManager: NotificationManager.shared,
        hasCompletedOnboarding: .constant(false)
    )
}
