//
//  EventService.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth

enum EEvent {
    case centralStateChanged(CBManagerState)
    case peripheralDiscovered(CBPeripheral)
    case connectedToPeripheral(CBPeripheral)
    case failToConnectToPeripheral(CBPeripheral, (any Error)?)
    case disconnectedFromPeripheral(CBPeripheral)
    case peripheralUpdated(CBPeripheral)
    case characteristicDiscovered([BTCharacteristic])
}

protocol PObserver: AnyObject, Identifiable {
    func onData(_ event: EEvent) -> Void
}

struct Subscription {
    private let _observer: any PObserver
    private let _cancel: (_ observer: any PObserver) -> Void
    
    init(observer: any PObserver, cancel: @escaping (_ observer: any PObserver) -> Void) {
        _observer = observer
        _cancel = cancel
    }
    
    func cancel() -> Void {
        _cancel(_observer)
    }
}

struct SubscriptionError: Error {
    let message: String
}

class Subject {
    private var observers: [any PObserver] = []
    
    deinit {
        observers.removeAll()
    }
    
    func subscribe(_ observer: any PObserver) -> Result<Subscription, SubscriptionError> {
        if observers.contains(where: { $0.id == observer.id }) {
            return .failure(SubscriptionError(
                message: "The observer has already been added"))
        }
        observers.append(observer)
        return .success(Subscription(observer: observer, cancel: self.cancel))
    }
    
    func notify(_ event: EEvent) -> Void {
        observers.forEach { $0.onData(event) }
    }
    
    private func cancel(_ observer: any PObserver) -> Void {
        observers.removeAll(where: { $0.id == observer.id })
    }
}
