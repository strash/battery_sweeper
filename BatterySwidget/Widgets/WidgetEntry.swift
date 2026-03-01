//
//  WidgetEntry.swift
//  BatterySwidgetExtension
//
//  Created by Dmitry Poyarkov on 2/20/26.
//

import Foundation
import WidgetKit

struct WidgedEntry: TimelineEntry {
    let date: Date
    let peripheral: PeripheralModel?
    let family: WidgetFamily
}
