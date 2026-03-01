//
//  ObserverProtocol.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation

protocol PObserver: Identifiable {
    var id: UUID { get }
    
    func onData(_ event: EEvent) -> Void
}
