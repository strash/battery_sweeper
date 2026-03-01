//
//  BTServiceDelegate.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/18/26.
//

import Foundation
import CoreBluetooth

class BTServiceDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var central: CBCentralManager!
    var availablePeripherals: Set<CBPeripheral> = []
    
    var subject: EventService? = nil
    
    private let option = CBConnectPeripheralOptionEnableAutoReconnect

    init(with subject: EventService) {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
        self.subject = subject
    }
    
    deinit {
        clean()
    }

    // on update state
    func centralManagerDidUpdateState(_ central: CBCentralManager) -> Void {
        subject?.notify(.centralStateChanged(central.state))
        if central.state == .poweredOn {
            retrieveConnectedPeripherals()
        } else {
            clean()
        }
    }
    
    // on discover a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) -> Void {
        availablePeripherals.insert(peripheral)
        peripheral.delegate = self
        subject?.notify(.peripheralsDiscovered([peripheral]))
    }
    
    // on connect to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        peripheral.delegate = self
        peripheral.discoverServices([
            BTConstants.batteryServiceUUID,
            BTConstants.deviceInformationServiceUUID
        ])
        subject?.notify(.connectedToPeripheral(peripheral))
        self.central.connect(peripheral, options: [option: true])
    }
    
    // on fail to connect to a peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) -> Void {
        if let error { print(error) }
        subject?.notify(.failToConnectToPeripheral(peripheral, error))
    }
    
    // on disconnect from a peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) -> Void {
        if let error { print(error) }
        subject?.notify(.disconnectedFromPeripheral(peripheral))
    }
    
    // on reconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) -> Void {
        if let error { print(error) }
        if isReconnecting {
            subject?.notify(.connectedToPeripheral(peripheral))
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) -> Void {
        let index = availablePeripherals.firstIndex(where: { $0.identifier == peripheral.identifier })
        if let index {
            availablePeripherals.remove(at: index)
            availablePeripherals.insert(peripheral)
        }
        subject?.notify(.peripheralUpdated(peripheral))
    }
    
    // on discover a services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) -> Void {
        if let error { print(error) }
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.delegate = self
            peripheral.discoverCharacteristics([
                BTConstants.batteryLevelCharacteristicUUID,
                BTConstants.modelNumberStringCharacteristicUUID,
                BTConstants.manufacturerNameStringCharacteristicUUID,
            ], for: service)
        }
    }
    
    // on discover a characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) -> Void {
        if let error { print(error) }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.delegate = self
            peripheral.readValue(for: characteristic)
        }
    }
    
    // on discover or change of a value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) -> Void {
        if let error { print(error) }
        if characteristic.uuid == BTConstants.batteryLevelCharacteristicUUID && !characteristic.isNotifying {
            peripheral.delegate = self
            peripheral.setNotifyValue(true, for: characteristic)
        }
        let values = characteristic.allFromService
            .map { $0.toValue }
            .filter { $0 != nil } as! [ECharacteristic]
        if !values.isEmpty {
            subject?.notify(.characteristicsDiscovered(peripheral, values))
        }
    }
    
    func retrieveConnectedPeripherals() -> Void {
        guard central.state == .poweredOn else { return }
        let peripherals = central.retrieveConnectedPeripherals(
            withServices: [BTConstants.batteryServiceUUID]
        )
        availablePeripherals.removeAll()
        availablePeripherals.formUnion(peripherals)
        subject?.notify(.peripheralsDiscovered(peripherals))
        peripherals.forEach {
            self.central.connect($0, options: [option: true])
        }
    }

    func cancel(_ peripheral: CBPeripheral?) -> Void {
        guard let peripheral else { return }
        if let services = peripheral.services {
            for service in services {
                guard let chars = service.characteristics else { continue }
                chars.forEach { peripheral.setNotifyValue(false, for: $0) }
            }
        }
        central.cancelPeripheralConnection(peripheral)
    }
    
    func clean() -> Void {
        availablePeripherals.forEach { cancel($0) }
        availablePeripherals.removeAll()
    }
}
