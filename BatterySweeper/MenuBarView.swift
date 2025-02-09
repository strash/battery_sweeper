//
//  ContentView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/7/25.
//

import SwiftUI

struct MenuBarView: View {
    let id: UUID = .init()
    
    @Environment(PeripheralViewModel.self) private var viewModel

    var body: some View {
        VStack {
            ForEach(Array(viewModel.peripherals)) { per in
                Text(per.name)
            }
            
            Divider()
            
            Button{
                exit(0)
            } label: {
                Text("Quit Battery Sweeper")
            }
        }
        .padding()
    }
}

#Preview {
    MenuBarView()
}
