//
//  Events.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation
import CoreBluetooth

enum EEvent {
    case centralStateChanged(CBManagerState)
    case peripheralDiscovered(CBPeripheral)
    case connectedToPeripheral(CBPeripheral)
    case failToConnectToPeripheral(CBPeripheral, (any Error)?)
    case disconnectedFromPeripheral(CBPeripheral)
    case peripheralUpdated(CBPeripheral)
    case characteristicDiscovered([BTCharacteristicDto])
}
