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
    
    private let subject: EventService = .init()
    private let model: AppModel = .init()
    private let viewModel: AppViewModel
    
    
    init() {
        self.viewModel = .init(
            btManager: BTService.init(with: subject),
            subject: self.subject,
            model: self.model
        )
    }

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
