//
//  MainView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/10/25.
//

import SwiftUI

struct MainView: View {
    @Environment(PeripheralViewModel.self) private var viewModel
    @State private var isScanOn = false
    @State private var activePeripheral: UUID? = nil
    
    // TODO: show errors
    var body: some View {
        Group {
            if let active = viewModel.activePeripheral {
                // -> active peripheral
                VStack(alignment: .leading, spacing: 3.0) {
                    // -> name
                    Text(active.name)
                        .font(.title)
                        .fontWeight(.medium)
                    
                    // -> model and manufacturer name
                    Text(modelName)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)

                    // -> battery levels
                    Text(batteryLevel)
                        .fontWeight(.medium)
                }
                .contentTransition(.opacity)
            } else {
                // -> empty state
                VStack {
                    ContentUnavailableView(
                        "Welcome!",
                        systemImage: "keyboard",
                        description: Text("Please select a device\nfrom the menu to continue.")
                    )
                    // -> peripherals
                    PeripheralPickerView(
                        "",
                        selection: $activePeripheral,
                        maxWidth: 200,
                        help: "Devices")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        .toolbar {
            ToolbarItemGroup {
                // -> peripherals
                PeripheralPickerView(
                    "Devices",
                    selection: $activePeripheral,
                    maxWidth: 100,
                    help: "Devices")

                // -> scan
                Button {
                    if isScanOn {
                        viewModel.scanPeripherals()
                    } else {
                        viewModel.stopScan()
                    }
                    isScanOn.toggle()
                } label: {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .frame(minWidth: 30, alignment: .center)
                        .symbolEffect(.variableColor, isActive: isScanOn)
                }
                .help(isScanOn ? "Stop" : "Scan for devices")
            }
        }
        .padding()
        .frame(minWidth: 450.0, idealHeight: 350.0)
        
        .onChange(of: activePeripheral) { _, id in
            if let id {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.connectToPeripheral(with: id)
                }
            }
        }
        
        .onChange(of: viewModel.centralState) {
            if viewModel.centralState != .poweredOn {
                activePeripheral = nil
            }
        }
        .onChange(of: viewModel.activePeripheral) {
            if viewModel.activePeripheral == nil {
                activePeripheral = nil
            }
        }
        .onChange(of: viewModel.peripherals) {
            if viewModel.peripherals.isEmpty {
                activePeripheral = nil
            }
        }
    }
    
    private var batteryLevel: String {
        let chars: [Int] = viewModel.activeCharacteristics.filter {
            if case .batteryLevel(_) = $0.characteristic { return true }
            return false
        }.map {
            if case .batteryLevel(let value) = $0.characteristic { return value }
            return 0
        }
        if chars.count == 2 {
            return chars.enumerated().reduce("", { prev, curr in
                if curr.0 == 0 { return "L: \(curr.1)%" }
                return "\(prev) R: \(curr.1)%"
            })
        }
        return chars.map { "\($0)%" }.joined(separator: " ")
    }
    
    private var modelName: String {
        viewModel.activeCharacteristics.filter {
            if case .batteryLevel(_) = $0.characteristic { return false }
            return true
        }.map {
            switch $0.characteristic {
            case .manufacturer(let value), .model(let value):
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
