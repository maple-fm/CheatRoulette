//
//  RouletteViewModel.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/18.
//

import SwiftUI
import SwiftData
import AVFoundation

class RouletteViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext
    
    @Published var items: [Item] = [] // データベースには保存せず、UI上のみで管理
    @Published var selectedTemplate: Template?
    
    @Published var rotation: Double = 0
    @Published var selectedItem: String?
    @Published var isSpinning: Bool = false // ルーレットが回転中かどうかを管理
    @Published var title: String = ""
    
    @Published var cheatItemID: UUID? // インチキする項目のID
    @Published var isMuted: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    
    var isCheatMode: Bool {
        return cheatItemID != nil
    }
    
    func startSpinning() {
        guard !isSpinning, !items.isEmpty else { return }
        isSpinning = true
        updateItemAngles()
        
        let spinDuration: Double = 11.0
        let steps = 100
        
        // ドラムロール再生開始
        playDrumRoll()
        
        // ルーレットの回転角をリセット（インチキモード用）
        if isCheatMode {
            rotation = 0
        }
        
        let startRotation = rotation.truncatingRemainder(dividingBy: 360)
        let targetRotation = calculateTargetRotation(startRotation: startRotation)
        
        let baseRotation: Double
        
        if isCheatMode {
            // インチキモード：固定回転数
            baseRotation = 360.0 * 3 // 3回転
        } else {
            // 通常モード：自由に回転数設定
            let spinCount = 7.0 // ここで好きな回転数に設定（例：8回転）
            baseRotation = 360.0 * spinCount
        }
        
        // アニメーションスタート（durationは常に11秒固定）
        applyRotationAnimation(baseRotation: baseRotation, duration: spinDuration, steps: steps, targetRotation: targetRotation)
    }

    
    private func calculateTargetRotation(startRotation: Double) -> Double? {
        guard isCheatMode, let riggedID = cheatItemID, let riggedItem = items.first(where: { $0.id == riggedID }) else {
            return nil
        }
        
        let targetAngle = Double.random(in: riggedItem.startAngle...riggedItem.endAngle)
        let adjustedTarget = (360 - (targetAngle + 90)).truncatingRemainder(dividingBy: 360)
        
        let cheatRotation = 1080.0 * 3 // 3回転
        let finalTarget = startRotation + cheatRotation + adjustedTarget
        
        return finalTarget
    }
    
    private func applyRotationAnimation(baseRotation: Double, duration: TimeInterval, steps: Int, targetRotation: Double?) {
        let interval = duration / Double(steps)
        var currentStep = 0
        var currentRotation = rotation.truncatingRemainder(dividingBy: 360)
        let initialSpeed = (baseRotation / Double(steps)) * 5  // ←ここ！
        
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
                self.audioPlayer?.stop() // ←ドラムロール停止！
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
    
    // ルーレットが回り始める時に角度を更新するメソッド
    private func updateItemAngles() {
        let totalRatio = items.reduce(0) { $0 + $1.ratio }
        var currentStartAngle = 0.0
        
        for (_, item) in items.enumerated() {
            // 各アイテムの角度を計算
            let segmentAngle = (item.ratio / totalRatio) * 360.0
            
            // startAngle と endAngle を計算
            let newStartAngle = currentStartAngle
            let newEndAngle = currentStartAngle + segmentAngle
            
            // アイテムの角度を更新
            item.startAngle = newStartAngle
            item.endAngle = newEndAngle
            
            // 次のアイテムの開始角度を設定
            currentStartAngle = newEndAngle
            
            // 更新を保存
            try? modelContext.save()
        }
    }
    
    func applyTemplate(_ template: Template) {
        title = template.name
        items = template.items.map { item in
            Item(name: item.name, ratio: 1, startAngle: 0, endAngle: 0)
        }
    }
    
    private func playDrumRoll() {
        guard !isMuted else { return }
        
        let musicData=NSDataAsset(name: "drumRoll")!.data
        
        do {
            audioPlayer = try AVAudioPlayer(data:musicData)
            audioPlayer?.play()
        } catch {
            print("ドラムロールの再生に失敗しました: \(error.localizedDescription)")
        }
    }
}
