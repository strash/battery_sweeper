//
//  EventService.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth

class EventService {
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
