//
//  CharacteristicValueEnum.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/24/26.
//

import Foundation

enum ECharacteristic: Codable, Equatable {
    case batteryLevel(Int)
    case manufacturerName(String)
    case modelNumber(String)
}
