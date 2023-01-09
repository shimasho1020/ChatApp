//
//  ArrayExtentionFile.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/09.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}
