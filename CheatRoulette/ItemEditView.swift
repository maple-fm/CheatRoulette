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
    
    @State private var showSaveAlert = false // アラート表示用
    @State private var templateName = "" // 入力されたテンプレート名
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("登録済みの項目")) {
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
                                
                                
                            }
                        }
                        .onDelete(perform: deleteItem) // スワイプ削除
                    }
                }
            }
            .navigationTitle("項目を編集")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) { // 下部ツールバーに追加
                    Button("テンプレートとして保存") {
                        templateName = ""
                        showSaveAlert = true
                    }
                }
            }
            .alert("テンプレート名を入力", isPresented: $showSaveAlert) {
                TextField("テンプレート名", text: $templateName)
                Button("保存", action: saveTemplate)
                Button("キャンセル", role: .cancel) { }
            }
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
        guard !templateName.isEmpty else { return }
        
        // SwiftData に保存するため、新しい Item インスタンスを作成
        let copiedItems = items.map { item in
            let newItem = Item(name: item.name, startAngle: item.startAngle, endAngle: item.endAngle, color: item.color)
            modelContext.insert(newItem)
            return newItem
        }
        
        let template = Template(name: templateName, items: copiedItems)
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
        Item(name: "サンプル1", startAngle: 0, endAngle: 0, color: .red),
        Item(name: "サンプル2", startAngle: 0, endAngle: 0, color: .blue)
    ]), riggedItemID: .constant(UUID()))
}
