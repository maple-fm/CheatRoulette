//
//  Color.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/19.
//

import SwiftUI

extension Color {
    
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
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
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
