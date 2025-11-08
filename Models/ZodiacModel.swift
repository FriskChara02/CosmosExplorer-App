//
//  ZodiacModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation

struct ZodiacModel: Codable, Identifiable {
    let id = UUID()
    let currentDate: String
    let compatibility: String
    let luckyTime: String
    let luckyNumber: String
    let color: String
    let dateRange: String
    let mood: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case currentDate = "current_date"
        case compatibility
        case luckyTime = "lucky_time"
        case luckyNumber = "lucky_number"
        case color
        case dateRange = "date_range"
        case mood
        case description
    }
    
    static let signs: [(vietnamese: String, english: String)] = [
        ("Bạch Dương", "aries"),
        ("Kim Ngưu", "taurus"),
        ("Song Tử", "gemini"),
        ("Cự Giải", "cancer"),
        ("Sư Tử", "leo"),
        ("Xử Nữ", "virgo"),
        ("Thiên Bình", "libra"),
        ("Thiên Yết", "scorpio"),
        ("Nhân Mã", "sagittarius"),
        ("Ma Kết", "capricorn"),
        ("Bảo Bình", "aquarius"),
        ("Song Ngư", "pisces")
    ]
}
