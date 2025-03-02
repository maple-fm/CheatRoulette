//
//  ContentView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var selectedItem: String = "選ばれた項目名"
    
    let items: [String] = ["項目A", "項目B", "項目C", "項目D"]
    let colors: [Color] = [.blue, .orange, .green, .red]
    
    var body: some View {
        VStack {
            Spacer()
            
            // 選ばれた項目ラベル
            Text(selectedItem)
                .font(.title)
                .padding()
            
            ZStack {
                // ルーレット
                RouletteWheel(items: items, colors: colors, rotation: rotation)
                    .frame(width: 300, height: 300)
                
                // 矢印
                Triangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                    .offset(y: -150) // ルーレットの上に配置
            }
            
            // スピンボタン
            Button("回す") {
                spinRoulette()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            // データ追加ボタン
            Button("データを追加する") {
                // データ追加画面に遷移する処理を入れる
            }
            .padding()
        }
    }
    
    private func spinRoulette() {
        let totalRotation: Double = 1440 // 2回転以上
        let duration: TimeInterval = 5.0 // 5秒間で止まる
        let steps = 100 // 徐々に減速するステップ数
        let interval = duration / Double(steps)
        
        var currentStep = 0
        var currentRotation = rotation
        let initialSpeed = totalRotation / Double(steps) * 5 // 最初のスピードを速めに
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            let progress = Double(currentStep) / Double(steps)
            let speedFactor = (1.0 - progress) * initialSpeed // 徐々に減速
            currentRotation += speedFactor
            
            rotation = currentRotation
            
            if currentStep >= steps {
                timer.invalidate() // 停止
                finalizeSelection() // 選ばれた項目を決定
            }
            
            currentStep += 1
        }
    }
    
    // 🎯 停止後に正しい項目を選択
    private func finalizeSelection() {
        let finalRotation = rotation.truncatingRemainder(dividingBy: 360)
        
        // 🎯 矢印が「下向き」なので90°補正
        let adjustedRotation = (finalRotation + 90).truncatingRemainder(dividingBy: 360)
        
        let segmentAngle = 360.0 / Double(items.count)
        
        // 🎯 SwiftUIの座標系に合わせて角度を反時計回りに調整
        let correctedRotation = (360 - adjustedRotation).truncatingRemainder(dividingBy: 360)
        
        for (index, _) in items.enumerated() {
            let startAngle = segmentAngle * Double(index)
            let endAngle = segmentAngle * Double(index + 1)
            
            if startAngle <= correctedRotation && correctedRotation < endAngle {
                selectedItem = items[index]
                break
            }
        }
    }


}

struct RouletteWheel: View {
    let items: [String]
    let colors: [Color]
    var rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<items.count, id: \.self) { index in
                let startAngle = Angle(degrees: (Double(index) / Double(items.count)) * 360)
                let endAngle = Angle(degrees: (Double(index + 1) / Double(items.count)) * 360)
                let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2) // セグメントの中央角度
                
                RouletteSegment(startAngle: startAngle, endAngle: endAngle, color: colors[index % colors.count])
                    .overlay(
                        GeometryReader { geometry in
                            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            let radius = min(geometry.size.width, geometry.size.height) / 2 * 0.7 // セグメントの中心あたりに配置
                            let textPosition = CGPoint(
                                x: center.x + radius * cos(CGFloat(midAngle.radians)),
                                y: center.y + radius * sin(CGFloat(midAngle.radians))
                            )
                            
                            Text(items[index])
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

#Preview {
    ContentView()
}
