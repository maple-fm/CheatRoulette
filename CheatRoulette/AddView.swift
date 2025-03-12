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
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("追加された項目")) {
                    List($items, id: \.id) { $item in
                        TextField("項目名", text: $item.name)
                    }
                }
                
                Button("追加") {
                    let newItem = Item(name: "\(items.count + 1)", startAngle: 0, endAngle: 0, color: .random())
                    items.append(newItem) // UI 上のみで管理
                }
                
                Button("テンプレートとして保存") {
                    let copiedItems = items.map { item in
                        Item(name: item.name, startAngle: 0, endAngle: 0, color: item.color) // 新規 ID でコピー
                    }
                    let template = Template(name: "新しいテンプレート", items: copiedItems)
                    modelContext.insert(template)
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print("保存エラー: \(error.localizedDescription)")
                    }
                }
            }
            .navigationTitle("項目を追加")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddView(items: .constant([]))
}
