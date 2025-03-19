//
//  AddViewModel.swift
//  CheatRoulette
//
//  Created by 出口楓真 on 2025/03/19.
//

import Foundation

class AddViewModel: ObservableObject {
    @Published  var showCancelAlert = false // キャンセル確認のポップアップ
    @Published  var tempItems: [Item] = [] // 編集用の一時データ
    @Published  var shouldSaveAsTemplate = false // 🔥 チェックボックスの状態
}
