//
//  PowerOffEmptyStateView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct PowerOffEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "Disconnected",
            systemImage: "antenna.radiowaves.left.and.right.slash",
            description: Text("Please turn bluetooth on.")
        )
    }
}

#Preview {
    PowerOffEmptyStateView()
}
