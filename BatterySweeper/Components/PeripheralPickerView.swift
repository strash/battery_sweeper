//
//  PeripheralPickerView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/12/25.
//

import SwiftUI

struct PeripheralPickerView: View {
    @Environment(PeripheralViewModel.self) private var viewModel
    @Binding var selection: UUID?
    
    let label: String
    let maxWidth: Double
    let help: String
    
    init(_ label: String, selection: Binding<UUID?>, maxWidth: Double, help: String) {
        self._selection = selection
        self.label = label
        self.maxWidth = maxWidth
        self.help = help
    }
    
    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(viewModel.peripherals) { peripheral in
                Text(peripheral.name).tag(Optional(peripheral.id))
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: maxWidth)
        .help(help)
    }
}

#Preview {
    @Previewable @State var bind: UUID?
    
    PeripheralPickerView("Label", selection: $bind, maxWidth: 200, help: "Devices")
}
