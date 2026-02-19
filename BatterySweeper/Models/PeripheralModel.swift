//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth

struct PeripheralModel: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from peripheral: CBPeripheral) {
        self.init(id: peripheral.identifier, name: peripheral.name ?? "--")
    }
    
    func copyWith(name: String? = nil) -> PeripheralModel {
        .init(id: id, name: name ?? self.name)
    }
    
    static func ==(lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
