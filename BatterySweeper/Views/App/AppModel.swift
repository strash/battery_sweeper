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
