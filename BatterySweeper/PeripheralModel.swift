//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth

struct CharacteristicModel: Identifiable, Equatable {
    let id: UUID = .init()
    var characteristic: EBTCharacteristic
    
    init(characteristic: EBTCharacteristic) {
        self.characteristic = characteristic
    }
    
    init(from characteristic: BTCharacteristic) {
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
