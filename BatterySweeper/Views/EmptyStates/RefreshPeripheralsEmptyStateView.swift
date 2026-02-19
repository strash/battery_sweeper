//
//  RefreshPeripheralsEmptyStateView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct RefreshPeripheralsEmptyStateView: View {
    @Environment(AppViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            ContentUnavailableView(
                "Oops! No Devices Detected",
                systemImage: "arrow.clockwise",
                description: Text("Please make sure your devices are powered on and within range. Click 'Refresh' to search for devices.")
            )
            
            Button("Refresh") {
                viewModel.retrieveConnectedPeripherals()
            }
        }
    }
}

#Preview {
    RefreshPeripheralsEmptyStateView()
}
