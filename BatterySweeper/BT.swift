//
//  BT.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/6/25.
//

import CoreBluetooth

enum EBTCharacteristic: Equatable {
    case batteryLevel(Int)
    case manufacturerName(String)
    case modelNumber(String)
}

struct BTCharacteristic: Identifiable {
    var id: UUID
    var value: EBTCharacteristic
}

class BTManagerImpl: BaseBTManager, PBTManager {
    private var timer: Timer?
    
    override init(with subject: Subject) {
        super.init(with: subject)
    }
    
    func retrieveConnectedPeripherals() -> Void {
        guard centralManager.state == .poweredOn else {
            return
        }
        let peripherals = centralManager.retrieveConnectedPeripherals(
            withServices: [batteryServiceUUID]
        )
        availablePeripherals.removeAll()
        for peripheral in peripherals {
            availablePeripherals.insert(peripheral)
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
        guard centralManager.state == .poweredOn &&  centralManager.isScanning else {
            return
        }
        centralManager.stopScan()
    }
    
    func connectToPeripheral(with uuid: UUID) -> Void {
        if let activePeripheral {
            disconnectAndCancel(activePeripheral)
            self.activePeripheral = nil
        }
        guard let peripheral = availablePeripherals.first(where: { $0.identifier == uuid }) else {
            return
        }
        centralManager.connect(
            peripheral,
            options: [CBConnectPeripheralOptionEnableAutoReconnect: true]
        )
    }
    
    func tryToReconnenct() -> Void {
        guard let activePeripheral else {
            return
        }
        timer = Timer(timeInterval: 5, repeats: true) { t in
            self.connectToPeripheral(with: activePeripheral.identifier)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        if let timer, timer.isValid {
            timer.invalidate()
        }
        super.centralManager(central, didConnect: peripheral)
    }
}

class BaseBTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let BT_BATTERY_SERVICE_UUID = "0x180F"
    private let BT_DEVICE_INFORMATION_SERVICE_UUID = "0x180A"
    private let BT_BATTERY_LEVEL_CHARACTERISTIC_UUID = "0x2A19"
    private let BT_MODEL_NUMBER_STRING_CHARACTERISTIC_UUID = "0x2A24"
    private let BT_MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID = "0x2A29"

    fileprivate var centralManager: CBCentralManager!
    fileprivate var activePeripheral: CBPeripheral? = nil
    fileprivate var availablePeripherals: Set<CBPeripheral> = []
    
    fileprivate var subject: Subject? = nil

    init(with subject: Subject) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.subject = subject
    }
    
    deinit {
        if let activePeripheral {
            disconnectAndCancel(activePeripheral)
            self.activePeripheral = nil
        }
        for peripheral in availablePeripherals {
            disconnectAndCancel(peripheral)
        }
        availablePeripherals.removeAll()
    }
    
    fileprivate var batteryServiceUUID: CBUUID {
        CBUUID(string: BT_BATTERY_SERVICE_UUID)
    }
    
    fileprivate var deviceInformationServiceUUID: CBUUID {
        CBUUID(string: BT_DEVICE_INFORMATION_SERVICE_UUID)
    }
    
    fileprivate var batteryLevelCharacteristicUUID: CBUUID {
        CBUUID(string: BT_BATTERY_LEVEL_CHARACTERISTIC_UUID)
    }
    
    fileprivate var modelNumberStringCharacteristicUUID: CBUUID {
        CBUUID(string: BT_MODEL_NUMBER_STRING_CHARACTERISTIC_UUID)
    }
    
    fileprivate var manufacturerNameStringCharacteristicUUID: CBUUID {
        CBUUID(string: BT_MANUFACTURER_NAME_STRING_CHARACTERISTIC_UUID)
    }
    
    // on update state
    func centralManagerDidUpdateState(_ central: CBCentralManager) -> Void {
        subject?.notify(.centralStateChanged(central.state))
        switch central.state {
        case .poweredOn:
            break
        default:
            break
//            if let activePeripheral {
//                disconnectAndCancel(activePeripheral)
//                self.activePeripheral = nil
//                subject?.notify(.disconnectedFromPeripheral(activePeripheral))
//            }
//            for peripheral in availablePeripherals {
//                disconnectAndCancel(peripheral)
//            }
//            availablePeripherals.removeAll()
        }
    }
    
    // on discover a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) -> Void {
        availablePeripherals.insert(peripheral)
        peripheral.delegate = self
        subject?.notify(.peripheralDiscovered(peripheral))
    }
    
    // on connect to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) -> Void {
        activePeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([batteryServiceUUID, deviceInformationServiceUUID])
        subject?.notify(.connectedToPeripheral(peripheral))
    }
    
    // on fail to connect to a peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            print(error)
        }
        subject?.notify(.failToConnectToPeripheral(peripheral, error))
    }
    
    // on disconnect from a peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error {
            print(error)
        }
        subject?.notify(.disconnectedFromPeripheral(peripheral))
    }
    
    // on reconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        if let error {
            print(error)
        }
        if isReconnecting {
            subject?.notify(.connectedToPeripheral(peripheral))
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        let index = availablePeripherals.firstIndex(where: { $0.identifier == peripheral.identifier })
        if let index {
            availablePeripherals.remove(at: index)
            availablePeripherals.insert(peripheral)
        }
        if let activePeripheral, activePeripheral.identifier == peripheral.identifier {
            self.activePeripheral = peripheral
        }
        subject?.notify(.peripheralUpdated(peripheral))
    }

    // on discover a services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) -> Void {
        if let error {
            print(error)
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.delegate = self
            peripheral.discoverCharacteristics([
                batteryLevelCharacteristicUUID,
                modelNumberStringCharacteristicUUID,
                manufacturerNameStringCharacteristicUUID,
            ], for: service)
        }
    }
    
    // on discover a characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) -> Void {
        if let error {
            print(error)
        }
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            peripheral.delegate = self
            peripheral.readValue(for: characteristic)
        }
    }
    
    // on discover or change of a value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) -> Void {
        if let error {
            print(error)
        }
        if characteristic.uuid == batteryLevelCharacteristicUUID && !characteristic.isNotifying {
            peripheral.delegate = self
            peripheral.setNotifyValue(true, for: characteristic)
        }
        subject?.notify(.characteristicDiscovered(
            getCharacteristics(from: characteristic, for: peripheral.identifier))
        )
    }
    
    fileprivate func getCharacteristics(from characteristic: CBCharacteristic, for id: UUID) -> [BTCharacteristic] {
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
    
    fileprivate func disconnectAndCancel(_ peripheral: CBPeripheral?) -> Void {
        if let peripheral {
            if let services = peripheral.services {
                for service in services {
                    guard let characteristics = service.characteristics else {
                        continue
                    }
                    for characteristic in characteristics {
                        peripheral.setNotifyValue(false, for: characteristic)
                    }
                }
            }
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
