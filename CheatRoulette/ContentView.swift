//
//  ContentView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import SwiftUI
import SwiftData

struct ItemData {
    let name: String
    let startAngle: Double
    let endAngle: Double
    let color: Color
}


struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var selectedItem: String = "選ばれた項目名"
    @State private var isCheatMode: Bool = false // インチキモード
    @State private var cheatItem: String = "項目A" // インチキ時の固定項目
    @State private var isSpinning: Bool = false // 🎯 ルーレットが回転中かどうかを管理
    
    let items: [ItemData] = ContentView.generateItems()
    
    static func generateItems() -> [ItemData] {
        let names = ["項目A", "項目B", "項目C", "項目D"]
        let colors: [Color] = [.blue, .orange, .green, .red] // 各項目の色を定義
        let segmentAngle = 360.0 / Double(names.count)
        
        return names.enumerated().map { index in
            let start = segmentAngle * Double(index.offset)
            let end = segmentAngle * Double(index.offset + 1)
            return ItemData(name: names[index.offset], startAngle: start, endAngle: end, color: colors[index.offset])
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // 選ばれた項目ラベル
            Text(selectedItem)
                .font(.title)
                .padding()
            
            ZStack {
                // ルーレット
                RouletteWheel(items: items, rotation: rotation)
                    .frame(width: 300, height: 300)
                
                // 矢印
                Triangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                    .offset(y: -150) // ルーレットの上に配置
            }
            
            HStack {
                Button("回す") {
                    spinRoulette()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(isSpinning)
                
                Toggle("インチキモード", isOn: $isCheatMode)
                    .padding()
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
        guard !isSpinning else { return } // すでに回転中なら何もしない
        isSpinning = true
        
        let baseRotation: Double = 1440 // 最低4回転
        let duration: TimeInterval = Double.random(in: 4.0...7.0) // 4〜7秒のランダム時間
        let steps = 100 // 減速ステップ数
        let interval = duration / Double(steps)
        
        var currentStep = 0
        let startRotation = rotation.truncatingRemainder(dividingBy: 360) // 現在の角度を取得
        var currentRotation = rotation
        let initialSpeed = baseRotation / Double(steps) * 5 // 初速度
        
        // 🎯 インチキモードの目標角度を決定
        var targetRotation: Double? = nil
        if isCheatMode, let cheatIndex = items.firstIndex(where: { $0.name == cheatItem }) {
            let segmentAngle = 360.0 / Double(items.count)
            let startAngle = segmentAngle * Double(cheatIndex)  // 項目の開始角度
            let endAngle = segmentAngle * Double(cheatIndex + 1) // 項目の終了角度
            
            let randomTarget = Double.random(in: startAngle...endAngle) // 範囲内のランダムな角度
            let adjustedTarget = 360 - (randomTarget + 90) // 矢印の向きを考慮
            
            targetRotation = startRotation + baseRotation + adjustedTarget
        }
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            let progress = Double(currentStep) / Double(steps)
            
            // 🎯 スムーズな減速ロジック
            let speedFactor = initialSpeed * (1.0 - pow(progress, 3))
            
            if let targetRotation = targetRotation {
                let remainingRotation = targetRotation - currentRotation
                
                if remainingRotation > 0 {
                    currentRotation += min(speedFactor, remainingRotation * 0.1) // 目標に向かって調整
                } else {
                    timer.invalidate()
                    finalizeSelection()
                    isSpinning = false
                    return
                }
            } else {
                currentRotation += speedFactor // 通常モードの回転
            }
            
            rotation = currentRotation
            
            if currentStep >= steps {
                timer.invalidate()
                finalizeSelection()
                isSpinning = false
            }
            
            currentStep += 1
        }
    }
    
    private func finalizeSelection() {
        let finalRotation = rotation.truncatingRemainder(dividingBy: 360)
        let adjustedRotation = (finalRotation + 90).truncatingRemainder(dividingBy: 360)
        let correctedRotation = (360 - adjustedRotation).truncatingRemainder(dividingBy: 360)
        
        if let selected = items.first(where: { $0.startAngle <= correctedRotation && correctedRotation < $0.endAngle }) {
            selectedItem = selected.name
        }
    }
}

#Preview {
    ContentView()
}
