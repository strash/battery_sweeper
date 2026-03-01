//
//  PeripheralDetailsProvider.swift
//  BatterySwidgetExtension
//
//  Created by Dmitry Poyarkov on 2/22/26.
//

import Foundation
import WidgetKit
import AppIntents

struct PeripheralDetailsProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectPeripheralConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        let entry = WidgedEntry(
            date: Date(),
            peripheral: configuration.peripheral,
            family: context.family
        )
        return Timeline(entries: [entry], policy: .never)
    }
    
    func snapshot(for configuration: SelectPeripheralConfigurationIntent, in context: Context) async -> WidgedEntry {
        .init(
            date: Date(),
            peripheral: configuration.peripheral ?? .init(id: .init(), name: "Keyboard", characteristics: [
                .init(.batteryLevel(55)),
                .init(.batteryLevel(65)),
                .init(.manufacturerName("Apple")),
                .init(.modelNumber("Magic Keyboard"))
            ]),
            family: context.family
        )
    }

    func placeholder(in context: Context) -> WidgedEntry {
        .init(
            date: Date(),
            peripheral: .init(id: .init(), name: "Keyboard", characteristics: [
                .init(.batteryLevel(55)),
                .init(.batteryLevel(65)),
                .init(.manufacturerName("Apple")),
                .init(.modelNumber("Magic Keyboard"))
            ]),
            family: context.family
        )
    }
}
