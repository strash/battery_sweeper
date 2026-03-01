//
//  CBCharacteristicsExtension.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 3/1/26.
//

import Foundation
import CoreBluetooth

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
