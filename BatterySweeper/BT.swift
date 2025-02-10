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
    func scanPeripherals() -> Void
    func stopScan() -> Void
    func connectToPeripheral(with uuid: UUID) -> Void
}

class BTManager: NSObject, PBTManager, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let BT_BATTERY_SERVICE_UUID = "0x180F"
    private let BT_DEVICE_INFORMATION_SERVICE_UUID = "0x180A"
    private let BT_BATTERY_LEVEL_CHARACTERISTIC_UUID = "0x2A19"
    private let BT_MODEL_NUMBER_STRING_CHARACTERISTIC_UUID = "0x2A24"
    private let BT_MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID = "0x2A29"
    private let BT_PNP_ID_CHARACTERISTIC_UUID = "0x2A50"

    private var centralManager: CBCentralManager!
    private var activePeripheral: CBPeripheral? = nil
    private var availablePeripherals: [CBPeripheral] = []
    
    private var subject: Subject? = nil

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
    
    private var batteryServiceUUID: CBUUID {
        CBUUID(string: BT_BATTERY_SERVICE_UUID)
    }
    
    private var deviceInformationServiceUUID: CBUUID {
        CBUUID(string: BT_DEVICE_INFORMATION_SERVICE_UUID)
    }
    
    private var batteryLevelCharacteristicUUID: CBUUID {
        CBUUID(string: BT_BATTERY_LEVEL_CHARACTERISTIC_UUID)
    }
    
    private var modelNumberStringCharacteristicUUID: CBUUID {
        CBUUID(string: BT_MODEL_NUMBER_STRING_CHARACTERISTIC_UUID)
    }
    
    private var manufacturerNameStringCharacteristicUUID: CBUUID {
        CBUUID(string: BT_MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID)
    }

    // MARK: protocol
    
    func retrieveConnectedPeripherals() -> Void {
        guard centralManager.state == .poweredOn else {
            return
        }
        let peripherals = centralManager.retrieveConnectedPeripherals(
            withServices: [batteryServiceUUID]
        )
        for peripheral in peripherals {
            availablePeripherals.append(peripheral)
            subject?.notify(.peripheralDiscovered(peripheral))
        }
    }
    
    func scanPeripherals() -> Void {
        guard centralManager.state == .poweredOn && !centralManager.isScanning else {
            return
        }
        centralManager.scanForPeripherals(
            withServices: [batteryServiceUUID],
            options:  [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScan() -> Void {
        guard centralManager.isScanning else {
            return
        }
        centralManager.stopScan()
    }
    
    func connectToPeripheral(with uuid: UUID) -> Void {
        guard let peripheral = availablePeripherals.first(where: { $0.identifier == uuid }) else {
            return
        }
        if let activePeripheral {
            centralManager.cancelPeripheralConnection(activePeripheral)
            subject?.notify(.disconnectedFromPeripheral(activePeripheral))
        }
        centralManager.connect(peripheral, options: nil)
    }
    
    // MARK: bt shits
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) -> Void {
        subject?.notify(.centralStateChanged(central.state))
        switch central.state {
        case .poweredOn:
            break
        default:
            if let activePeripheral {
                centralManager.cancelPeripheralConnection(activePeripheral)
            }
            for peripheral in availablePeripherals {
                centralManager.cancelPeripheralConnection(peripheral)
            }
            availablePeripherals.removeAll()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) -> Void {
        availablePeripherals.append(peripheral)
        peripheral.delegate = self
        subject?.notify(.peripheralDiscovered(peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        activePeripheral = peripheral
        subject?.notify(.connectedToPeripheral(peripheral))
        peripheral.delegate = self
        peripheral.discoverServices([batteryServiceUUID, deviceInformationServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) -> Void {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.delegate = self
            peripheral.discoverCharacteristics([
                batteryLevelCharacteristicUUID,
                modelNumberStringCharacteristicUUID,
                manufacturerNameStringCharacteristicUUID,
            ],
               for: service
            )
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) -> Void {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            peripheral.delegate = self
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) -> Void {
        guard let value = characteristic.value else {
            return
        }
        let data = NSData(data: value)
        var description: String = "--"
        switch characteristic.uuid {
        case batteryLevelCharacteristicUUID:
            description = "\(data.bytes.load(as: Int.self))"
        case modelNumberStringCharacteristicUUID,
            manufacturerNameStringCharacteristicUUID:
            description = String(data: value, encoding: .utf8) ?? "--"
        default:
            description = "--"
        }
        print("BT discovered value:",
              peripheral.name ?? "--",
              description,
              "primary \(characteristic.service?.isPrimary ?? false)"
        )
        if characteristic.uuid == batteryLevelCharacteristicUUID {
            peripheral.delegate = self
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) -> Void {
        print("BT notification state for:",
              peripheral.name ?? "--",
              "notifying \(characteristic.isNotifying)"
        )
    }
}
