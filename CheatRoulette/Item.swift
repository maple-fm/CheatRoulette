//
//  Item.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
