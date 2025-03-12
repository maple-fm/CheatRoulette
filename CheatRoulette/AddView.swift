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
    @State private var addedItems: [Item] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("追加された項目")) {
                    List($addedItems, id: \.id) { $item in
                        TextField("項目名", text: $item.name)
                    }
                }
                
                Button("追加") {
                    // 新規項目を作成し、即座に modelContext に挿入する
                    let newItem = Item(name: "\(addedItems.count + 1)", startAngle: 0, endAngle: 0, color: .random())
                    modelContext.insert(newItem)
                    addedItems.append(newItem)
                }
                
                Button("テンプレートとして保存") {
                    let template = Template(name: "新しいテンプレート", items: Array(addedItems))
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
                        // ここでは既に modelContext に挿入済みのため、
                        // ユーザーが編集した名前もそのまま反映される
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        // キャンセル時には、追加した項目を削除することも可能
                        for item in addedItems {
                            modelContext.delete(item)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddView()
}
