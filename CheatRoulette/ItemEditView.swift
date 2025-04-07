//
//  ItemEditView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/11.
//

import SwiftUI
import SwiftData

struct ItemEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var items: [Item] // @Binding で UI 上のリストを編集
    @Binding var riggedItemID: UUID? // インチキする項目のID
    @Binding var rouletteName: String
    
    @State private var showSaveAlert = false // アラート表示用
    @State  var showCancelAlert = false // キャンセル確認のポップアップ
    @State  var shouldSaveAsTemplate = false // 🔥 チェックボックスの状態
    
    var body: some View {
        VStack {
            // 🔥 ヘッダー部分
            HStack {
                
                Spacer()
                TextField("名称未設定", text: $rouletteName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                Spacer()
                Button("Set") {
                    
                    if shouldSaveAsTemplate { // 🔥 チェックが入っていたらテンプレート保存
                        saveTemplate()
                    }
                    dismiss()
                }
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            
            List {
                ForEach(items) { item in
                    HStack {
                        
                        // インチキ項目を選択するラジオボタン
                        Button(action: {
                            if riggedItemID == item.id {
                                riggedItemID = nil // すでに選択済みなら解除
                            } else {
                                riggedItemID = item.id
                            }
                        }) {
                            Image(systemName: riggedItemID == item.id ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                        }
                        
                        TextField("項目名", text: Binding(
                            get: { item.name },
                            set: { item.name = $0 }
                        ))
                        
                        Spacer()
                        
                        // 比率入力フィールドの追加
                        VStack {
                            Text("比率:")
                                .font(.footnote)
                            
                            TextField("1", value: Binding(
                                get: { item.ratio },
                                set: { newValue in
                                    // 比率が1〜99の範囲に収まるように制限
                                    if newValue < 1 {
                                        item.ratio = 1
                                    } else if newValue > 99 {
                                        item.ratio = 99
                                    } else {
                                        item.ratio = newValue
                                    }
                                }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    .onDelete(perform: deleteItem) // スワイプ削除
                }
                
                // 🔥 下部の「テンプレートに登録」
                HStack {
                    Text("テンプレートに登録")
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: { shouldSaveAsTemplate.toggle() }) {
                        Image(systemName: shouldSaveAsTemplate ? "checkmark.square.fill" : "square")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }
                .frame(height: 50)
                .background(Color.red)
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = items[index]
            if riggedItemID == itemToDelete.id {
                riggedItemID = nil // インチキ対象を削除したら解除
            }
            items.remove(at: index)
        }
    }
    
    private func saveTemplate() {
        guard !rouletteName.isEmpty else { return }
        
        // SwiftData に保存するため、新しい Item インスタンスを作成
        let copiedItems = items.map { item in
            let newItem = Item(name: item.name, ratio: item.ratio, startAngle: item.startAngle, endAngle: item.endAngle)
            modelContext.insert(newItem)
            return newItem
        }
        
        let template = Template(name: rouletteName, items: copiedItems)
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("保存エラー: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ItemEditView(items: .constant([
        Item(name: "サンプル1", ratio: 1, startAngle: 0, endAngle: 0),
        Item(name: "サンプル2", ratio: 1, startAngle: 0, endAngle: 0)
    ]), riggedItemID: .constant(UUID()), rouletteName: .constant("テンプレート"))
}
