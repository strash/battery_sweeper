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
                    model.activePeripheral = nil
                }
                
            case .peripheralsDiscovered(let peripherals):
                for e in peripherals {
                    if !model.peripherals
                        .contains(where: { $0.id == e.identifier }) {
                        model.peripherals.append(.init(from: e))
                    }
                }
                model.error = nil
                
            case .connectedToPeripheral(let cbPeripheral):
                if let peripheral = model.peripherals
                    .first(where: { $0.id == cbPeripheral.identifier }) {
                    model.activePeripheral = peripheral
                }
                model.error = nil
                
            case .failToConnectToPeripheral(let cbPeripheral, let error):
                if let peripheral = model.activePeripheral,
                   peripheral.id == cbPeripheral.identifier {
                    model.activePeripheral = nil
                }
                model.error = error
                
            case .disconnectedFromPeripheral(let cbPeripheral):
                if let peripheral = model.activePeripheral,
                   peripheral.id == cbPeripheral.identifier {
                    model.activePeripheral = nil
                }
                model.error = nil
                
            case .peripheralUpdated(let cbPeripheral):
                model.peripherals = model.peripherals.map {
                    $0.id == cbPeripheral.identifier
                    ? $0.copyWith(name: cbPeripheral.name, characteristics: nil)
                    : $0
                }
                if let active = model.activePeripheral,
                   active.id == cbPeripheral.identifier,
                   let peripheral = model.peripherals.first(where: { $0.id == active.id }){
                    model.activePeripheral = peripheral
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
                if let active = model.activePeripheral,
                   active.id == cbPeripheral.identifier,
                   let peripheral = model.peripherals.first(where: { $0.id == active.id }){
                    //                model.activePeripheral = nil
                    model.activePeripheral = peripheral
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
        model.activePeripheral = peripheral
    }
}
#endif
