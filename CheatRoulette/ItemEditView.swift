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
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("登録済みの項目")) {
                    List {
                        ForEach($items, id: \.id) { $item in
                            HStack {
                                TextField("項目名", text: $item.name)
                                
                                Button(role: .destructive) {
                                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                                        items.remove(at: index) // UI 上から削除
                                    }
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
        items.remove(atOffsets: offsets) // UI 上で削除
    }
}

#Preview {
    ItemEditView(items: .constant([
        Item(name: "サンプル1", startAngle: 0, endAngle: 0, color: .red),
        Item(name: "サンプル2", startAngle: 0, endAngle: 0, color: .blue)
    ]))
}
