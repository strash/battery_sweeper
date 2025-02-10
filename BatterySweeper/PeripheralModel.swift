//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import Foundation
import CoreBluetooth

enum ESide: Equatable, CaseIterable {
    case left, right
    case main
}

struct PeripheralSideModel: Identifiable, Equatable {
    var id: Int
    var side: ESide
    var battery: Int
    
    static func ==(lhs: PeripheralSideModel, rhs: PeripheralSideModel) -> Bool {
        lhs.side == rhs.side
    }
}

struct PeripheralModel: Identifiable, Equatable {
    var id: UUID
    var name: String
    var sides: [PeripheralSideModel]
    
    init(from peripheral: CBPeripheral, sides: [PeripheralSideModel]) {
        id = peripheral.identifier
        name = peripheral.name ?? "--"
        self.sides = sides
    }
    
    static func ==(lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id
    }
}
