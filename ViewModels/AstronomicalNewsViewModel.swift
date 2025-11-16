//
//  AstronomicalNewsViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 14/11/25.
//

import Foundation
import UIKit
import Combine

@MainActor
class AstronomicalNewsViewModel: ObservableObject {
    // MARK: - News Properties
    @Published var news: [APOD] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    
    // MARK: - Private
    private let apiService = NASAApiService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var filteredNews: [APOD] {
        if searchText.isEmpty {
            return news
        } else {
            return news.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.explanation.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // MARK: - Init
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - News Functions
    
    func fetchNews() async {
        isLoading = true
        errorMessage = nil
        do {
            news = try await apiService.fetchAPOD(count: 10)
        } catch {
            errorMessage = "Lỗi fetch NASA API: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func loadMoreNews() async {
        guard let oldestDate = news.last?.date else { return }
        
        isLoadingMore = true
        errorMessage = nil
        
        do {
            let moreNews = try await apiService.fetchMoreAPOD(count: 10, beforeDate: oldestDate)
            
            let uniqueNews = moreNews.filter { newApod in
                !news.contains { existingApod in
                    existingApod.title == newApod.title
                }
            }
            
            news.append(contentsOf: uniqueNews)
        } catch {
            errorMessage = "Lỗi tải thêm: \(error.localizedDescription)"
        }
        
        isLoadingMore = false
    }
    
    // Func copy link
    func copyLink(apod: APOD) {
        let articleText = """
        [News] \(apod.title)
        
        [Date] Date: \(apod.date)
        
        [Content]:
        \(apod.explanation)
        
        [Image URL]: \(apod.url)
        
        ---
        Shared from CosmosExplorer [Moon]
        """
        
        UIPasteboard.general.string = articleText
        // Có thể add alert: "Link copied!"
    }
    
    // Func share to Google Calendar: // NOTE: Cần tích hợp Google SignIn và Google Calendar API
    // 1. Install GoogleSignIn pod hoặc SPM.
    // 2. Config Google API Console: Enable Calendar API, tạo OAuth credentials.
    // 3. Trong app: GIDSignIn.sharedInstance.signIn() để auth.
    // 4. Sử dụng Google APIs Client Library for Swift để add event.
    // Ví dụ pseudocode:
    // let event = GTLRCalendar_Event()
    // event.summary = apod.title
    // event.description = "Miêu tả tự điền" + apod.explanation
    // event.start = ... (chọn date)
    // event.colorId = "1" // Chọn màu (1-11 cho colors)
    // service.events.insert(event, calendarId: "primary")
    func shareToCalendar(apod: APOD) {
        // TODO: Implement sau khi có Google auth
        print("Share to Calendar: \(apod.title)")
    }
}
