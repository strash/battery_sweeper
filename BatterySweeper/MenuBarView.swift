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
        VStack(alignment: .leading) {
            ForEach(viewModel.peripherals) { peripheral in
                Button {
                    viewModel.selectPeripheral(peripheral)
                } label: {
                    Text(peripheral.name)
                        .foregroundStyle(
                            viewModel.activePeripheral == peripheral ? .primary : .secondary
                        )
                }
            }
            
            // TODO: refresh list

            Divider()
            
            Button{
                exit(0)
            } label: {
                Text("Quit Battery Sweeper")
            }
        }
    }
}

#Preview {
    MenuBarView()
}
