//
//  BTCharacteristicDto.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/18/26.
//

import Foundation

enum EBTCharacteristic: Equatable {
    case batteryLevel(Int)
    case manufacturerName(String)
    case modelNumber(String)
}

struct BTCharacteristicDto: Identifiable {
    var id: UUID
    var value: EBTCharacteristic
}
