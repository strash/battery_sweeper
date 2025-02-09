//
//  BatterySweeperApp.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/7/25.
//

import SwiftUI

@main
struct BatterySweeperApp: App {
    private let subject: Subject = .init()
    private let btManager: BTManager
    @State private var peripheralViewModel: PeripheralViewModel
    
    init() {
        btManager = .init(with: subject)
        peripheralViewModel = .init(btManager: btManager, subject: subject)
    }
    
    var body: some Scene {
        MenuBarExtra(
            "Battery Sweeper",
            systemImage: peripheralViewModel.centralState == .poweredOn
            ? "minus.plus.batteryblock.fill"
            : "batteryblock.slash"
        ) {
            MenuBarView()
                .environment(peripheralViewModel)
        }
        .menuBarExtraStyle(.menu)
    }
}
