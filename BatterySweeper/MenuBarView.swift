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
            Button {
                openWindow(id: "main")
            } label: {
                Text("Open Battery Sweeper")
            }

            Divider()
            
            Button {
                exit(0)
            } label: {
                Text("Quit")
            }
        }
    }
}

#Preview {
    MenuBarView()
}
