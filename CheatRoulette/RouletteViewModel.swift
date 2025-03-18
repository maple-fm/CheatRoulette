//
//  RouletteViewModel.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/18.
//

import SwiftUI
import SwiftData

class RouletteViewModel: ObservableObject {
    @Published var items: [Item] = [] // データベースには保存せず、UI上のみで管理
    @Published var selectedTemplate: Template?
    
    @Published var rotation: Double = 0
    @Published var selectedItem: String = "選ばれた項目名"
    @Published var isCheatMode: Bool = false // インチキモード
    @Published var isSpinning: Bool = false // ルーレットが回転中かどうかを管理
    
    @Published var riggedItemID: UUID? // インチキする項目のID
    
    func startSpinning() {
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
            let speedFactor = self.calculateSpeedFactor(initialSpeed: initialSpeed, progress: progress)
            
            if let targetRotation = targetRotation {
                let remainingRotation = targetRotation - currentRotation
                
                if abs(remainingRotation) < 0.5 {
                    currentRotation = targetRotation
                    self.rotation = currentRotation.truncatingRemainder(dividingBy: 360)
                    timer.invalidate()
                    self.finalizeSelection()
                    self.isSpinning = false
                    return
                } else {
                    currentRotation += min(speedFactor, remainingRotation * 0.15)
                }
            } else {
                currentRotation += speedFactor
            }
            
            self.rotation = currentRotation.truncatingRemainder(dividingBy: 360)
            
            if currentStep >= steps {
                timer.invalidate()
                self.finalizeSelection()
                self.isSpinning = false
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
}
