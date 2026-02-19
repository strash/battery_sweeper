//
//  BTServiceProtocol.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation

protocol PBTService {
    func retrieveConnectedPeripherals() -> Void
    func scanPeripherals() -> Void
    func stopScan() -> Void
    func connectToPeripheral(with uuid: UUID?) -> Void
    func tryToReconnenct() -> Void
}
