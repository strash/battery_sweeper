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
    private let btManager: PBTManager
    @State private var peripheralViewModel: PeripheralViewModel
    
    init() {
        btManager = BTManager.init(with: subject)
        peripheralViewModel = .init(btManager: btManager, subject: subject)
    }
    
    private var icon: String {
        get {
            if peripheralViewModel.centralState == .poweredOn {
                if peripheralViewModel.activePeripheral != nil {
                    return "minus.plus.batteryblock.fill"
                }
                return "minus.plus.batteryblock"
            }
            return "batteryblock.slash"
        }
    }
    
    var body: some Scene {
        Window("Battery Sweeper", id: "main") {
            MainView()
                .environment(peripheralViewModel)
        }
        .windowResizability(.contentMinSize)
        .windowToolbarLabelStyle(fixed: .automatic)

        MenuBarExtra("Battery Sweeper", systemImage: icon) {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
