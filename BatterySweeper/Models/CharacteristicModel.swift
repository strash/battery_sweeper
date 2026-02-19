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

