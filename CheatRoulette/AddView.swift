//
//  AddView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/11.
//

import SwiftUI

struct AddView: View {
    @StateObject var viewModel: AddViewModel = AddViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var items: [Item]
    @Binding var rouletteName: String
    @Binding var cheatedID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔥 ヘッダー部分
            HStack {
  
                Spacer()
                TextField("名称未設定", text: $rouletteName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                Spacer()
                Button("Set") {
                    if !viewModel.tempItems.isEmpty {
                        items = viewModel.tempItems
                    }
                    
                    if viewModel.shouldSaveAsTemplate { // 🔥 チェックが入っていたらテンプレート保存
                        saveTemplate()
                    }
                    
                    dismiss()
                }
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            
            // 🔥 追加した項目リスト
            List {
                ForEach($viewModel.tempItems, id: \.id) { $item in
                    HStack {
                        TextField("項目名", text: $item.name)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        // 比率入力フィールドの追加
                        VStack {
                            Text("比率:")
                                .font(.footnote)
                            
                            TextField("1", value: $item.ratio, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: item.ratio) { newValue in
                                    // 比率が1〜99の範囲内か確認
                                    if newValue < 1 {
                                        item.ratio = 1
                                    } else if newValue > 99 {
                                        item.ratio = 99
                                    }
                                }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            cheatedID = (cheatedID == item.id) ? nil : item.id
                        }) {
                            Image(systemName: cheatedID == item.id ? "largecircle.fill.circle" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            
            // 🔥 下部の「テンプレートに登録」
            HStack {
                Text("テンプレートに登録")
                    .foregroundColor(.white)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: { viewModel.shouldSaveAsTemplate.toggle() }) {
                    Image(systemName: viewModel.shouldSaveAsTemplate ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
            .frame(height: 50)
            .background(Color.red)
            
            // 🔥 「項目を追加」ボタン
            Button(action: {
                let newItem = Item(name: "\(viewModel.tempItems.count + 1)", ratio: 1, startAngle: 0, endAngle: 0, color: .random())
                viewModel.tempItems.append(newItem) // UI 上のみで管理
            }) {
                Text("項目を追加")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray4))
                    .foregroundColor(.black)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true) // ヘッダーをカスタムしたため非表示
        .alert("変更を破棄しますか？", isPresented: $viewModel.showCancelAlert) {
            Button("破棄", role: .destructive) { dismiss() }
            Button("キャンセル", role: .cancel) { }
        }
    }
    
    private func saveTemplate() {
        guard !rouletteName.isEmpty else { return }
        
        let copiedItems = viewModel.tempItems.map { item in
            Item(name: item.name, ratio: item.ratio, startAngle: item.startAngle, endAngle: item.endAngle, color: item.color)
        }
        
        // テンプレートを作成して SwiftData に登録
        let template = Template(name: rouletteName, items: copiedItems)
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            items = viewModel.tempItems
            dismiss()
        } catch {
            print("保存エラー: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddView(items: .constant([]), rouletteName: .constant("タイトル"), cheatedID: .constant(nil))
}
