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
        Group {
            if let peripheral = viewModel.activePeripheral {
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
                switch (viewModel.centralState == .poweredOn) {
                case true where !viewModel.peripherals.isEmpty:
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
                // -> peripherals
                PeripheralPickerView("Devices", maxWidth: 100, help: "Devices")
                    .disabled(viewModel.centralState != .poweredOn)

                // -> scan
                Button {
                    if viewModel.isScanning {
                        viewModel.scanPeripherals()
                    } else {
                        viewModel.stopScan()
                    }
                    viewModel.isScanning.toggle()
                } label: {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .frame(minWidth: 30, alignment: .center)
                        .symbolEffect(.variableColor, isActive: viewModel.isScanning)
                        .accessibilityLabel(Text(viewModel.isScanning ? "Stop" : "Scan for devices"))
                }
                .help(viewModel.isScanning ? "Stop" : "Scan for devices")
                .disabled(viewModel.centralState != .poweredOn)
            }
        }
        .padding()
        .frame(minWidth: 450.0, idealHeight: 350.0)
    }
    
    private var modelName: String {
        viewModel.activeCharacteristics.filter {
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
}

#if DEBUG
#Preview {
    @Previewable @State var viewModel = PeripheralViewModel()
    
    MainView()
        .environment(viewModel)
}
#endif
