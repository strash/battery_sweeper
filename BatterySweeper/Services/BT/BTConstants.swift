//
//  BTConstants.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/22/26.
//

import Foundation
import CoreBluetooth

struct BTConstants {
    static private let BATTERY_SERVICE_UUID = "0x180F"
    static private let DEVICE_INFORLATION_SERVICE_UUID = "0x180A"
    static private let BATTERY_LEVEL_CHARACTERISTIC_UUID = "0x2A19"
    static private let MODEL_NUMBER_STRING_CHARACTERISTIC_UUID = "0x2A24"
    static private let MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID = "0x2A29"
    
    static let batteryServiceUUID = CBUUID(string: BATTERY_SERVICE_UUID)
    static let deviceInformationServiceUUID = CBUUID(string: DEVICE_INFORLATION_SERVICE_UUID)
    static let batteryLevelCharacteristicUUID = CBUUID(
        string: BATTERY_LEVEL_CHARACTERISTIC_UUID)
    static let modelNumberStringCharacteristicUUID = CBUUID(
        string: MODEL_NUMBER_STRING_CHARACTERISTIC_UUID)
    static let manufacturerNameStringCharacteristicUUID = CBUUID(
        string: MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID)
}
