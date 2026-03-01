//
//  BatterySwidget.swift
//  BatterySwidget
//
//  Created by Dmitry Poyarkov on 2/20/26.
//

import WidgetKit
import SwiftUI

struct BatterySwidget: Widget {
    let kind: String = "BatterySwidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectPeripheralConfigurationIntent.self,
            provider: PeripheralDetailsProvider()
        ) { entry in
            MainView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Battery Level")
        .description("Displays the current battery level.")
    }
}
