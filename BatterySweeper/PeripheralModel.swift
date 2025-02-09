//
//  PeripheralModel.swift
//  BatterySweeper
//
//  Created by Dmitry Poyarkov on 2/9/25.
//

import Foundation

enum ESide {
    case left, right
    case unknown
}

struct PeripheralModel: Identifiable {
    var id: UUID
    var name: String
    var side: ESide
    var battery: Int
}
