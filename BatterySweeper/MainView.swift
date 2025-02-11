//
//  MainView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/10/25.
//

import SwiftUI

struct MainView: View {
    @Environment(PeripheralViewModel.self) private var viewModel
    
    private func battery(for peripheral: PeripheralModel) -> [CharacteristicModel.ECharacteristic] {
        var chars: [CharacteristicModel.ECharacteristic] = []
//        for c in peripheral.characteristics {
//            print(c)
//            switch c.characteristic {
//            case .batteryLevel(let value):
//                chars.append(.batteryLevel(value))
//            default: continue
//            }
//        }
        print(chars)
        return chars
    }
    
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
                Button(peripheral.name) {
                    viewModel.connectToPeripheral(peripheral)
                }
            }
            
            HStack {
                ForEach(viewModel.activeCharacteristics) { char in
                    switch char.characteristic {
                    case .batteryLevel(let value):
                        Text("\(value)%")
                    case .manufacturer(let value):
                        Text(value)
                    case .model(let value):
                        Text(value)
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
