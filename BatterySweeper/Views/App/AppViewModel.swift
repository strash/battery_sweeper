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
    let id = UUID()
    private let btService: PBTService
    private var sub: Result<Subscription, SubscriptionError>?
    
    private let model: AppModel
    
    init(btManager: PBTService, subject: EventService, model: AppModel) {
        self.btService = btManager
        self.model = model
        self.sub = subject.subscribe(self)
    }
    
    deinit {
        if case .success(let s) = sub { s.cancel() }
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
        withAnimation {
            switch event {
            case .centralStateChanged(let state):
                model.centralState = state
                switch state {
                case .poweredOn:
                    btService.restoreConnection()
                    model.error = nil
                case _:
                    model.peripherals.removeAll()
                    model.activePeripheralID = nil
                }
                
            case .peripheralsDiscovered(let peripherals):
                model.peripherals = peripherals.map { .init(from: $0) }
                model.error = nil
                
            case .connectedToPeripheral(let cbPeripheral):
                if let peripheral = model.peripheral(by: cbPeripheral.identifier) {
                    model.activePeripheralID = peripheral.id
                }
                stopScan()
                model.error = nil
                
            case .failToConnectToPeripheral(let cbPeripheral, let error):
                if model.activePeripheralID == cbPeripheral.identifier {
                    model.activePeripheralID = nil
                }
                retrieveConnectedPeripherals()
                model.error = error
                
            case .disconnectedFromPeripheral(let cbPeripheral):
                if model.activePeripheralID == cbPeripheral.identifier {
                    model.activePeripheralID = nil
                }
                retrieveConnectedPeripherals()
                model.error = nil
                
            case .peripheralUpdated(let cbPeripheral):
                model.peripherals = model.peripherals.map {
                    $0.id == cbPeripheral.identifier
                    ? $0.copyWith(name: cbPeripheral.name, characteristics: nil)
                    : $0
                }
                model.error = nil
                
            case .characteristicsDiscovered(let cbPeripheral, let characteristics):
                model.peripherals = model.peripherals.map {
                    $0.id == cbPeripheral.identifier
                    ? $0.copyWith(name: nil, characteristics: characteristics.map {
                        .init($0)
                    })
                    : $0
                }
                model.error = nil
            }
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
        let peripheral: PeripheralModel = .init(
            id: .init(),
            name: "Sweep Test",
            characteristics: [
                .init(.batteryLevel(54)),
                .init(.batteryLevel(25)),
                .init(.manufacturerName("ZMK project")),
                .init(.modelNumber("Cradio")),
            ]
        )
        model.centralState = .poweredOn
        model.peripherals = [
            peripheral,
            .init(id: .init(), name: "Iaei")
        ]
        model.activePeripheralID = peripheral.id
    }
}
#endif
