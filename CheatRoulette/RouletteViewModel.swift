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
    
    // MARK: - Published Properties
    
    @Published var items: [Item] = []
    @Published var selectedTemplate: Template?
    @Published var rotation: Double = 0
    @Published var selectedItem: String?
    @Published var isSpinning: Bool = false
    @Published var title: String = ""
    @Published var cheatItemID: UUID?
    @Published var isMuted: Bool = false
    
    // MARK: - Private Properties
    
    private var soundPlayer = SoundPlayer()
    
    private var isCheatMode: Bool {
        cheatItemID != nil
    }
    
    // MARK: - Public Methods
    
    func startSpinning() {
        guard !isSpinning, !items.isEmpty else { return }
        
        isSpinning = true
        updateItemAngles()
        soundPlayer.playDrumRoll(isMuted: isMuted)
        
        let spinDuration = isCheatMode ? 9.0 : 11.0
        let steps = isCheatMode ? 90 : 100
        
        if isCheatMode {
            rotation = 0
        }
        
        let startRotation = rotation.truncatingRemainder(dividingBy: 360)
        let targetRotation = calculateTargetRotation(startRotation: startRotation)
        
        let baseRotation = isCheatMode ? 360.0 * 2 : 360.0 * 3 // 3回転
        applyRotationAnimation(
            baseRotation: baseRotation,
            duration: spinDuration,
            steps: steps,
            targetRotation: targetRotation
        )
    }
    
    func applyTemplate(_ template: Template) {
        title = template.name
        items = template.items.map { item in
            Item(name: item.name, ratio: 1, startAngle: 0, endAngle: 0)
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateTargetRotation(startRotation: Double) -> Double? {
        guard isCheatMode,
              let riggedID = cheatItemID,
              let riggedItem = items.first(where: { $0.id == riggedID }) else {
            return nil
        }
        
        let randomAngle = Double.random(in: riggedItem.startAngle...riggedItem.endAngle)
        let adjustedTarget = (360 - (randomAngle + 90)).truncatingRemainder(dividingBy: 360)
        let cheatRotation = 1080.0 // 3回転
        return startRotation + cheatRotation + adjustedTarget
    }
    
    private func applyRotationAnimation(baseRotation: Double, duration: TimeInterval, steps: Int, targetRotation: Double?) {
        let interval = duration / Double(steps)
        var currentStep = 0
        let totalSteps = Double(steps)
        let startRotation = rotation.truncatingRemainder(dividingBy: 360)
        let endRotation = targetRotation ?? (startRotation + baseRotation)
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            let progress = Double(currentStep) / totalSteps
            
            // イージング関数（easeOut）を使う
            let easedProgress = 1 - pow(1 - progress, 3)
            
            let currentRotation = startRotation + (endRotation - startRotation) * easedProgress
            
            self.rotation = currentRotation.truncatingRemainder(dividingBy: 360)
            
            currentStep += 1
            
            if currentStep > steps {
                timer.invalidate()
                self.rotation = endRotation.truncatingRemainder(dividingBy: 360)
                self.finishSpin()
            }
        }
    }

    
    private func calculateSpeedFactor(initialSpeed: Double, progress: Double) -> Double {
        return initialSpeed * (1.0 - pow(progress, 3))
    }
    
    private func finishSpin() {
        finalizeSelection()
        isSpinning = false
        if !isCheatMode {
            soundPlayer.stop()
        }
    }
    
    private func finalizeSelection() {
        let finalRotation = rotation.truncatingRemainder(dividingBy: 360)
        let adjustedRotation = (finalRotation + 90).truncatingRemainder(dividingBy: 360)
        let correctedRotation = (360 - adjustedRotation).truncatingRemainder(dividingBy: 360)
        
        if let selected = items.first(where: { $0.startAngle <= correctedRotation && correctedRotation < $0.endAngle }) {
            selectedItem = selected.name
        } else {
            selectedItem = "選ばれた項目名"
        }
    }
    
    private func updateItemAngles() {
        let totalRatio = items.reduce(0) { $0 + $1.ratio }
        var currentStartAngle = 0.0
        
        for item in items {
            let segmentAngle = (item.ratio / totalRatio) * 360.0
            item.startAngle = currentStartAngle
            item.endAngle = currentStartAngle + segmentAngle
            currentStartAngle += segmentAngle
            
            try? modelContext.save()
        }
    }
}

// MARK: - SoundPlayer

private class SoundPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    func playDrumRoll(isMuted: Bool) {
        guard !isMuted, let data = NSDataAsset(name: "drumRoll")?.data else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            print("ドラムロールの再生に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
    }
}
