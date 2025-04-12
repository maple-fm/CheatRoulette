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
        Color("Yellow"),
        Color("Orange"),
        Color("Red"),
        Color("Pink"),
        Color("Purple"),
        Color("DarkPurple"),
        Color("Blue"),
        Color("LightBlue"),
        Color("LightGreen"),
        Color("LightPurple"),
        Color("BluePurple"),
        Color("Begue"),
        Color("SalmonPink"),
        Color("Rose"),
        Color("DarkBlue")
    ].compactMap { $0 } // nil防止
    
    // 🪄 最後に使ったインデックスを保存
    private static var lastColorIndex: Int = -1  // 最初はまだ何も使ってないので -1
    
    init(name: String, ratio: Double, startAngle: Double, endAngle: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.timestamp = timestamp
        self.createdAt = Date()
        self.ratio = ratio
    
        // 🎯 次の色を順番に取得
        let nextColor = Item.nextSequentialColor()
        self.colorHex = nextColor.toHex()
    }
    
    // 色を取得する computed property
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    // 🎯 順番に色を取得する
    private static func nextSequentialColor() -> Color {
        lastColorIndex += 1
        if lastColorIndex >= palette.count {
            lastColorIndex = 0 // 最後まで行ったら最初に戻る
        }
        return palette[lastColorIndex]
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
