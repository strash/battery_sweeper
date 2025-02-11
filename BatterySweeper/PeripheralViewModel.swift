//
//  PeripheralViewModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import SwiftUI
import CoreBluetooth

protocol PBTManager {
    func retrieveConnectedPeripherals() -> Void
    func scanPeripherals() -> Void
    func stopScan() -> Void
    func connectToPeripheral(with uuid: UUID) -> Void
}

@Observable
class PeripheralViewModel: PObserver, Identifiable {
    let id: UUID = .init()
    
    @ObservationIgnored private var sub: Result<Subscription, SubscriptionError>? = nil
    @ObservationIgnored private var btManager: PBTManager

    var centralState: CBManagerState = .unknown
    var peripherals: [PeripheralModel] = []
    var activePeripheral: PeripheralModel? = nil
    var activeCharacteristics: [CharacteristicModel] = []
    
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
    
    func connectToPeripheral(with id: UUID) -> Void {
        btManager.connectToPeripheral(with: id)
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
            if !peripherals.contains(where: { $0.id == peripheral.identifier }) {
                peripherals.append(.init(from: peripheral))
            }
        case .connectedToPeripheral(let cbPeripheral):
            if let peripheral = peripherals.first(where: { $0.id == cbPeripheral.identifier }) {
                activePeripheral = peripheral
            }
        case .disconnectedFromPeripheral(let cbPeripheral):
            if activePeripheral?.id == cbPeripheral.identifier {
                activePeripheral = nil
            }
        case .characteristicDiscovered(let characteristics):
            activeCharacteristics = characteristics.map { .init(from: $0) }
        }
    }
}

#if DEBUG
extension PeripheralViewModel {
    convenience init() {
        self.init(btManager: BTManager(with: .init()), subject: .init())
        centralState = .poweredOn
        peripherals = [
            .init(id: .init(), name: "Sweep Test", isOn: false),
            .init(id: .init(), name: "Iaei", isOn: false)
        ]
        activePeripheral = .init(id: .init(), name: "Sweep Test", isOn: false)
        activeCharacteristics = [
            .init(characteristic: .batteryLevel(54)),
            .init(characteristic: .batteryLevel(25)),
            .init(characteristic: .manufacturer("ZMK project")),
            .init(characteristic: .model("Cradio")),
        ]
    }
}
#endif
