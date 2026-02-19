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
    
    private var modelName: String {
        model.activeCharacteristics.filter {
            if case .batteryLevel(_) = $0.characteristic { return false }
            return true
        }.map {
            switch $0.characteristic {
            case .manufacturerName(let value), .modelNumber(let value):
                return value
            default:
                return ""
            }
        }.joined(separator: " • ")
    }

    var body: some View {
        Group {
            if let peripheral = model.activePeripheral {
                // -> active peripheral
                VStack(alignment: .center, spacing: 3.0) {
                    // -> name
                    Text(peripheral.name)
                        .font(.title)
                        .fontWeight(.medium)
                    
                    // -> model and manufacturer name
                    Text(modelName)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)

                    // -> battery levels
                    BatteryLevelView()
                }
            } else {
                // -> empty state
                switch (model.centralState == .poweredOn) {
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
                    PeripheralPickerView("Devices", maxWidth: 100, help: "Devices")
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
    @Previewable @State var viewModel = AppViewModel()
    
    MainView()
        .environment(viewModel)
}
#endif
