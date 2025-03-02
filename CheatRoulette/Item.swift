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
    @Attribute(.unique) var id: UUID  // 一意な識別子
    var name: String  // 項目名
    var timestamp: Date  // 作成日時
    
    init(name: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
    }
}
