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
final class Item: Hashable {
    @Attribute(.unique) var id: UUID  // 一意な識別子
    var name: String  // 項目名
    var timestamp: Date  // 作成日時
    var startAngle: Double // ルーレット上の開始角度
    var endAngle: Double   // ルーレット上の終了角度
    var colorHex: String   // 色を16進数文字列で保存
    var createdAt: Date // 追加順を管理
    var ratio: Double
    
    // 🎨 固定カラーパレット
    static let palette: [Color] = [
        Color(hex: "#FEC400"),
        Color(hex: "#FF7300"),
        Color(hex: "#FF2700"),
        Color(hex: "#FF33B0"),
        Color(hex: "#BF39FC"),
        Color(hex: "#6434FC"),
        Color(hex: "#0188FD"),
        Color(hex: "#00D4FC"),
        Color(hex: "#00F78E"),
        Color(hex: "#EB82F9"),
        Color(hex: "#7A7FF7"),
        Color(hex: "#FFD478"),
        Color(hex: "#FF7E79"),
        Color(hex: "#E94790"),
        Color(hex: "#1944F5"),
        Color(hex: "#8C8C8C")  // グレー
    ].compactMap { $0 } // nil防止
    // 🪄 直前に選んだ色を保存する static 変数
    private static var lastColorHex: String?
    
    init(name: String, ratio: Double, startAngle: Double, endAngle: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.timestamp = timestamp
        self.createdAt = Date()
        self.ratio = ratio
        
        // 🎯 ここで「連続しない色」を選ぶ
        let randomColor = Item.randomNonRepeatingColor()
        self.colorHex = randomColor.toHex()
        
        // 最後に選んだ色を更新
        Item.lastColorHex = self.colorHex
    }
    
    // 色を取得する computed property
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    // 🎯 連続しない色を選ぶ static 関数
    private static func randomNonRepeatingColor() -> Color {
        // 前回と違う色だけフィルタ
        let availableColors = palette.filter { $0.toHex() != lastColorHex }
        
        // もしフィルタ後に空になったら、全色から選び直す
        let colorsToChooseFrom = availableColors.isEmpty ? palette : availableColors
        
        return colorsToChooseFrom.randomElement() ?? .gray
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
