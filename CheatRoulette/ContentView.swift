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
    @State private var items: [Item] = [] // データベースには保存せず、UI上のみで管理
    @Query private var templates: [Template]
    @State private var selectedTemplate: Template?
    
    @State private var rotation: Double = 0
    @State private var selectedItem: String = "選ばれた項目名"
    @State private var isCheatMode: Bool = false // インチキモード
    @State private var isSpinning: Bool = false // ルーレットが回転中かどうかを管理
    @State private var isShowingNewItemView = false
    @State private var isShowingEditView = false
    @State private var isSelectingTemplate = false // テンプレート選択画面の表示管理
    
    @State private var riggedItemID: UUID? // インチキする項目のID
    
    
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
                        startSpinning()
                        
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
                isShowingNewItemView = true
            }
            .padding()
            .sheet(isPresented: $isShowingNewItemView) {
                AddView(items: $items)
            }
            
            Button("項目を編集する") {
                isShowingEditView = true
            }
            .padding()
            .sheet(isPresented: $isShowingEditView) {
                ItemEditView(items: $items, riggedItemID: $riggedItemID)
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
    
    private func startSpinning() {
        guard !isSpinning, !items.isEmpty else { return } // 空なら回さない
        isSpinning = true
        
        // 🎯 ルーレットの回転角をリセット
        if isCheatMode {
            rotation = 0
        }
        let baseRotation: Double = Double.random(in: 770...1440) // 最低4回転
        let duration: TimeInterval = Double.random(in: 4.0...9.0) // 4〜9秒のランダム時間
        let steps = 100 // 減速ステップ数
        
        let startRotation = rotation.truncatingRemainder(dividingBy: 360) // 現在の角度
        let targetRotation = calculateTargetRotation(baseRotation: baseRotation, startRotation: startRotation)
        
        applyRotationAnimation(duration: duration, steps: steps, targetRotation: targetRotation)
    }
    
    private func calculateTargetRotation(baseRotation: Double, startRotation: Double) -> Double? {
        guard isCheatMode, let riggedID = riggedItemID, let riggedItem = items.first(where: { $0.id == riggedID }) else {
            return nil
        }
        
        let targetAngle = Double.random(in: riggedItem.startAngle...riggedItem.endAngle)
        let adjustedTarget = (360 - (targetAngle + 90)).truncatingRemainder(dividingBy: 360)
        
        let cheatRotation = 1080.0 // 3回転
        let finalTarget = startRotation + cheatRotation + adjustedTarget
        
        return finalTarget
    }
    
    private func applyRotationAnimation(duration: TimeInterval, steps: Int, targetRotation: Double?) {
        let interval = duration / Double(steps)
        var currentStep = 0
        var currentRotation = rotation.truncatingRemainder(dividingBy: 360)
        let initialSpeed = (1080.0 / Double(steps)) * 5
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            let progress = Double(currentStep) / Double(steps)
            let speedFactor = calculateSpeedFactor(initialSpeed: initialSpeed, progress: progress)
            
            if let targetRotation = targetRotation {
                let remainingRotation = targetRotation - currentRotation
                
                if abs(remainingRotation) < 0.5 {
                    currentRotation = targetRotation
                    rotation = currentRotation.truncatingRemainder(dividingBy: 360)
                    timer.invalidate()
                    finalizeSelection()
                    isSpinning = false
                    return
                } else {
                    currentRotation += min(speedFactor, remainingRotation * 0.15)
                }
            } else {
                currentRotation += speedFactor
            }
            
            rotation = currentRotation.truncatingRemainder(dividingBy: 360)
            
            if currentStep >= steps {
                timer.invalidate()
                finalizeSelection()
                isSpinning = false
            }
            
            currentStep += 1
        }
    }
    
    private func calculateSpeedFactor(initialSpeed: Double, progress: Double) -> Double {
        return initialSpeed * (1.0 - pow(progress, 3))
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
        items.removeAll()
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
        items = template.items.map { item in
            Item(name: item.name, startAngle: 0, endAngle: 0, color: item.color) // 新しいItemとして作成
        }
    }
}

#Preview {
    ContentView()
}
