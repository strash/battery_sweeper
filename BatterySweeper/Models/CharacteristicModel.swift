//
//  Characteristic.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/18/26.
//

import Foundation
import CoreBluetooth

struct CharacteristicModel: Codable, Equatable {
    let value: ECharacteristic
    
    init(_ characteristic: ECharacteristic) {
        self.value = characteristic
    }
}

extension [CharacteristicModel] {
    /// Filter battery levels
    var batteryLevels: [Int] {
        self.filter {
            if case .batteryLevel(_) = $0.value { return true }
            return false
        }.map {
            if case .batteryLevel(let value) = $0.value { return value }
            return 0
        }
    }
    
    /// Model name
    var modelName: String {
        self.filter {
            if case .batteryLevel(_) = $0.value { return false }
            return true
        }.map {
            switch $0.value {
            case .manufacturerName(let value), .modelNumber(let value):
                return value
            default:
                return ""
            }
        }.joined(separator: " • ")
    }
}

