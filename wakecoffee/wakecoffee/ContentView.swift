//
//  ContentView.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedWorkMode: WorkMode?

    var body: some View {
        Group {
            if let workMode = selectedWorkMode {
                // 근무 유형이 선택된 경우 해당 화면 표시
                switch workMode {
                case .regular:
                    RegularWorkView()
                case .shift:
                    ShiftWorkView()
                }
            } else {
                // 근무 유형이 선택되지 않은 경우 온보딩 화면 표시
                WorkModeSelectionView { mode in
                    DataManager.shared.saveWorkMode(mode)
                    selectedWorkMode = mode
                }
            }
        }
        .onAppear {
            // 앱 시작 시 저장된 근무 유형 로드
            selectedWorkMode = DataManager.shared.loadWorkMode()
        }
    }
}

#Preview {
    ContentView()
}
