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
                get: { model.activePeripheralID },
                set: { value in
                    withAnimation {
                        model.activePeripheralID = value
                    }
                }
            )
            
            Picker(label, selection: binding) {
                Text("").tag(nil as UUID?)
                ForEach(model.peripherals.sorted(by: { $0.name < $1.name }), id: \.id ) { peripheral in
                    Text(peripheral.name)
                        .tag(peripheral.id)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: maxWidth)
            .fontDesign(.rounded)
            .help(help)
        }
    }
}
