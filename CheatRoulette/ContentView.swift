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
        ZStack {
            Button(action: {
                viewModel.isMuted.toggle()
            }) {
                Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title)
                    .padding()
                    .foregroundStyle(.black)
            }
            .position(x: width - 30, y: 45)
            
            VStack {
                
                Spacer()
                
                if viewModel.title.isEmpty {
                    Text("名称未設定")
                        .font(.title)
                        .padding(.bottom, 25)
                    
                } else {
                    Text(viewModel.title)
                        .font(.title)
                        .padding(.bottom, 25)
                }
                
                ZStack {
                    ZStack {
                        // ルーレット
                        if viewModel.items.isEmpty {
                            Circle()
                                .foregroundStyle(Color("Empty"))
                                .frame(width: 303, height: 303)
                        } else {
                            RouletteWheel(items: viewModel.items, rotation: viewModel.rotation)
                                .frame(width: 303, height: 303)
                        }
                        
                        // 🎯 ルーレットの中央にボタンを配置
                        Button(action: {
                            viewModel.startSpinning()
                            
                        }) {
                            Text("START")
                                .font(.system(size: 36))
                                .frame(width: 160, height: 160)
                                .background(Color("Background"))
                                .cornerRadius(999)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // 矢印
                    Triangle()
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                        .offset(y: -160) // ルーレットの上に配置
                }
                
                // 選ばれた項目ラベル
                if let result = viewModel.selectedItem {
                    Text("結果: \(result)")
                        .font(.title)
                        .padding()
                } else {
                    Text("")
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                // データ追加ボタン
                Button("データをセット") {
                    showOptions = true
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(UIColor.systemGray4))
                .foregroundColor(.black)
                
            }
            .confirmationDialog("データをセット", isPresented: $showOptions, titleVisibility: .visible) {
                Button("新規追加") {
                    isShowingNewItemView = true
                }
                
                if !viewModel.items.isEmpty {
                    Button("編集する") {
                        isShowingEditView = true
                    }
                }
                
                Button("テンプレートを開く") {
                    isSelectingTemplate = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $isShowingNewItemView) {
                AddView(items: $viewModel.items, rouletteName: .constant(""), cheatedID: $viewModel.cheatItemID)
            }
            .sheet(isPresented: $isSelectingTemplate) {
                TemplateSelectionView { selectedTemplate in
                    viewModel.applyTemplate(selectedTemplate)
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                ItemEditView(items: $viewModel.items, riggedItemID: $viewModel.cheatItemID, rouletteName: $viewModel.title)
            }
        }
    }
}

#Preview {
    ContentView()
}
