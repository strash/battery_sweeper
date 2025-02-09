//
//  BT.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/6/25.
//

import Foundation
import CoreBluetooth

protocol PBTManager {
    func retrieveConnectedPeripherals() -> Void
}

class BTManager: NSObject, PBTManager, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let BT_BATTERY_SERVICE_UUID = "0x180F"
    private let BT_BATTERY_CHARACTERISTICS_UUID = "0x2A19"

    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: Optional<CBPeripheral> = .none
    var availablePeripherals: Set<CBPeripheral> = []
    
    private var subject: Optional<Subject> = nil

    init(with subject: Subject) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.subject = subject
    }
    
    deinit {
        for peripheral in availablePeripherals {
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: protocol
    
    func retrieveConnectedPeripherals() {
        let cbuuid = CBUUID(string: BT_BATTERY_SERVICE_UUID)
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [cbuuid])
        for peripheral in peripherals {
            availablePeripherals.insert(peripheral)
            //self.centralManager.connect(peripheral, options: nil)
        }
        subject?.notify(.peripheralsResieved(peripherals))
        //            centralManager.scanForPeripherals(
        //                withServices: [CBUUID(string: BT_BATTERY_SERVICE_UUID)],
        //                options:  [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        //            )
    }
    
    // MARK: bt shits
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        subject?.notify(.centralStateChanged(central.state))
        switch central.state {
        case .poweredOn:
            break
        default:
            discoveredPeripheral = .none
            for peripheral in availablePeripherals {
                self.centralManager.cancelPeripheralConnection(peripheral)
            }
            availablePeripherals.removeAll()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        availablePeripherals.insert(peripheral)
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: BT_BATTERY_SERVICE_UUID)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            if service.uuid.isEqual(CBUUID(string: BT_BATTERY_SERVICE_UUID)) {
                peripheral.delegate = self
                peripheral.discoverCharacteristics([CBUUID(string: BT_BATTERY_CHARACTERISTICS_UUID)], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service.uuid.isEqual(CBUUID(string: BT_BATTERY_SERVICE_UUID)) {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid.isEqual(CBUUID(string: BT_BATTERY_CHARACTERISTICS_UUID)) {
                    peripheral.delegate = self
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid.isEqual(CBUUID(string: BT_BATTERY_CHARACTERISTICS_UUID)) && characteristic.value != nil {
            peripheral.delegate = self
            let value: Data = characteristic.value!
            let data = NSData(data: value)
            print(
                peripheral.name,
                characteristic.descriptors,
                characteristic.properties,
                characteristic.isNotifying,
                data.bytes.load(as: Int.self)
            )
            peripheral.setNotifyValue(true, for: characteristic)
            self.centralManager.stopScan()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid.isEqual(CBUUID(string: BT_BATTERY_CHARACTERISTICS_UUID)) && characteristic.value != nil {
            peripheral.delegate = self
            let value: Data = characteristic.value!
            let data = NSData(data: value)
            let name = peripheral.name ?? "--"
            print(
                name,
                "primary \(characteristic.service?.isPrimary)",
                "is notifying \(characteristic.isNotifying)",
                "\(data.bytes.load(as: Int.self))%"
            )
        }
    }
}
