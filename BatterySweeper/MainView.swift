//
//  MainView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/10/25.
//

import SwiftUI

struct MainView: View {
    @Environment(PeripheralViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.scanPeripherals()
            } label: {
                Text("Scan")
            }
            
            Button {
                viewModel.stopScan()
            } label: {
                Text("Stop scan")
            }

            ForEach(viewModel.peripherals) { peripheral in
                Button {
                    viewModel.connectToPeripheral(peripheral)
                } label: {
                    Group {
                        Text(peripheral.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        ForEach(peripheral.sides) { side in
                            switch(side.side) {
                            case .left:
                                Text("L: \(side.battery)%")
                            case .right:
                                Text("R: \(side.battery)%")
                            case .main:
                                Text("\(side.battery)%")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
