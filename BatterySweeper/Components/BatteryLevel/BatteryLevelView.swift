//
//  BatteryLevelView.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/17/26.
//

import SwiftUI

struct BatteryLevelView: View {
    @Environment(AppModel.self) private var model
    
    var body: some View {
        let batteryLevels = model.activeCharacteristics.batteryLevels
        let totalLevel = max(0, batteryLevels.reduce(0, { $0 + $1 }) / max(1, batteryLevels.count))
        let (percent, icon) = EBatteryLevelSide.levelIcon(from: totalLevel)
        
        HStack(spacing: 10.0) {
            // -> icon battery
            Image(systemName: icon)
                .font(.title3)
                .symbolRenderingMode(percent > 0 ? .palette : .monochrome)
                .foregroundStyle(percent > 25 ? .green : .red, .secondary)

            // -> levels
            if batteryLevels.count == 1 {
                BatteryLevelSideView(.center, level: batteryLevels.first!)
            } else {
                HStack(spacing: 10.0) {
                    ForEach(batteryLevels.indices, id: \.self) { levelIdx in
                        let level = batteryLevels[levelIdx]
                        let side = EBatteryLevelSide.from(index: levelIdx)
                        BatteryLevelSideView(side, level: level)
                    }
                }
            }
        }
    }
}

#Preview {
    BatteryLevelView()
}
