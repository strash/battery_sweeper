//
//  ContentView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/7/25.
//

import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button("Open Battery Sweeper") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: kMainWindowID)
            }

            Divider()
            
            Button("Quit") {
                exit(0)
            }
        }
    }
}

#Preview {
    MenuBarView()
}
