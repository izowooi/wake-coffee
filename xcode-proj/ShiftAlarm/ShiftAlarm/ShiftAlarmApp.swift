//
//  ShiftAlarmApp.swift
//  ShiftAlarm
//
//  Created by izowooi on 11/30/25.
//

import SwiftUI
import SwiftData

@main
struct ShiftAlarmApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkSchedule.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 앱 시작 시 초기 설정
                    let modelContext = sharedModelContainer.mainContext

                    // 1. 12월 근무표 자동 생성
                    await InitialDataManager.setupInitialScheduleIfNeeded(modelContext: modelContext)

                    // 2. 알림 권한 요청
                    let notificationManager = NotificationManager.shared
                    await notificationManager.checkAuthorizationStatus()
                    if notificationManager.authorizationStatus == .notDetermined {
                        _ = await notificationManager.requestAuthorization()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
