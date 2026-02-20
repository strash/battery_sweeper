//
//  App.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/7/25.
//

import SwiftUI

let kMainWindowID: String = "main_window"

@main
struct BatterySweeperApp: App {
    private let subject: EventService = .init()
    private var viewModel: AppViewModel
    @State private var model: AppModel
    
    
    init() {
        let model: AppModel = .init()
        self.viewModel = .init(
            btManager: BTService.init(with: subject),
            subject: subject,
            model: model
        )
        self.model = model
    }
    
    private var icon: String {
        get {
            if model.centralState == .poweredOn {
                if model.activePeripheral != nil {
                    return "minus.plus.batteryblock.fill"
                }
                return "minus.plus.batteryblock"
            }
            return "batteryblock.slash"
        }
    }
    
    var body: some Scene {
        Window("Battery Sweeper", id: kMainWindowID) {
            MainView()
                .environment(viewModel)
                .environment(model)
                .frame(minWidth: 200, minHeight: 100)
                .onAppear {
#if !DEBUG
                    NSApplication.shared.activate(ignoringOtherApps: true)
#endif
                }
        }
        .windowResizability(.contentMinSize)
        .windowToolbarLabelStyle(fixed: .automatic)

        MenuBarExtra("Battery Sweeper", systemImage: icon) {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
