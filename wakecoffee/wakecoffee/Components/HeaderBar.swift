//
//  HeaderBar.swift
//  wakecoffee
//
//  Created by izowooi on 10/22/25.
//

import SwiftUI

struct HeaderBar: View {
    var onStatistics: (() -> Void)?
    var onSettings: (() -> Void)?

    var body: some View {
        HStack {
            Text("Wake Coffee")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                onStatistics?()
            }) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            Button(action: {
                onSettings?()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    HeaderBar()
}
