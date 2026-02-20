//
//  AppModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation
import CoreBluetooth
import SwiftUI

@Observable
class AppModel {
    var centralState: CBManagerState = .unknown
    var peripherals: [PeripheralModel] = []
    
    var activePeripheral: PeripheralModel? = nil
    var activeCharacteristics: [CharacteristicModel] = []
    
    var isScanning: Bool = false
    
    var error: (any Error)? = nil
}

#if DEBUG
extension AppModel {
    convenience init(_ state: CBManagerState, peripherals: [PeripheralModel], activePeripheral: PeripheralModel, activeCharacteristics: [CharacteristicModel]) {
        self.init()
        self.centralState = state
        self.peripherals = peripherals
        self.activePeripheral = activePeripheral
        self.activeCharacteristics = activeCharacteristics
    }
}
#endif
