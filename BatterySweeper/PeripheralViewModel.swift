//
//  PeripheralViewModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import Foundation
import Observation
import CoreBluetooth
import SwiftUI

@Observable
class PeripheralViewModel: PObserver {
    private var sub: Optional<Result<Subscription, SubscriptionError>> = .none
    
    var centralState: CBManagerState = .unknown
    var peripherals: [PeripheralModel] = []
    var activePeripheral: PeripheralModel? = nil
    
    @ObservationIgnored private var btManager: PBTManager
    
    init(btManager: PBTManager, subject: Subject) {
        self.btManager = btManager
        subscribe(subject: subject)
    }
    
    deinit {
        if case .success(let s) = sub  {
            s.cancel()
        }
    }
    
    private func subscribe(subject: Subject) -> Void {
        sub = subject.subscribe(self)
    }
    
    func retrieveConnectedPeripherals() -> Void {
        btManager.retrieveConnectedPeripherals()
    }
    
    func scanPeripherals() -> Void {
        btManager.scanPeripherals()
    }
    
    func stopScan() -> Void {
        btManager.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: PeripheralModel) -> Void {
        btManager.connectToPeripheral(with: peripheral.id)
    }
    
    func onData(_ event: EEvent) -> Void {
        switch event {
        case .centralStateChanged(let state):
            centralState = state
            switch state {
            case .poweredOn:
                retrieveConnectedPeripherals()
            case _:
                break;
            }
        case .peripheralDiscovered(let peripheral):
            guard !peripherals.contains(where: { $0.id == peripheral.identifier }) else {
                break
            }
            print("discovered:", peripheral)
            peripherals.append(.init(from: peripheral, sides: [
                .init(id: ESide.main.hashValue, side: .main, battery: 0)
            ]))
        case .connectedToPeripheral(let cbPeripheral):
            guard let peripheral = peripherals.first(where: { $0.id == cbPeripheral.identifier }) else {
                break
            }
            print("connected to:", peripheral)
            activePeripheral = peripheral
        case .disconnectedFromPeripheral(let cbPeripheral):
            guard activePeripheral?.id == cbPeripheral.identifier else {
                break
            }
            activePeripheral = nil
        }
    }
}
