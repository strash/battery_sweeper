//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth

struct CharacteristicModel: Identifiable, Equatable {
    enum ECharacteristic {
        case batteryLevel(Int)
        case manufacturer(String)
        case model(String)
    }

    let id: UUID = .init()
    var characteristic: ECharacteristic
    
    init(characteristic: ECharacteristic) {
        self.characteristic = characteristic
    }
    
    init(from characteristic: BTCharacteristic) {
        switch characteristic.value {
        case .batteryLevel(let value):
            self.characteristic = .batteryLevel(value)
        case .manufacturerName(let value):
            self.characteristic = .manufacturer(value)
        case .modelNumber(let value):
            self.characteristic = .model(value)
        }
    }
    
    static func ==(lhs: CharacteristicModel, rhs: CharacteristicModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct PeripheralModel: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var inOn: Bool
    
    init(id: UUID, name: String, isOn: Bool) {
        self.id = id
        self.name = name
        self.inOn = isOn
    }
    
    init(from peripheral: CBPeripheral) {
        self.init(
            id: peripheral.identifier,
            name: peripheral.name ?? "--",
            isOn: false
        )
    }
    
    func copyWith(name: String? = nil, isOn: Bool = false) -> PeripheralModel {
        .init(
            id: id,
            name: name ?? self.name,
            isOn: isOn
        )
    }
    
    static func ==(lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id
    }
}
