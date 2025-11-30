//
//  ContentView.swift
//  ShiftAlarm
//
//  Created by izowooi on 11/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        CalendarView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkSchedule.self, inMemory: true)
}
