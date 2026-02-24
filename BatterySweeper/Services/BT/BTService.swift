//
//  BTService.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/6/25.
//

import CoreBluetooth

class BTService: BTServiceDelegate, PBTService {
    private var timer: Timer?
    
    override init(with subject: EventService) {
        super.init(with: subject)
    }
    
    func scanPeripherals() -> Void {
        guard super.central.state == .poweredOn && !super.central.isScanning else {
            return
        }
        super.central.scanForPeripherals(
            withServices: [BTConstants.batteryServiceUUID],
            options:  [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScan() -> Void {
        guard super.central.state == .poweredOn && super.central.isScanning else {
            return
        }
        super.central.stopScan()
    }
    
    func connectToPeripheral(with uuid: UUID?) -> Void {
        if let activePeripheral {
            cancel(activePeripheral)
            super.activePeripheral = nil
        }
        guard let peripheral = super.availablePeripherals.first(where: { $0.identifier == uuid }) else {
            return
        }
        super.central.connect(
            peripheral,
            options: [CBConnectPeripheralOptionEnableAutoReconnect: true]
        )
    }
    
    func restoreConnection() -> Void {
        guard let activePeripheral else { return }
        invalidateTimer()
        self.timer = Timer(timeInterval: 5, repeats: true) { _ in
            self.connectToPeripheral(with: activePeripheral.identifier)
        }
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    override func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        invalidateTimer()
        super.centralManager(central, didConnect: peripheral)
    }
    
    private func invalidateTimer() {
        if let timer, timer.isValid { timer.invalidate() }
    }
}

