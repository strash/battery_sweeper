//
//  BatteryLevelSideView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import SwiftUI

struct BatteryLevelSideView: View {
    let side: EBatteryLevelSide
    let level: Int
    
    init(_ side: EBatteryLevelSide, level: Int) {
        self.side = side
        self.level = level
    }
    
    var body: some View {
        HStack(spacing: 3.0) {
            // -> icon
            Image(systemName: side.sideIcon)
                .foregroundStyle(.secondary)
            
            // -> level
            Text("\(level)%")
                .fontWeight(.medium)
        }
        .fontDesign(.rounded)
    }
}
