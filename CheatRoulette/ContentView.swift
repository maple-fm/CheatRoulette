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
    @State private var isShowingNewItemView = false
    @State private var isShowingEditView = false
    @State private var isSelectingTemplate = false // テンプレート選択画面の表示管理
    
    @StateObject private var viewModel = RouletteViewModel()
    
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(viewModel.title)
                .font(.title)
            
            ZStack {
                ZStack {
                    // ルーレット
                    if viewModel.items.isEmpty {
                        Circle()
                            .foregroundStyle(.gray)
                            .frame(width: 300, height: 300)
                    } else {
                        RouletteWheel(items: viewModel.items, rotation: viewModel.rotation)
                            .frame(width: 300, height: 300)
                    }
                    
                    // 🎯 ルーレットの中央にボタンを配置
                    Button(action: {
                        // アイテムの角度を更新する
                        updateItemAngles()
                        viewModel.startSpinning()
                        
                    }) {
                       Text("Start")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .frame(width: 150, height: 150)
                            .background(.white)
                            .cornerRadius(999)
                    }
                    .buttonStyle(.plain)
                }
                
                // 矢印
                Triangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                    .offset(y: -150) // ルーレットの上に配置
            }
            
            Spacer()
            
            // 選ばれた項目ラベル
            if let result = viewModel.selectedItem {
                Text("結果: \(result)")
                    .font(.title)
                    .padding()
            }
            
            HStack {
                Toggle("インチキモード", isOn: $viewModel.isCheatMode)
                    .padding()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            // データ追加ボタン
            Button("データを追加する") {
                isShowingNewItemView = true
                viewModel.title = ""
            }
            .padding()
            .sheet(isPresented: $isShowingNewItemView) {
                AddView(items: $viewModel.items, rouletteName: $viewModel.title)
            }
            
            Button("項目を編集する") {
                isShowingEditView = true
            }
            .padding()
            .sheet(isPresented: $isShowingEditView) {
                ItemEditView(items: $viewModel.items, riggedItemID: $viewModel.riggedItemID)
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
    
    private func removeAll() {
        viewModel.items.removeAll()
    }
    
    // ルーレットが回り始める時に角度を更新するメソッド
    private func updateItemAngles() {
        let segmentAngle = 360.0 / Double(viewModel.items.count)
        
        for (index, item) in viewModel.items.enumerated() {
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
        viewModel.title = template.name
        viewModel.items = template.items.map { item in
            Item(name: item.name, startAngle: 0, endAngle: 0, color: item.color) // 新しいItemとして作成
        }
    }
}

#Preview {
    ContentView()
}
