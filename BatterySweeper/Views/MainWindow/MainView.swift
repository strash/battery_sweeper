//
//  MainView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/10/25.
//

import SwiftUI

struct MainView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(AppModel.self) private var model
    
    var body: some View {
        Group {
            if let peripheral = model.activePeripheral {
                // -> active peripheral
                VStack(alignment: .center, spacing: 5.0) {
                    // -> name
                    Text(peripheral.name)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                    
                    // -> model and manufacturer name
                    Text(model.activeCharacteristics.modelName)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                        .fontDesign(.rounded)

                    // -> battery levels
                    BatteryLevelView()
                }
            } else {
                // -> empty state
                switch model.centralState == .poweredOn {
                case true where !model.peripherals.isEmpty:
                    WelcomeEmptyStateView()
                case false:
                    PowerOffEmptyStateView()
                default:
                    RefreshPeripheralsEmptyStateView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        .toolbar {
            ToolbarItemGroup {
                // -> peripheral select
                if model.activePeripheral != nil {
                    PeripheralPickerView("Devices", maxWidth: 130, help: "Devices")
                        .disabled(model.centralState != .poweredOn)
                }

                // -> button scan
                Button {
                    if model.isScanning {
                        viewModel.scanPeripherals()
                    } else {
                        viewModel.stopScan()
                    }
                    model.isScanning.toggle()
                } label: {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .frame(minWidth: 30, alignment: .center)
                        .symbolEffect(.variableColor, isActive: model.isScanning)
                        .accessibilityLabel(Text(model.isScanning ? "Stop" : "Scan for devices"))
                }
                .help(model.isScanning ? "Stop" : "Scan for devices")
                .disabled(model.centralState != .poweredOn)
            }
        }
        .padding()
        .frame(minWidth: 450.0, idealHeight: 350.0)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model = AppModel(
        .poweredOn,
        peripherals: [.init(id: .init(), name: "Sweep Test")],
        activePeripheral: .init(id: .init(), name: "Sweep Test"),
        activeCharacteristics: [
            .init(characteristic: .batteryLevel(54)),
            .init(characteristic: .batteryLevel(25)),
            .init(characteristic: .manufacturerName("ZMK project")),
            .init(characteristic: .modelNumber("Cradio")),
        ]
    )
    @Previewable @State var viewModel = AppViewModel()
    
    MainView()
        .environment(viewModel)
        .environment(model)
}
#endif
