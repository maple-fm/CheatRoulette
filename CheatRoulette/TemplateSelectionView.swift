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
    var onSelect: (Template) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        onSelect(template) // 選択時の処理を呼び出す
                        dismiss() // 画面を閉じる
                    } label: {
                        HStack {
                            Text(template.name)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("テンプレートを選択")
        }
    }
}

#Preview {
    TemplateSelectionView() { _ in 
        print("")
    }
}
