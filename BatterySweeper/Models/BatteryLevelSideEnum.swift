//
//  BatteryLevelSideEnum.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/20/26.
//

import Foundation

enum EBatteryLevelSide {
    case left
    case right
    case center
    case other
    
    /// Side system icon
    var sideIcon: String {
        get {
            let letter = switch self {
            case .center: "c"
            case .left: "l"
            case .right: "r"
            case .other: "o"
            }
            return "\(letter).circle.fill"
        }
    }
    
    /// For cases when there is more than one characeristic
    static func from(index: Int) -> EBatteryLevelSide {
        return switch index {
        case 0: .left
        case 1: .right
        default: .other
        }
    }
    
    /// Battery level system icon and its percentage (0, 25, 50, 75, 100)
    static func levelIcon(from totalLevel: Int) -> (Int, String) {
        let percent = switch totalLevel {
        case 76...100: 100
        case 51...75: 75
        case 26...50: 50
        case 5...26: 25
        default: 0
        }
        return (percent, "battery.\(percent)percent")
    }
}
