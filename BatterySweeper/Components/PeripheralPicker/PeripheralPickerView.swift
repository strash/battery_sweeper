//
//  PeripheralPickerView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct PeripheralPickerView: View {
    @Environment(AppModel.self) private var model
    @Environment(AppViewModel.self) private var viewModel
    
    let label: String
    let maxWidth: Double
    let help: String
    
    init(_ label: String, maxWidth: Double, help: String) {
        self.label = label
        self.maxWidth = maxWidth
        self.help = help
    }
    
    var body: some View {
        if !model.peripherals.isEmpty {
            let binding = Binding(
                get: { model.activePeripheral },
                set: { value in
                    model.activePeripheral = value
                    viewModel.connectToPeripheral(with: value?.id)
                }
            )
            
            Picker(label, selection: binding) {
                Text("").tag(nil as PeripheralModel?)
                ForEach(model.peripherals, id: \.id) { peripheral in
                    Text(peripheral.name)
                        .tag(peripheral)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: maxWidth)
            .help(help)
        }
    }
}

//#Preview {
//    PeripheralPickerView("Label", maxWidth: 200, help: "Devices")
//}
