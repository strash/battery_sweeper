//
//  BT.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/6/25.
//

import CoreBluetooth

struct BTCharacteristic: Identifiable {
    enum EBTCharacteristic {
        case batteryLevel(Int)
        case manufacturerName(String)
        case modelNumber(String)
    }
    
    var id: UUID
    var value: EBTCharacteristic
}

class BTManager: NSObject, PBTManager, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let BT_BATTERY_SERVICE_UUID = "0x180F"
    private let BT_DEVICE_INFORMATION_SERVICE_UUID = "0x180A"
    private let BT_BATTERY_LEVEL_CHARACTERISTIC_UUID = "0x2A19"
    private let BT_MODEL_NUMBER_STRING_CHARACTERISTIC_UUID = "0x2A24"
    private let BT_MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID = "0x2A29"

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
        if characteristic.uuid == batteryLevelCharacteristicUUID && !characteristic.isNotifying {
            peripheral.delegate = self
            peripheral.setNotifyValue(true, for: characteristic)
        }
        subject?.notify(.characteristicDiscovered(
            getCharacteristics(from: characteristic, for: peripheral.identifier))
        )
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) -> Void {
        // TODO: возможно нужно отпралять сообщение в субъект, что характеристика батареи перестала отправлять сообщения
        print("BT notification state for:",
              peripheral.name ?? "--",
              "notifying \(characteristic.isNotifying)"
        )
    }
    
    private func getCharacteristics(from characteristic: CBCharacteristic, for id: UUID) -> [BTCharacteristic] {
        var chars: [BTCharacteristic] = []
        if let services = characteristic.service?.peripheral?.services {
            for s in services {
                if let characteristics = s.characteristics {
                    for c in characteristics {
                        guard let v = c.value else {
                            continue
                        }
                        switch c.uuid {
                        case batteryLevelCharacteristicUUID:
                            let data = NSData(data: v)
                            chars.append(.init(id: id, value: .batteryLevel(data.bytes.load(as: Int.self))))
                        case manufacturerNameStringCharacteristicUUID:
                            let value = String(data: v, encoding: .utf8)
                            if let value {
                                chars.append(.init(id: id, value: .manufacturerName(value)))
                            }
                        case modelNumberStringCharacteristicUUID:
                            let value = String(data: v, encoding: .utf8)
                            if let value {
                                chars.append(.init(id: id, value: .modelNumber(value)))
                            }
                        default:
                            continue
                        }
                    }
                }
            }
        }
        return chars
    }
}
