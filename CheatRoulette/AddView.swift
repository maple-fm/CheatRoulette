//
//  AddView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/11.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var items: [Item]
    
    @State private var showSaveAlert = false // ポップアップ表示状態
    @State private var templateName = "" // 入力されたテンプレート名
    
    @State private var showCancelAlert = false // キャンセル確認のポップアップ
    @State private var tempItems: [Item] = [] // 編集用の一時データ
    
    var body: some View {
        NavigationStack {
            Form {
                Button("追加") {
                    let newItem = Item(name: "\(tempItems.count + 1)", startAngle: 0, endAngle: 0, color: .random())
                    tempItems.append(newItem) // UI 上のみで管理
                }
                
                Button("テンプレートとして保存") {
                    templateName = "" // 初期化
                    showSaveAlert = true  // アラートを表示
                }
                
                Section(header: Text("追加された項目")) {
                    List($tempItems, id: \.id) { $item in
                        TextField("項目名", text: $item.name)
                    }
                }
                
            }
            .navigationTitle("項目を追加")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        if !tempItems.isEmpty {
                            items = tempItems
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        if tempItems.isEmpty {
                            dismiss()
                        } else {
                            showCancelAlert = true
                        }
                    }
                }
            }
            .alert("テンプレート名を入力", isPresented: $showSaveAlert) {
                TextField("テンプレート名", text: $templateName)
                Button("保存", action: saveTemplate)
                Button("キャンセル", role: .cancel) { }
            }
            .alert("変更を破棄しますか？", isPresented: $showCancelAlert) {
                Button("破棄", role: .destructive) { dismiss() }
                Button("キャンセル", role: .cancel) { }
            }
        }
    }
    
    private func saveTemplate() {
        guard !templateName.isEmpty else { return }
        
        let copiedItems = tempItems.map { item in
            Item(name: item.name, startAngle: item.startAngle, endAngle: item.endAngle, color: item.color)
        }
        
        // テンプレートを作成して SwiftData に登録
        let template = Template(name: templateName, items: copiedItems)
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            items = tempItems
            dismiss()
        } catch {
            print("保存エラー: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddView(items: .constant([]))
}
