//
//  WelcomeEmptyStateView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct WelcomeEmptyStateView: View {
    var body: some View {
        VStack {
            ContentUnavailableView(
                "Welcome!",
                systemImage: "keyboard",
                description: Text("Please select a device\nfrom the menu to continue.")
            )
            
            // -> peripheral picker
            PeripheralPickerView("", maxWidth: 200, help: "Devices")
        }
    }
}

#Preview {
    WelcomeEmptyStateView()
}
