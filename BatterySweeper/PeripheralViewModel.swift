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
    var activePeripheral: Optional<PeripheralModel> = .none
    
    @ObservationIgnored private var btManager: PBTManager
    
    init(btManager: PBTManager, subject: Subject) {
        self.btManager = btManager
        subscribe(subject: subject)
    }
    
    private func subscribe(subject: Subject) {
        sub = .some(subject.subscribe(self))
    }
    
    func onData(_ event: EEvent) {
        switch event {
        case .centralStateChanged(let state):
            centralState = state
            switch state {
            case .poweredOn:
                self.btManager.retrieveConnectedPeripherals()
            case _:
                break;
            }
        case .peripheralsResieved(let peripherals):
            self.peripherals = peripherals.map {
                PeripheralModel(
                    id: $0.identifier,
                    name: $0.name ?? "--",
                    side: .unknown,
                    battery: 0
                )
            }
        }
    }
}
