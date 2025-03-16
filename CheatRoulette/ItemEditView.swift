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
    @Binding var items: [Item] // @Binding で UI 上のリストを編集
    @Binding var riggedItemID: UUID? // インチキする項目のID
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("登録済みの項目")) {
                    List {
                        ForEach(items) { item in
                            HStack {
                                TextField("項目名", text: Binding(
                                    get: { item.name },
                                    set: { item.name = $0 }
                                ))
                                
                                Spacer()
                                
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
}

#Preview {
    ItemEditView(items: .constant([
        Item(name: "サンプル1", startAngle: 0, endAngle: 0, color: .red),
        Item(name: "サンプル2", startAngle: 0, endAngle: 0, color: .blue)
    ]), riggedItemID: .constant(UUID()))
}
