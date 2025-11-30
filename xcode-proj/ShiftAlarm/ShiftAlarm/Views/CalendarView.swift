//
//  CalendarView.swift
//  ShiftAlarm
//
//  Created by Claude on 2025-11-30.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var schedules: [WorkSchedule]
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 월 선택 헤더
                monthHeader

                // 요일 헤더
                weekdayHeader

                // 캘린더 그리드
                calendarGrid

                // 범례
                legend

                Spacer()
            }
            .padding()
            .navigationTitle("근무 일정")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDayDetail) {
                if let selectedDate = selectedDate {
                    DayDetailView(date: selectedDate, notificationManager: notificationManager)
                }
            }
            .task {
                await notificationManager.checkAuthorizationStatus()
            }
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(day == "일" ? .red : .primary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = generateDaysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { day in
                if let day = day {
                    dayCell(for: day)
                } else {
                    Color.clear
                        .frame(height: 60)
                }
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(for date: Date) -> some View {
        let schedule = getSchedule(for: date)
        let isToday = calendar.isDateInToday(date)
        let dayNumber = calendar.component(.day, from: date)
        let isAnnualLeave = schedule != nil && !schedule!.isActive

        return VStack(spacing: 4) {
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundStyle(isToday ? .white : .primary)

            if let schedule = schedule {
                ZStack {
                    Image(systemName: schedule.shiftType.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(schedule.shiftType.color)
                        .opacity(isAnnualLeave ? 0.4 : 1.0)

                    // 연차인 경우 줄 긋기
                    if isAnnualLeave {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 2)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.blue : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(schedule != nil ? schedule!.shiftType.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedDate = date
            showingDayDetail = true
        }
    }

    // MARK: - Legend

    private var legend: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                ForEach(ShiftType.allCases, id: \.self) { type in
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.caption)
                            .foregroundStyle(type.color)

                        Text(type.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 연차 표시 설명
            HStack(spacing: 4) {
                ZStack {
                    Image(systemName: "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                        .opacity(0.4)

                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 12, height: 1.5)
                        .rotationEffect(.degrees(-45))
                }

                Text("연차")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemGray6))
        )
    }

    // MARK: - Helper Functions

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentDate)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }

        var days: [Date?] = []

        // 앞쪽 빈 칸 추가 (일요일이 1)
        let emptySlots = firstWeekday - 1
        days.append(contentsOf: Array(repeating: nil, count: emptySlots))

        // 월의 모든 날짜 추가
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }

        return days
    }

    private func getSchedule(for date: Date) -> WorkSchedule? {
        let dateStart = calendar.startOfDay(for: date)
        return schedules.first { schedule in
            calendar.isDate(schedule.dateStart, inSameDayAs: dateStart)
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: WorkSchedule.self, inMemory: true)
}
