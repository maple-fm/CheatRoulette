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
    
    init(name: String, startAngle: Double, endAngle: Double, color: Color, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.colorHex = color.toHex() // Color を 16進数に変換
        self.timestamp = timestamp
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

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        guard hexSanitized.count == 6,
              let rgbValue = UInt64(hexSanitized, radix: 16) else { return nil }
        
        self.init(
            red: Double((rgbValue >> 16) & 0xFF) / 255.0,
            green: Double((rgbValue >> 8) & 0xFF) / 255.0,
            blue: Double(rgbValue & 0xFF) / 255.0
        )
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
