//
//  ObserverProtocol.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/19/26.
//

import Foundation

protocol PObserver: AnyObject, Identifiable {
    func onData(_ event: EEvent) -> Void
}
