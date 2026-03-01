//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import CoreBluetooth
import AppIntents

struct PeripheralModel: Identifiable, Codable, Hashable, Equatable, AppEntity {
    let id: UUID
    let name: String
    let characteristics: [CharacteristicModel]
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Device"
    static var defaultQuery = PeripheralQuery()
    
    init(id: UUID, name: String, characteristics: [CharacteristicModel]) {
        self.id = id
        self.name = name
        self.characteristics = characteristics
    }
    
    init(id: UUID, name: String) {
        self.init(id: id, name: name, characteristics: [])
    }

    init(from peripheral: CBPeripheral) {
        self.init(
            id: peripheral.identifier,
            name: peripheral.name ?? "--",
        )
    }
    
    func copyWith(name: String?, characteristics: [CharacteristicModel]?) -> Self {
        .init(
            id: self.id,
            name: name ?? self.name,
            characteristics: characteristics ?? self.characteristics
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.characteristics == rhs.characteristics
    }
}

struct PeripheralQuery: EntityQuery {
    func entities(for identifiers: [PeripheralModel.ID]) async throws -> [PeripheralModel] {
        do {
            return try await suggestedEntities().filter { identifiers.contains($0.id) }
        } catch {
            return []
        }
    }
    
    func suggestedEntities() async throws -> [PeripheralModel] {
        guard let userDefs = UserDefaults(suiteName: kSharedGroupName) else {
            return []
        }
        guard let data = userDefs.data(forKey: kPeripheralsKey) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([PeripheralModel].self, from: data)
        } catch {
            return []
        }
    }
    
    func defaultResult() async -> PeripheralModel? {
        do {
            return try await suggestedEntities().first
        } catch {
            return nil
        }
    }
}
