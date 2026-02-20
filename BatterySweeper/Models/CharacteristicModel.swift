//
//  Characteristic.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/18/26.
//

import Foundation

struct CharacteristicModel: Identifiable, Equatable {
    let id: UUID = .init()
    var characteristic: EBTCharacteristic
    
    init(characteristic: EBTCharacteristic) {
        self.characteristic = characteristic
    }
    
    init(from characteristic: BTCharacteristicDto) {
        switch characteristic.value {
        case .batteryLevel(let value):
            self.characteristic = .batteryLevel(value)
        case .manufacturerName(let value):
            self.characteristic = .manufacturerName(value)
        case .modelNumber(let value):
            self.characteristic = .modelNumber(value)
        }
    }
    
    static func ==(lhs: CharacteristicModel, rhs: CharacteristicModel) -> Bool {
        lhs.id == rhs.id && lhs.characteristic == rhs.characteristic
    }
}

extension [CharacteristicModel] {
    /// Filter battery levels
    var batteryLevels: [Int] {
        return self.filter {
            if case .batteryLevel(_) = $0.characteristic { return true }
            return false
        }.map {
            if case .batteryLevel(let value) = $0.characteristic { return value }
            return 0
        }
    }
    
    /// Model name
    var modelName: String {
        self.filter {
            if case .batteryLevel(_) = $0.characteristic { return false }
            return true
        }.map {
            switch $0.characteristic {
            case .manufacturerName(let value), .modelNumber(let value):
                return value
            default:
                return ""
            }
        }.joined(separator: " • ")
    }
}
