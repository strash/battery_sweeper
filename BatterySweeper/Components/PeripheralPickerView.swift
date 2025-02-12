//
//  PeripheralPickerView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct PeripheralPickerView: View {
    @Environment(PeripheralViewModel.self) private var viewModel

    let label: String
    let maxWidth: Double
    let help: String
    
    init(_ label: String, maxWidth: Double, help: String) {
        self.label = label
        self.maxWidth = maxWidth
        self.help = help
    }
    
    var body: some View {
        let activePeripheral = Binding(
            get: { viewModel.activePeripheral },
            set: {
                viewModel.activePeripheral = $0
                if let peripheral = $0 {
                    viewModel.connectToPeripheral(with: peripheral.id)
                }
            }
        )
        
        Picker(label, selection: activePeripheral) {
            ForEach(viewModel.peripherals) { peripheral in
                Text(peripheral.name).tag(Optional(peripheral))
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: maxWidth)
        .help(help)
    }
}

#Preview {
    PeripheralPickerView("Label", maxWidth: 200, help: "Devices")
}
