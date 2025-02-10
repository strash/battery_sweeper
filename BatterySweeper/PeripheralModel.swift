//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import Foundation
import CoreBluetooth

enum ESide: Equatable {
    case left, right
    case unknown
}

struct PeripheralModel: Identifiable, Equatable {
    var id: String
    var name: String
    var side: ESide
    var battery: Int
    
    init(from peripheral: CBPeripheral, side: ESide) {
        id = peripheral.identifier.uuidString
        name = peripheral.name ?? "--"
        self.side = side
        battery = 0
    }
    
    static func ==(lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id
    }
}
