//
//  MainTabView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RegularWorkView()
                .tabItem {
                    Label("일반근무", systemImage: "briefcase.fill")
                }
                .tag(0)

            ShiftWorkView()
                .tabItem {
                    Label("교대근무", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}
