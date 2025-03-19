//
//  AddView.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/11.
//

import SwiftUI

struct AddView: View {
    @StateObject var viewModel: AddViewModel = AddViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var items: [Item]
    @Binding var rouletteName: String
    
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
                        Button(action: { viewModel.shouldSaveAsTemplate.toggle() }) {
                            Image(systemName: viewModel.shouldSaveAsTemplate ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.shouldSaveAsTemplate ? .blue : .gray)
                        }
                    }
                }
                
                Section(header: Text("追加された項目")) {
                    List($viewModel.tempItems, id: \.id) { $item in
                        TextField("項目名", text: $item.name)
                    }
                }
                
            }
            .navigationTitle("項目を追加")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        if !viewModel.tempItems.isEmpty {
                            items = viewModel.tempItems
                        }
                        
                        if viewModel.shouldSaveAsTemplate { // 🔥 チェックが入っていたらテンプレート保存
                            saveTemplate()
                        }
                        
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        if viewModel.tempItems.isEmpty {
                            dismiss()
                        } else {
                            viewModel.showCancelAlert = true
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) { // 下部ツールバーに追加
                    Button("追加") {
                        let newItem = Item(name: "\(viewModel.tempItems.count + 1)", startAngle: 0, endAngle: 0, color: .random())
                        viewModel.tempItems.append(newItem) // UI 上のみで管理
                    }
                    
                }
            }
            .alert("変更を破棄しますか？", isPresented: $viewModel.showCancelAlert) {
                Button("破棄", role: .destructive) { dismiss() }
                Button("キャンセル", role: .cancel) { }
            }
        }
    }
    
    private func saveTemplate() {
        guard !rouletteName.isEmpty else { return }
        
        let copiedItems = viewModel.tempItems.map { item in
            Item(name: item.name, startAngle: item.startAngle, endAngle: item.endAngle, color: item.color)
        }
        
        // テンプレートを作成して SwiftData に登録
        let template = Template(name: rouletteName, items: copiedItems)
        modelContext.insert(template)
        
        do {
            try modelContext.save()
            items = viewModel.tempItems
            dismiss()
        } catch {
            print("保存エラー: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddView(items: .constant([]), rouletteName: .constant("タイトル"))
}
