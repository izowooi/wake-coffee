//
//  ContentView.swift
//  ShiftAlarm
//
//  Created by izowooi on 11/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                CalendarView()
            } else {
                OnboardingView(
                    notificationManager: notificationManager,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkSchedule.self, inMemory: true)
}
