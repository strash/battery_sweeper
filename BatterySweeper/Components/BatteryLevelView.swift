//
//  BatteryLevelView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/17/26.
//

import SwiftUI

enum EBatteryLevelSide {
    case left
    case right
    case center
}

struct BatteryLevelView: View {
    @Environment(PeripheralViewModel.self) private var viewModel
    
    var body: some View {
        let batteryLevels = self.batteryLevels
        let totalLevel = max(0, batteryLevels.reduce(0, { $0 + $1 }) / max(1, batteryLevels.count))
        
        let iconPercent = switch (totalLevel) {
        case 76...100: 100
        case 51...75: 75
        case 26...50: 50
        case 5...26: 25
        default: 0
        }
        
        HStack(spacing: 10.0) {
            // -> icon battery
            Image(systemName: "battery.\(iconPercent)percent")
                .font(.title3)
                .symbolRenderingMode(iconPercent > 0 ? .palette : .monochrome)
                .foregroundStyle(iconPercent > 25 ? .green : .red, .secondary)
            
            // -> levels
            if batteryLevels.count == 1 {
                Item(.center, level: 10)
            } else {
                HStack(spacing: 10.0) {
                    ForEach(batteryLevels.indices, id: \.self) { levelIdx in
                        let level = batteryLevels[levelIdx]
                        Item(levelIdx == 0 ? .left : .right, level: level)
                    }
                }
            }
        }
    }
    
    private var batteryLevels: [Int] {
        return viewModel.activeCharacteristics.filter {
            if case .batteryLevel(_) = $0.characteristic { return true }
            return false
        }.map {
            if case .batteryLevel(let value) = $0.characteristic { return value }
            return 0
        }
    }
}

private struct Item: View {
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

#Preview {
    BatteryLevelView()
}
