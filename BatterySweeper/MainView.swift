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
    @State private var activePer: UUID?
    
    var body: some View {
        // -> active peripheral
        VStack(alignment: .leading, spacing: 3.0) {
            if let active = viewModel.activePeripheral {
                Group {
                    // -> name
                    Text(active.name)
                        .font(.title)
                        .padding(.bottom)
                    
                    // -> battery levels
                    Text(batteryLevel)
                    
                    // -> model and manufacturer name
                    Text(modelName)
                        .foregroundStyle(.tertiary)
                }
                .contentTransition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItemGroup {
                // -> peripherals
                Picker("Peripherals", selection: $activePer) {
                    ForEach(viewModel.peripherals) { peripheral in
                        Text(peripheral.name).tag(peripheral.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 100)
                .help("Peripherals")
                .onChange(of: activePer) { _, id in
                    if let id {
                        viewModel.connectToPeripheral(with: id)
                    }
                }

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
                .help(isScanOn ? "Stop" : "Scan for peripherals")
            }
        }
        .padding()
        .frame(minWidth: 450.0)
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
