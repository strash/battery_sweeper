//
//  SelectPeripheralConfigurationIntent.swift
//  BatterySwidgetExtension
//
//  Created by Dmitry Poyarkov on 2/22/26.
//

import Foundation
import AppIntents

struct SelectPeripheralConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select device"
    static var description: IntentDescription = .init("Selects the device to display battery level for.")

    @Parameter(title: "Device")
    var peripheral: PeripheralModel?
    
    init(peripheral: PeripheralModel) {
        self.peripheral = peripheral
    }
    
    init() {}
}
