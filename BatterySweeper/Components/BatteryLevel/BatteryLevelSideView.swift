//
//  BatteryLevelSideView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import SwiftUI

enum EBatteryLevelSide {
    case left
    case right
    case center
}

struct BatteryLevelSideView: View {
    let side: EBatteryLevelSide
    let level: Int
    
    init(_ side: EBatteryLevelSide, level: Int) {
        self.side = side
        self.level = level
    }
    
    var body: some View {
        HStack(spacing: 3.0) {
            let iconSide = switch(side) {
            case .center: "m"
            case .left: "l"
            case .right: "r"
            }
            
            if side != .center {
                Image(systemName: "\(iconSide).circle.fill")
                    .foregroundStyle(.secondary)
            }
            
            Text("\(level)%")
                .fontWeight(.medium)
        }
    }
}
