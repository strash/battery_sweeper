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
    
    func retrieveConnectedPeripherals() -> Void {
        guard super.centralManager.state == .poweredOn else {
            return
        }
        let peripherals = super.centralManager.retrieveConnectedPeripherals(
            withServices: [super.batteryServiceUUID]
        )
        super.availablePeripherals.removeAll()
        for peripheral in peripherals {
            super.availablePeripherals.insert(peripheral)
            super.subject?.notify(.peripheralDiscovered(peripheral))
        }
    }
    
    func scanPeripherals() -> Void {
        guard super.centralManager.state == .poweredOn && !super.centralManager.isScanning else {
            return
        }
        super.centralManager.scanForPeripherals(
            withServices: [super.batteryServiceUUID],
            options:  [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScan() -> Void {
        guard super.centralManager.state == .poweredOn && super.centralManager.isScanning else {
            return
        }
        super.centralManager.stopScan()
    }
    
    func connectToPeripheral(with uuid: UUID?) -> Void {
        if let activePeripheral {
            disconnectAndCancel(activePeripheral)
            super.activePeripheral = nil
        }
        guard let peripheral = super.availablePeripherals.first(where: { $0.identifier == uuid }) else {
            return
        }
        super.centralManager.connect(
            peripheral,
            options: [CBConnectPeripheralOptionEnableAutoReconnect: true]
        )
    }
    
    func tryToReconnenct() -> Void {
        guard let activePeripheral else {
            return
        }
        self.timer = Timer(timeInterval: 5, repeats: true) { _ in
            self.connectToPeripheral(with: activePeripheral.identifier)
        }
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    override func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        if let timer, timer.isValid {
            timer.invalidate()
        }
        super.centralManager(central, didConnect: peripheral)
    }
}

