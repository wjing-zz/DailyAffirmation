//
//  SavedCard.swift
//  DailyAffirmation
//
//  Created by Jane Wang on 2025/9/18.
//

import Foundation

// 定义一个用于本地存储的数据模型
struct SavedCard: Codable, Identifiable {
    let id = UUID() // 用于在列表中唯一标识
    let date: Date
    let quote: Quote
    let universeReply: UniverseReply?
}
