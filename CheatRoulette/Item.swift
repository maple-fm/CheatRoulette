//
//  Item.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    @Attribute(.unique) var id: UUID  // 一意な識別子
    var name: String  // 項目名
    var timestamp: Date  // 作成日時
    var startAngle: Double // ルーレット上の開始角度
    var endAngle: Double   // ルーレット上の終了角度
    var colorHex: String   // 色を16進数文字列で保存
    var createdAt: Date // 追加順を管理
    var ratio: Double
    
    init(name: String, ratio: Double, startAngle: Double, endAngle: Double, color: Color, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.colorHex = color.toHex() // Color を 16進数に変換
        self.timestamp = timestamp
        self.createdAt = Date()
        self.ratio = ratio
    }
    
    // 色を取得する computed property
    var color: Color {
        Color(hex: colorHex) ?? .gray // 変換失敗時はデフォルトのグレー
    }
}

@Model
class Template {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade) var items: [Item]
    
    init(name: String, items: [Item]) {
        self.id = UUID()
        self.name = name
        self.items = items
    }
}
