//
//  MainViewModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import SwiftUI
import CoreBluetooth

@Observable
class AppViewModel: PObserver {
    private let btService: PBTService
    private var sub: Result<Subscription, SubscriptionError>?
    
    private let model: AppModel
    
    init(btManager: PBTService, subject: EventService, model: AppModel) {
        self.btService = btManager
        self.model = model
        self.sub = subject.subscribe(self)
    }
    
    deinit {
        if case .success(let s) = sub  {
            s.cancel()
        }
    }
    
    func retrieveConnectedPeripherals() -> Void {
        btService.retrieveConnectedPeripherals()
    }
    
    func scanPeripherals() -> Void {
        model.isScanning = true
        btService.retrieveConnectedPeripherals()
        btService.scanPeripherals()
    }
    
    func stopScan() -> Void {
        model.isScanning = false
        btService.stopScan()
    }
    
    func connectToPeripheral(with id: UUID?) -> Void {
        btService.connectToPeripheral(with: id)
    }
    
    func onData(_ event: EEvent) -> Void {
        switch event {
        case .centralStateChanged(let state):
            model.centralState = state
            switch state {
            case .poweredOn:
                retrieveConnectedPeripherals()
                btService.tryToReconnenct()
                model.error = nil
            case _:
                model.peripherals.removeAll()
                model.activePeripheral = nil
            }
            
        case .peripheralDiscovered(let peripheral):
            if !model.peripherals.contains(where: { $0.id == peripheral.identifier }) {
                model.peripherals.append(.init(from: peripheral))
            }
            model.error = nil
            
        case .connectedToPeripheral(let cbPeripheral):
            if let peripheral = model.peripherals.first(where: { $0.id == cbPeripheral.identifier }) {
                model.activePeripheral = peripheral
                model.activeCharacteristics.removeAll()
            }
            model.error = nil
            
        case .failToConnectToPeripheral(_, let error):
            model.activePeripheral = nil
            model.activeCharacteristics.removeAll()
            model.error = error
            
        case .disconnectedFromPeripheral(let cbPeripheral):
            if let activePeripheral = model.activePeripheral, activePeripheral.id == cbPeripheral.identifier {
                model.activePeripheral = nil
                model.activeCharacteristics.removeAll()
            }
            model.error = nil
        
        case .peripheralUpdated(let cbPeripheral):
            model.peripherals = model.peripherals.map {
                $0.id == cbPeripheral.identifier ? .init(from: cbPeripheral) : $0
            }
            if let activePeripheral = model.activePeripheral, activePeripheral.id == cbPeripheral.identifier {
                model.activePeripheral = .init(from: cbPeripheral)
            }
            
        case .characteristicDiscovered(let characteristics):
            model.activeCharacteristics = characteristics.map { .init(from: $0) }
            model.error = nil
            
        }
    }
}

#if DEBUG
extension AppViewModel {
    convenience init() {
        self.init(
            btManager: BTService(with: .init()),
            subject: .init(),
            model: .init()
        )
        model.centralState = .poweredOn
        model.peripherals = [
            .init(id: .init(), name: "Sweep Test"),
            .init(id: .init(), name: "Iaei")
        ]
        model.activePeripheral = .init(id: .init(), name: "Sweep Test")
        model.activeCharacteristics = [
            .init(characteristic: .batteryLevel(54)),
            .init(characteristic: .batteryLevel(25)),
            .init(characteristic: .manufacturerName("ZMK project")),
            .init(characteristic: .modelNumber("Cradio")),
        ]
    }
}
#endif
