//
//  ContentView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item] // SwiftData のデータを取得
    @Query private var templates: [Template]
    @State private var selectedTemplate: Template?
    
    @State private var rotation: Double = 0
    @State private var selectedItem: String = "選ばれた項目名"
    @State private var isCheatMode: Bool = false // インチキモード
    @State private var cheatItem: String = "項目A" // インチキ時の固定項目
    @State private var isSpinning: Bool = false // ルーレットが回転中かどうかを管理
    @State private var isShowingNewItemView = false
    @State private var isShowingEditView = false
    @State private var isSelectingTemplate = false // テンプレート選択画面の表示管理
    
    
    var body: some View {
        VStack {
            Spacer()
            
            // 選ばれた項目ラベル
            Text(selectedItem)
                .font(.title)
                .padding()
            
            ZStack {
                ZStack {
                    // ルーレット
                    RouletteWheel(items: items, rotation: rotation)
                        .frame(width: 300, height: 300)
                    
                    // 🎯 ルーレットの中央にボタンを配置
                    Button(action: {
                        // アイテムの角度を更新する
                        updateItemAngles()
                        spinRoulette()
                        
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text("回す")
                                    .foregroundColor(.black)
                                    .font(.title)
                                    .bold()
                            )
                    }
                }
                
                // 矢印
                Triangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                    .offset(y: -150) // ルーレットの上に配置
            }
            
            HStack {
                Toggle("インチキモード", isOn: $isCheatMode)
                    .padding()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            // データ追加ボタン
            Button("データを追加する") {
                removeAll()
                isShowingNewItemView = true
            }
            .padding()
            .sheet(isPresented: $isShowingNewItemView) {
                AddView()
            }
            
            Button("項目を編集する") {
                isShowingEditView = true
            }
            .padding()
            .sheet(isPresented: $isShowingEditView) {
                ItemEditView()
            }
            
            Button("テンプレートを選択") {
                isSelectingTemplate = true // モーダルを開く
            }
            .sheet(isPresented: $isSelectingTemplate) {
                TemplateSelectionView { selectedTemplate in
                    applyTemplate(selectedTemplate) // 選択したテンプレートを適用
                }
            }
        }
    }
    
    private func spinRoulette() {
        guard !isSpinning, !items.isEmpty else { return } // 空なら回さない
        isSpinning = true
        
        let baseRotation: Double = Double.random(in: 770...1440) // 最低4回転
        let duration: TimeInterval = Double.random(in: 4.0...7.0) // 4〜7秒のランダム時間
        let steps = 100 // 減速ステップ数
        let interval = duration / Double(steps)
        
        var currentStep = 0
        let startRotation = rotation.truncatingRemainder(dividingBy: 360) // 現在の角度を取得
        var currentRotation = rotation
        let initialSpeed = baseRotation / Double(steps) * 5 // 初速度
        
        // 🎯 インチキモードの目標角度を決定
        var targetRotation: Double? = nil
        if isCheatMode, let cheatItemData = items.first(where: { $0.name == cheatItem }) {
            let randomTarget = Double.random(in: cheatItemData.startAngle...cheatItemData.endAngle)
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
        
        // 回転角度に基づいて、現在の位置がどの項目に対応しているかを判定
        if let selected = items.first(where: { $0.startAngle <= correctedRotation && correctedRotation < $0.endAngle }) {
            selectedItem = selected.name
        } else {
            // 何も見つからない場合は、"選ばれた項目名"を表示
            selectedItem = "選ばれた項目名"
        }
    }
    
    private func removeAll() {
        // アイテムをすべて削除
        for item in items {
            modelContext.delete(item)
        }
    }
    
    // ルーレットが回り始める時に角度を更新するメソッド
    private func updateItemAngles() {
        let segmentAngle = 360.0 / Double(items.count)
        
        for (index, item) in items.enumerated() {
            let newStartAngle = segmentAngle * Double(index)
            let newEndAngle = newStartAngle + segmentAngle
            
            // Model のデータを更新
            item.startAngle = newStartAngle
            item.endAngle = newEndAngle
            
            // 更新を保存
            try? modelContext.save()
        }
    }
    
    private func applyTemplate(_ template: Template) {
        // 現在の items をクリアして、新しいテンプレートの items を適用
        for item in items {
            modelContext.delete(item)
        }
        
        for newItem in template.items {
            let copiedItem = Item(name: newItem.name, startAngle: 0, endAngle: 0, color: newItem.color)
            modelContext.insert(copiedItem)
        }
        
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
}
