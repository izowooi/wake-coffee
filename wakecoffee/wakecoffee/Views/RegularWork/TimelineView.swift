//
//  TimelineView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct TimelineView: View {
    let alarms: [Alarm]
    let workSchedule: RegularWorkSchedule
    var onToggleAlarm: ((Alarm, Bool) -> Void)?
    var onDeleteAlarm: ((Alarm) -> Void)?

    // 타임라인에 표시할 시간대 구간들
    private var timelineItems: [TimelineItem] {
        var items: [TimelineItem] = []

        // 출근 전 구간
        let beforeWorkAlarms = alarms.filter { $0.workPeriod == .beforeWork }.sorted { $0.time < $1.time }
        if !beforeWorkAlarms.isEmpty {
            items.append(.periodMarker(.beforeWork))
            beforeWorkAlarms.forEach { items.append(.alarm($0)) }
        }

        // 출근 시간 마커
        items.append(.workTimeMarker(workSchedule.startTime, isStart: true))

        // 근무 중 구간
        let duringWorkAlarms = alarms.filter { $0.workPeriod == .duringWork }.sorted { $0.time < $1.time }
        if !duringWorkAlarms.isEmpty {
            items.append(.periodMarker(.duringWork))
            duringWorkAlarms.forEach { items.append(.alarm($0)) }
        }

        // 퇴근 시간 마커
        items.append(.workTimeMarker(workSchedule.endTime, isStart: false))

        // 퇴근 후 구간
        let afterWorkAlarms = alarms.filter { $0.workPeriod == .afterWork }.sorted { $0.time < $1.time }
        if !afterWorkAlarms.isEmpty {
            items.append(.periodMarker(.afterWork))
            afterWorkAlarms.forEach { items.append(.alarm($0)) }
        }

        return items
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(timelineItems.enumerated()), id: \.offset) { index, item in
                    switch item {
                    case .periodMarker(let period):
                        PeriodMarkerView(period: period)
                            .padding(.top, index == 0 ? 0 : 12)

                    case .alarm(let alarm):
                        TimelineAlarmRow(
                            alarm: alarm,
                            onToggle: { isEnabled in
                                onToggleAlarm?(alarm, isEnabled)
                            },
                            onDelete: {
                                onDeleteAlarm?(alarm)
                            }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 4)

                    case .workTimeMarker(let time, let isStart):
                        WorkTimeMarkerView(time: time, isStart: isStart)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
}

// 타임라인 아이템 타입
enum TimelineItem {
    case periodMarker(WorkPeriod)
    case alarm(Alarm)
    case workTimeMarker(Date, isStart: Bool)
}

// 구간 마커 뷰
struct PeriodMarkerView: View {
    let period: WorkPeriod

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(colorForPeriod)
                .frame(width: 4, height: 30)
                .padding(.leading, 76)

            Text(period.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(colorForPeriod)

            Spacer()
        }
    }

    private var colorForPeriod: Color {
        switch period {
        case .beforeWork: return .blue
        case .duringWork: return .green
        case .afterWork: return .orange
        }
    }
}

// 출퇴근 시간 마커 뷰
struct WorkTimeMarkerView: View {
    let time: Date
    let isStart: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(timeString)
                .font(.headline)
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 4)

            Divider()
                .frame(height: 2)
                .overlay(Color.gray)

            Text(isStart ? "근무시작" : "퇴근시간")
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(.horizontal)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}

// 타임라인 알람 행
struct TimelineAlarmRow: View {
    let alarm: Alarm
    var onToggle: ((Bool) -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // 시간
            Text(alarm.timeString)
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 60, alignment: .leading)

            // 타임라인 바
            Rectangle()
                .fill(colorForPeriod)
                .frame(width: 4, height: 50)

            // 알람 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alarm.purpose.icon)
                        .font(.title3)
                    Text(alarm.purpose.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                }

                Text(repeatDaysString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // 토글
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { onToggle?($0) }
            ))
            .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
        .contextMenu {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    private var colorForPeriod: Color {
        guard let period = alarm.workPeriod else { return .gray }
        switch period {
        case .beforeWork: return .blue.opacity(0.6)
        case .duringWork: return .green.opacity(0.6)
        case .afterWork: return .orange.opacity(0.6)
        }
    }

    private var repeatDaysString: String {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let sortedDays = alarm.repeatDays.sorted()

        if sortedDays == [2, 3, 4, 5, 6] {
            return "월~금"
        } else if sortedDays == [1, 2, 3, 4, 5, 6, 7] {
            return "매일"
        } else if sortedDays.isEmpty {
            return "반복 없음"
        } else {
            return sortedDays.map { weekdays[$0 - 1] }.joined(separator: ", ")
        }
    }
}

#Preview {
    TimelineView(
        alarms: Alarm.sampleAlarms,
        workSchedule: RegularWorkSchedule()
    )
}
