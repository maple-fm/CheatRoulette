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
    @Binding var rouletteName: String
    
    @State private var showCancelAlert = false // キャンセル確認のポップアップ
    @State private var tempItems: [Item] = [] // 編集用の一時データ
    @State private var shouldSaveAsTemplate = false // 🔥 チェックボックスの状態
    
    var body: some View {
        NavigationStack {
            Form {
                
                // 🔥 ルーレット名の入力フィールドを追加
                Section(header: Text("ルーレット名")) {
                    TextField("ルーレットの名前を入力", text: $rouletteName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // 🔥 チェックボックスの代わりにアイコンを切り替える
                Section {
                    HStack {
                        Text("テンプレートとして保存")
                        Spacer()
                        Button(action: { shouldSaveAsTemplate.toggle() }) {
                            Image(systemName: shouldSaveAsTemplate ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(shouldSaveAsTemplate ? .blue : .gray)
                        }
                    }
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
                        
                        if shouldSaveAsTemplate { // 🔥 チェックが入っていたらテンプレート保存
                            saveTemplate()
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
                
                ToolbarItem(placement: .bottomBar) { // 下部ツールバーに追加
                    Button("追加") {
                        let newItem = Item(name: "\(tempItems.count + 1)", startAngle: 0, endAngle: 0, color: .random())
                        tempItems.append(newItem) // UI 上のみで管理
                    }
                    
                }
            }
            .alert("変更を破棄しますか？", isPresented: $showCancelAlert) {
                Button("破棄", role: .destructive) { dismiss() }
                Button("キャンセル", role: .cancel) { }
            }
        }
    }
    
    private func saveTemplate() {
        guard !rouletteName.isEmpty else { return }
        
        let copiedItems = tempItems.map { item in
            Item(name: item.name, startAngle: item.startAngle, endAngle: item.endAngle, color: item.color)
        }
        
        // テンプレートを作成して SwiftData に登録
        let template = Template(name: rouletteName, items: copiedItems)
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
    AddView(items: .constant([]), rouletteName: .constant("タイトル"))
}
