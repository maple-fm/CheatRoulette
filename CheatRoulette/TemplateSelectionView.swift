//
//  TemplateSelectionView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/12.
//

import SwiftUI
import SwiftData

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var templates: [Template] // SwiftData からテンプレートを取得
    
    @Environment(\.modelContext) private var modelContext
    var onSelect: (Template) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        // 追加順を維持するために createdAt でソート
                        let sortedItems = template.items.sorted(by: { $0.createdAt < $1.createdAt })
                        
                        // 新しい Template インスタンスを作成
                        let sortedTemplate = Template(name: template.name, items: sortedItems)
                        
                        // onSelect に並び替えたテンプレートを渡す
                        onSelect(sortedTemplate)
                        dismiss() // 画面を閉じる
                    } label: {
                        HStack {
                            Text(template.name)
                            Spacer()
                        }
                    }
                }
                .onDelete(perform: deleteTemplate) // スワイプ削除を追加
            }
            .navigationTitle("テンプレートを選択")
        }
    }
    
    /// テンプレートを削除する処理
    private func deleteTemplate(at offsets: IndexSet) {
        for index in offsets {
            let templateToDelete = templates[index]
            modelContext.delete(templateToDelete) // SwiftData から削除
        }
        do {
            try modelContext.save() // データを保存
        } catch {
            print("削除エラー: \(error.localizedDescription)")
        }
    }
}

#Preview {
    TemplateSelectionView() { _ in 
        print("")
    }
}
