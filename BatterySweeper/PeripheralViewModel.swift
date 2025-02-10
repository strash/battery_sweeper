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
    
    private func subscribe(subject: Subject) -> Void {
        sub = .some(subject.subscribe(self))
    }
    
    func retrieveConnectedPeripherals() -> Void {
        btManager.retrieveConnectedPeripherals()
    }
    
    func selectPeripheral(_ peripheral: PeripheralModel) -> Void {
        if peripheral == activePeripheral {
            activePeripheral = nil
        } else {
            activePeripheral = peripheral
        }
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
        case .peripheralsResieved(let peripherals):
            self.peripherals = peripherals.map {
                .init(from: $0, side: .unknown)
            }
        }
    }
}
