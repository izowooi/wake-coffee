//
//  wakecoffeeApp.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

@main
struct wakecoffeeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 알림 카테고리 설정
        NotificationManager.shared.setupNotificationCategories()

        // 알림 권한 확인
        NotificationManager.shared.checkAuthorization()

        return true
    }
}
