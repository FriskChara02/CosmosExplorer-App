//
//  NASAApiService.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData

struct APOD: Codable, Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let explanation: String
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case title, url, explanation, date
    }
}

class NASAApiService {
    private let apiKey: String = "DEMO_KEY"  // THAY BẰNG KEY CỦA BẠN Ở ĐÂY - hoặc dùng DEMO_KEY
    
    private var cache: [APOD] = []
    private var lastFetch: Date?
    private let cacheDuration: TimeInterval = 3600 // 1 giờ
    
    func fetchAPOD(count: Int = 10) async throws -> [APOD] {
        let now = Date()
        
        if let lastFetch = lastFetch,
           now.timeIntervalSince(lastFetch) < cacheDuration,
           !cache.isEmpty {
            print("Using cached APOD data")
            return cache
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        guard let startDate = calendar.date(byAdding: .day, value: -(count - 1), to: today) else {
            throw URLError(.badURL)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDateStr = dateFormatter.string(from: startDate)
        let endDateStr = dateFormatter.string(from: today)
        
        var components = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "start_date", value: startDateStr),
            URLQueryItem(name: "end_date", value: endDateStr)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            let limit = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit") ?? "N/A"
            let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining") ?? "N/A"
            print("Rate Limit: \(remaining)/\(limit)")
        }
        
        let apods = try JSONDecoder().decode([APOD].self, from: data)
        
        let sortedApods = apods.sorted { $0.date > $1.date }
        
        cache = sortedApods
        lastFetch = now
        
        return sortedApods
    }
    
    func fetchMoreAPOD(count: Int = 10, beforeDate: String) async throws -> [APOD] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let endDate = dateFormatter.date(from: beforeDate) else {
            throw URLError(.badURL)
        }
        
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -count, to: endDate) else {
            throw URLError(.badURL)
        }
        
        let startDateStr = dateFormatter.string(from: startDate)
        guard let adjustedEndDate = calendar.date(byAdding: .day, value: -1, to: endDate) else {
            throw URLError(.badURL)
        }
        let endDateStr = dateFormatter.string(from: adjustedEndDate)
        
        var components = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "start_date", value: startDateStr),
            URLQueryItem(name: "end_date", value: endDateStr)
        ]
        
        guard let url = components.url else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let apods = try JSONDecoder().decode([APOD].self, from: data)
        
        return apods.sorted { $0.date > $1.date }
    }
}
