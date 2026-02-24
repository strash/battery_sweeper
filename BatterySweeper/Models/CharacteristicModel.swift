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

extension CBCharacteristic {
    var allFromService: [CBCharacteristic] {
        var characteristics: [CBCharacteristic] = []
        guard let services = self.service?.peripheral?.services else {
            return []
        }
        for service in services {
            if let serviceCharacteristics = service.characteristics {
                characteristics.append(contentsOf: serviceCharacteristics)
            }
        }
        return characteristics
    }
    
    var toValue: ECharacteristic? {
        guard let value = self.value else { return nil }
        var val: ECharacteristic?
        
        switch self.uuid {
        case BTConstants.batteryLevelCharacteristicUUID:
            let data = NSData(data: value)
            val = .batteryLevel(data.bytes.load(as: Int.self))
            
        case BTConstants.manufacturerNameStringCharacteristicUUID:
            let data = String(data: value, encoding: .utf8)
            if let data { val = .manufacturerName(data) }
            
        case BTConstants.modelNumberStringCharacteristicUUID:
            let data = String(data: value, encoding: .utf8)
            if let data { val = .modelNumber(data) }
            
        default:
            val = nil
        }
        
        return val
    }
}
