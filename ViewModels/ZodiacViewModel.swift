//
//  ZodiacViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import Foundation
import Combine

@MainActor
class ZodiacViewModel: ObservableObject {
    @Published var horoscopes: [String: ZodiacModel] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - URLSession Configuration (TỐI ƯU TỐC ĐỘ)
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpMaximumConnectionsPerHost = 2
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
    
    // MARK: - Fetch All Horoscopes (TỐI ƯU TỐC ĐỘ)
    func fetchAllHoroscopes(day: String) async {
        isLoading = true
        errorMessage = nil
        horoscopes.removeAll()
        
        let signs = ZodiacModel.signs.map { $0.english.lowercased() }
        var successCount = 0
        var failCount = 0
        
        await withTaskGroup(of: Bool.self) { group in
            for (index, sign) in signs.enumerated() {
                group.addTask {
                    let success = await self.fetchHoroscopeWithRetry(sign: sign, day: day)
                    await MainActor.run {
                        if success { successCount += 1 } else { failCount += 1 }
                    }
                    if index < signs.count - 1 {
                        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
                    }
                    return success
                }
            }
            await group.waitForAll()
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Single Horoscope
    private func fetchHoroscopeWithRetry(sign: String, day: String, maxRetries: Int = 2) async -> Bool {
        guard let url = URL(string: "https://aztro.sameerkumar.website/?sign=\(sign)&day=\(day)") else {
            await fallback(sign: sign)
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        
        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    if attempt == maxRetries { await fallback(sign: sign) }
                    try? await backoffSleep(attempt)
                    continue
                }
                
                if httpResponse.statusCode == 503 {
                    #if DEBUG
                    print("\(sign.capitalized)✅")
                    #endif
                    await fallback(sign: sign)
                    return false
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if (400...499).contains(httpResponse.statusCode) {
                        await fallback(sign: sign)
                        return false
                    }
                    if attempt == maxRetries {
                        await fallback(sign: sign)
                        return false
                    }
                    try? await backoffSleep(attempt)
                    continue
                }
                
                let decoder = JSONDecoder()
                let zodiac = try decoder.decode(ZodiacModel.self, from: data)
                
                await MainActor.run {
                    horoscopes[sign] = zodiac
                }
                return true
                
            } catch {
                if attempt == maxRetries {
                    await fallback(sign: sign)
                    return false
                }
                try? await backoffSleep(attempt)
            }
        }
        return false
    }
    
    // MARK: - Backoff
    private func backoffSleep(_ attempt: Int) async throws {
        let delay = UInt64(min(pow(2.0, Double(attempt)) * 800_000_000, 3_000_000_000)) // max 3s
        try await Task.sleep(nanoseconds: delay)
    }
    
    // MARK: - Fallback
    private func fallback(sign: String) async {
        await MainActor.run {
            horoscopes[sign] = getHardcodedHoroscope(sign: sign)
        }
    }
    
    // MARK: - Hardcoded Horoscope
    func getHardcodedHoroscope(sign: String) -> ZodiacModel {
        let descriptions: [String: (vi: String, en: String)] = [
                "aries": (
                    vi: "Bạch Dương hôm nay tràn đầy năng lượng và nhiệt huyết. Sao Hỏa mang đến sức mạnh để vượt qua thử thách. Khởi đầu dự án mới là lựa chọn tốt. Kiểm soát sự nóng nảy.",
                    en: "Aries is full of energy and passion today. Mars gives strength to overcome challenges. Starting a new project is a good choice. Control impulsiveness."
                ),
                "taurus": (
                    vi: "Kim Ngưu được Kim tinh che chở. Tài chính và tình cảm ổn định. Đầu tư dài hạn là hợp lý. Hãy tin vào trực giác và giữ vững lập trường.",
                    en: "Taurus is protected by Venus. Finance and love are stable. Long-term investments are wise. Trust your intuition and stay firm."
                ),
                "gemini": (
                    vi: "Song Tử giao tiếp xuất sắc nhờ Thủy tinh. Thuyết phục dễ dàng, ý tưởng sáng tạo bùng nổ. Mở rộng quan hệ và chia sẻ kiến thức.",
                    en: "Gemini communicates excellently thanks to Mercury. Persuasion is easy, creative ideas explode. Expand relationships and share knowledge."
                ),
                "cancer": (
                    vi: "Cự Giải nhạy cảm và trực giác mạnh. Chăm sóc bản thân và gia đình. Cảm xúc là nguồn cảm hứng. Lắng nghe trái tim.",
                    en: "Cancer is sensitive and intuitive. Take care of yourself and family. Emotions are a source of inspiration. Listen to your heart."
                ),
                "leo": (
                    vi: "Sư Tử tỏa sáng, thu hút mọi ánh nhìn. Tự tin lãnh đạo, thể hiện tài năng. Đừng quên quan tâm người xung quanh.",
                    en: "Leo shines brightly, attracting all eyes. Lead with confidence, show your talent. Don’t forget to care for those around you."
                ),
                "virgo": (
                    vi: "Xử Nữ tỉ mỉ và logic. Tập trung cao độ, giải quyết vấn đề hiệu quả. Đừng quá khắt khe với bản thân.",
                    en: "Virgo is meticulous and logical. High focus, effective problem-solving. Don’t be too hard on yourself."
                ),
                "libra": (
                    vi: "Thiên Bình hài hòa và thẩm mỹ. Cân bằng quan hệ, giải quyết mâu thuẫn. Tận hưởng nghệ thuật và công bằng.",
                    en: "Libra is harmonious and aesthetic. Balance relationships, resolve conflicts. Enjoy art and fairness."
                ),
                "scorpio": (
                    vi: "Bọ Cạp sâu sắc và biến đổi. Nhìn thấu bản chất. Thực hiện thay đổi lớn. Kiểm soát sự chiếm hữu.",
                    en: "Scorpio is deep and transformative. See through the essence. Make big changes. Control possessiveness."
                ),
                "sagittarius": (
                    vi: "Nhân Mã lạc quan và phiêu lưu. Khám phá mới, học hỏi, du lịch. Theo đuổi đam mê tự do.",
                    en: "Sagittarius is optimistic and adventurous. Explore new things, learn, travel. Pursue freedom and passion."
                ),
                "capricorn": (
                    vi: "Ma Kết kiên trì và trách nhiệm. Xây dựng nền tảng vững chắc. Tiến độ chậm nhưng đúng hướng.",
                    en: "Capricorn is persistent and responsible. Build a solid foundation. Progress is slow but on the right track."
                ),
                "aquarius": (
                    vi: "Bảo Bình sáng tạo và nhân đạo. Chia sẻ ý tưởng mới, kết nối cộng đồng. Hãy là chính mình.",
                    en: "Aquarius is creative and humanitarian. Share new ideas, connect with the community. Be yourself."
                ),
                "pisces": (
                    vi: "Song Ngư giàu tưởng tượng và từ bi. Sáng tạo nghệ thuật, thiền định, giúp đỡ người khác. Bảo vệ năng lượng.",
                    en: "Pisces is imaginative and compassionate. Create art, meditate, help others. Protect your energy."
                )
            ]
        
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let signIndex = ZodiacModel.signs.firstIndex(where: { $0.english.lowercased() == sign }) ?? 0
        let seed = dayOfYear + signIndex
        
        let compatibilities = ["Cancer", "Taurus", "Virgo", "Scorpio", "Pisces", "Capricorn", "Leo", "Aries", "Gemini", "Aquarius", "Libra", "Sagittarius"]
        let times = ["7am", "9am", "11am", "2pm", "4pm", "6pm", "8pm", "10pm"]
        let colors = ["Spring Green", "Sky Blue", "Coral Pink", "Golden Yellow", "Lavender", "Ruby Red", "Mint Green", "Peach", "Turquoise", "Rose Gold", "Emerald", "Sapphire"]
        let moods = ["Relaxed", "Energetic", "Focused", "Creative", "Thoughtful", "Optimistic", "Confident", "Peaceful", "Ambitious", "Romantic", "Analytical", "Adventurous"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let currentDate = dateFormatter.string(from: Date())
        
        return ZodiacModel(
            currentDate: currentDate,
            compatibility: compatibilities[seed % compatibilities.count],
            luckyTime: times[seed % times.count],
            luckyNumber: String((seed * 7) % 99 + 1),
            color: colors[seed % colors.count],
            dateRange: getDateRange(for: sign),
            mood: moods[seed % moods.count],
            description: descriptions[sign]?.en ?? "Không có dự đoán."
        )
    }
    
    private func getDateRange(for sign: String) -> String {
        let ranges: [String: String] = [
            "aries": "Mar 21 - Apr 20",
            "taurus": "Apr 21 - May 21",
            "gemini": "May 22 - Jun 21",
            "cancer": "Jun 22 - Jul 22",
            "leo": "Jul 23 - Aug 23",
            "virgo": "Aug 24 - Sep 23",
            "libra": "Sep 24 - Oct 23",
            "scorpio": "Oct 24 - Nov 22",
            "sagittarius": "Nov 23 - Dec 21",
            "capricorn": "Dec 22 - Jan 20",
            "aquarius": "Jan 21 - Feb 19",
            "pisces": "Feb 20 - Mar 20"
        ]
        return ranges[sign] ?? "Jan 1 - Dec 31"
    }
}
