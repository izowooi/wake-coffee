//
//  TimelineDivider.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct TimelineDivider: View {
    let period: WorkPeriod
    let showLabel: Bool

    init(period: WorkPeriod, showLabel: Bool = true) {
        self.period = period
        self.showLabel = showLabel
    }

    var body: some View {
        HStack(spacing: 12) {
            // 시간 표시 영역 (공백)
            Spacer()
                .frame(width: 60)

            // 타임라인 바
            Rectangle()
                .fill(colorForPeriod)
                .frame(width: 4, height: showLabel ? 30 : 20)

            // 구간 라벨
            if showLabel {
                Text(period.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
    }

    private var colorForPeriod: Color {
        switch period {
        case .beforeWork: return .blue.opacity(0.6)
        case .duringWork: return .green.opacity(0.6)
        case .afterWork: return .orange.opacity(0.6)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TimelineDivider(period: .beforeWork)
        TimelineDivider(period: .duringWork)
        TimelineDivider(period: .afterWork)
    }
    .padding()
}
