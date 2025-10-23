//
//  WorkModeSelectionView.swift
//  wakecoffee
//
//  Created by izowooi on 10/23/25.
//

import SwiftUI

struct WorkModeSelectionView: View {
    let onModeSelected: (WorkMode) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "alarm.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Wake Coffee")
                    .font(.system(size: 36, weight: .bold))

                Text("근무 유형을 선택해주세요")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding(.bottom, 60)

            VStack(spacing: 16) {
                Button(action: {
                    onModeSelected(.regular)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 24))
                                Text("일반근무")
                                    .font(.system(size: 22, weight: .semibold))
                            }

                            Text("9-to-6 고정 근무시간")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    onModeSelected(.shift)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 24))
                                Text("교대근무")
                                    .font(.system(size: 22, weight: .semibold))
                            }

                            Text("2/3/4 교대 근무")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    WorkModeSelectionView { mode in
        print("Selected mode: \(mode)")
    }
}
