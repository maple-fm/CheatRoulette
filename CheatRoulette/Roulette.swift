//
//  Roulette.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/09.
//

import SwiftUI

struct RouletteWheel: View {
    let items: [Item] // 🆕 Item 型のリスト
    var rotation: Double
    
    var body: some View {
        ZStack {
            let segmentAngle = 360.0 / Double(max(items.count, 1)) // 🔥 分割数を items.count に応じて決定
            
            ForEach(items.indices, id: \.self) { index in
                let startAngle = Angle(degrees: segmentAngle * Double(index))
                let endAngle = Angle(degrees: segmentAngle * Double(index + 1))
                let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2) // セグメントの中央角度
                
                RouletteSegment(startAngle: startAngle, endAngle: endAngle, color: items[index].color) // 🎨 ランダムな色を適用
                    .overlay(
                        GeometryReader { geometry in
                            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.8 // 🎯 文字の配置
                            let textPosition = CGPoint(
                                x: center.x + radius * cos(CGFloat(midAngle.radians)),
                                y: center.y + radius * sin(CGFloat(midAngle.radians))
                            )
                            
                            Text(items[index].name)
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .bold))
                                .position(x: textPosition.x, y: textPosition.y)
                        }
                    )
            }
        }
        .rotationEffect(.degrees(rotation))
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
