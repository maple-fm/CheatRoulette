//
//  Roulette.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/09.
//

import SwiftUI

struct RouletteWheel: View {
    let items: [ItemData] // 🆕 Item 型のリストに変更
    var rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<items.count, id: \.self) { index in
                let startAngle = Angle(degrees: items[index].startAngle)
                let endAngle = Angle(degrees: items[index].endAngle)
                let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2) // セグメントの中央角度
                
                RouletteSegment(startAngle: startAngle, endAngle: endAngle, color: items[index].color) // 🆕 各項目の color を適用
                    .overlay(
                        GeometryReader { geometry in
                            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.7 // セグメントの中心あたりに配置
                            let textPosition = CGPoint(
                                x: center.x + radius * cos(CGFloat(midAngle.radians)),
                                y: center.y + radius * sin(CGFloat(midAngle.radians))
                            )
                            
                            Text(items[index].name) // 🆕 name を表示
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .bold))
                                .position(x: textPosition.x, y: textPosition.y)
                        }
                    )
            }
        }
        .rotationEffect(.degrees(rotation)) // 🆕 外側で回転適用
    }
}

// ルーレットのセグメント
struct RouletteSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

// 矢印の形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // 左上
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // 右上
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // 下中央（矢印の先端）
        path.closeSubpath()
        return path
    }
}
