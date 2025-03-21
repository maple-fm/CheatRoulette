//
//  ContentView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/02.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingNewItemView = false
    @State private var isShowingEditView = false
    @State private var isSelectingTemplate = false // テンプレート選択画面の表示管理
    @State private var showOptions = false
    
    @StateObject private var viewModel = RouletteViewModel()
    
    private let width = UIScreen.main.bounds.width - (15 * 2)
    
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
                            .frame(width: width, height: width)
                    } else {
                        RouletteWheel(items: viewModel.items, rotation: viewModel.rotation)
                            .frame(width: width, height: width)
                    }
                    
                    // 🎯 ルーレットの中央にボタンを配置
                    Button(action: {
                        viewModel.startSpinning()
                        
                    }) {
                       Text("Start")
                            .fontWeight(.bold)
                            .font(.system(size: 36))
                            .frame(width: width * (2 / 3), height: width * (2/3))
                            .background(.white)
                            .cornerRadius(999)
                    }
                    .buttonStyle(.plain)
                }
                
                // 矢印
                Triangle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                    .offset(y: -180) // ルーレットの上に配置
            }
            
            // 選ばれた項目ラベル
            if let result = viewModel.selectedItem {
                Text("結果: \(result)")
                    .font(.title)
                    .padding()
            }
            
            HStack {
                Text("インチキモード: ")
                
                Text(viewModel.isCheatMode ? "ON" : "OFF")
            }
            .padding()
            
            Spacer()
            
            // データ追加ボタン
            Button("データをセット") {
                showOptions = true
                viewModel.title = ""
            }
            .padding()
            
            
            Button("項目を編集する") {
                isShowingEditView = true
            }
            .padding()
            .sheet(isPresented: $isShowingEditView) {
                ItemEditView(items: $viewModel.items, riggedItemID: $viewModel.cheatItemID)
            }
        }
        .confirmationDialog("データをセット", isPresented: $showOptions, titleVisibility: .visible) {
            Button("新規追加") {
                isShowingNewItemView = true
            }
            Button("テンプレートを開く") {
                isSelectingTemplate = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $isShowingNewItemView) {
            AddView(items: $viewModel.items, rouletteName: $viewModel.title, cheatedID: $viewModel.cheatItemID)
        }
        .sheet(isPresented: $isSelectingTemplate) {
            TemplateSelectionView { selectedTemplate in
                viewModel.applyTemplate(selectedTemplate)
            }
        }
    }
}

#Preview {
    ContentView()
}
