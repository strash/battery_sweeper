//
//  Subscription.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation

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
