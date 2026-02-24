//
//  WidgetView.swift
//  BatterySwidgetExtension
//
//  Created by Dmitry Poyarkov on 2/20/26.
//

import SwiftUI

struct MainView: View {
    var entry: PeripheralDetailsProvider.Entry
    
    var body: some View {
        if let peripheral = entry.peripheral {
            // -> active peripheral
            VStack(alignment: .leading, spacing: 5.0) {
                // -> name
                Text(peripheral.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                
                // -> model and manufacturer name
                if let characteristics = entry.characteristics {
                    Text(characteristics.modelName)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                        .fontDesign(.rounded)
                }
                
                // -> battery levels
                BatteryLevelView(entry: entry)
            }
        } else {
            // -> empty state
            Text("yayaya")
//            switch model.centralState == .poweredOn {
//            case true where !model.peripherals.isEmpty:
//                WelcomeEmptyStateView()
//            case false:
//                PowerOffEmptyStateView()
//            default:
//                RefreshPeripheralsEmptyStateView()
//            }
        }
    }
}
