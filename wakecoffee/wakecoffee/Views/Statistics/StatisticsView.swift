//
//  StatisticsView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss

    // 샘플 통계 데이터
    @State private var statistics = AlarmStatistics.sample

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 전체 통계 카드
                    OverallStatsCard(statistics: statistics)

                    // 주간 통계
                    WeeklyStatsCard(statistics: statistics)

                    // 목적별 통계
                    PurposeStatsCard()

                    // 최근 기록
                    RecentRecordsCard(statistics: statistics)
                }
                .padding()
            }
            .navigationTitle("통계")
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

// 전체 통계 카드
struct OverallStatsCard: View {
    let statistics: AlarmStatistics

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊")
                    .font(.title2)
                Text("전체 통계")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                StatItem(
                    title: "전체 준수율",
                    value: String(format: "%.1f%%", statistics.completionRate),
                    color: .blue
                )

                Divider()
                    .frame(height: 50)

                StatItem(
                    title: "이번 주",
                    value: String(format: "%.1f%%", statistics.weeklyCompletionRate),
                    color: .green
                )

                Divider()
                    .frame(height: 50)

                StatItem(
                    title: "총 알람",
                    value: "\(statistics.records.count)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// 주간 통계 차트
struct WeeklyStatsCard: View {
    let statistics: AlarmStatistics

    private var weeklyData: [DailyCompletion] {
        let calendar = Calendar.current
        let today = Date()

        return (-6...0).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let dayRecords = statistics.records.filter {
                calendar.isDate($0.scheduledTime, inSameDayAs: date)
            }

            let completed = dayRecords.filter { $0.isCompleted }.count
            let total = dayRecords.count
            let rate = total > 0 ? Double(completed) / Double(total) * 100 : 0

            return DailyCompletion(
                date: date,
                rate: rate,
                completed: completed,
                total: total
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📈")
                    .font(.title2)
                Text("최근 7일 준수율")
                    .font(.headline)
                Spacer()
            }

            if #available(iOS 16.0, *) {
                Chart(weeklyData) { data in
                    BarMark(
                        x: .value("날짜", data.date, unit: .day),
                        y: .value("준수율", data.rate)
                    )
                    .foregroundStyle(data.rate >= 80 ? Color.green : data.rate >= 50 ? Color.orange : Color.red)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Double.self) {
                                Text("\(Int(intValue))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
            } else {
                // iOS 16 미만 대체 UI
                VStack(spacing: 8) {
                    ForEach(weeklyData) { data in
                        HStack {
                            Text(data.date, format: .dateTime.month().day())
                                .font(.caption)
                                .frame(width: 40, alignment: .leading)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 20)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(data.rate >= 80 ? Color.green : data.rate >= 50 ? Color.orange : Color.red)
                                        .frame(width: geometry.size.width * CGFloat(data.rate / 100), height: 20)
                                }
                            }
                            .frame(height: 20)

                            Text("\(Int(data.rate))%")
                                .font(.caption)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let rate: Double
    let completed: Int
    let total: Int
}

// 목적별 통계
struct PurposeStatsCard: View {
    private let purposeStats = [
        (purpose: AlarmPurpose.water, rate: 85.0),
        (purpose: AlarmPurpose.stretch, rate: 72.0),
        (purpose: AlarmPurpose.medicine, rate: 95.0),
        (purpose: AlarmPurpose.coffee, rate: 68.0)
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎯")
                    .font(.title2)
                Text("목적별 준수율")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(purposeStats, id: \.purpose) { stat in
                    PurposeStatRow(purpose: stat.purpose, rate: stat.rate)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct PurposeStatRow: View {
    let purpose: AlarmPurpose
    let rate: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(purpose.icon)
                .font(.title3)

            Text(purpose.rawValue)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForRate(rate))
                        .frame(width: geometry.size.width * CGFloat(rate / 100), height: 8)
                }
            }
            .frame(height: 8)

            Text("\(Int(rate))%")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 40, alignment: .trailing)
        }
    }

    private func colorForRate(_ rate: Double) -> Color {
        if rate >= 80 { return .green }
        else if rate >= 50 { return .orange }
        else { return .red }
    }
}

// 최근 기록
struct RecentRecordsCard: View {
    let statistics: AlarmStatistics

    private var recentRecords: [AlarmRecord] {
        Array(statistics.records.sorted { $0.scheduledTime > $1.scheduledTime }.prefix(5))
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🕐")
                    .font(.title2)
                Text("최근 기록")
                    .font(.headline)
                Spacer()
            }

            if recentRecords.isEmpty {
                Text("기록이 없습니다")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentRecords) { record in
                        RecordRow(record: record)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct RecordRow: View {
    let record: AlarmRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(record.isCompleted ? .green : .red)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.scheduledTime, format: .dateTime.month().day().hour().minute())
                    .font(.subheadline)

                if let delay = record.delayMinutes, delay > 0 {
                    Text("\(delay)분 지연")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            Text(record.isCompleted ? "완료" : "미완료")
                .font(.caption)
                .foregroundColor(record.isCompleted ? .green : .gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
    }
}

#Preview {
    StatisticsView()
}
