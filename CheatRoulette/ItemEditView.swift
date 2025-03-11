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
    @Query private var items: [Item] // 既存データを取得
    
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
                                
                                Button(role: .destructive) {
                                    modelContext.delete(item) // 削除
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
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
            modelContext.delete(itemToDelete)
        }
    }
}

#Preview {
    ItemEditView()
}
