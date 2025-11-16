//
//  AstronomicalNewsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct AstronomicalNewsView: View {
    @StateObject private var viewModel = AstronomicalNewsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Sort State
    @State private var sortOption: SortOption = .newest
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case alphabeticalAsc = "A → Z"
        case alphabeticalDesc = "Z → A"
        
        var systemImage: String {
            switch self {
            case .newest: return "clock.arrow.circlepath"
            case .alphabeticalAsc: return "text.alignleft"
            case .alphabeticalDesc: return "text.alignright"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("BlackBG2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.news.isEmpty {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text(LanguageManager.current.string("loading_news"))
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.sortedNews(sortBy: sortOption).indices, id: \.self) { index in
                                    let apod = viewModel.sortedNews(sortBy: sortOption)[index]
                                    NewsCardView(
                                        apod: apod,
                                        isNewest: index == 0 && sortOption == .newest,
                                        viewModel: viewModel
                                    )
                                }
                                
                                // Show More Button
                                if !viewModel.news.isEmpty {
                                    Button {
                                        Task {
                                            await viewModel.loadMoreNews()
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            if viewModel.isLoadingMore {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                                    .tint(.white)
                                            } else {
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .font(.title3)
                                            }
                                            Text(viewModel.isLoadingMore ? LanguageManager.current.string("loading") : LanguageManager.current.string("show_more"))
                                                .font(.headline)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .disabled(viewModel.isLoadingMore)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle(LanguageManager.current.string("astronomical_news"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Nút Sort
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    withAnimation(.easeInOut) {
                                        sortOption = option
                                    }
                                } label: {
                                    Label(option.rawValue, systemImage: option.systemImage)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: sortOption.systemImage)
                                .font(.title3)
                                .foregroundColor(.white)
                                .labelStyle(IconOnlyLabelStyle())
                        }
                        .menuStyle(BorderlessButtonMenuStyle())
                        .animation(.easeInOut, value: sortOption)
                        
                        // Nút Chuông - Notification
                        Button {
                            // Link to notification setting (tích hợp sau)
                            print("Notification settings")
                        } label: {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: LanguageManager.current.string("search_news"))
        }
        .onAppear {
            Task {
                await viewModel.fetchNews()
            }
        }
        .onChange(of: sortOption) { _,_ in
            viewModel.objectWillChange.send()
        }
        .preferredColorScheme(.dark)
    }
}

// News Card Component
struct NewsCardView: View {
    let apod: APOD
    let isNewest: Bool
    @ObservedObject var viewModel: AstronomicalNewsViewModel
    
    var body: some View {
        NavigationLink(destination: NewsDetailView(apod: apod, viewModel: viewModel)) {
            HStack(spacing: 14) {
                // Image
                AsyncImage(url: URL(string: apod.url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(apod.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        
                        if isNewest {
                            Text("(New)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(apod.date)
                            .font(.caption)
                    }
                    .foregroundColor(.blue.opacity(0.8))
                    
                    Text(apod.explanation)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                
                Spacer()
            }
            .padding(12)
            .frame(height: 130)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexFull: "1a1f3a").opacity(0.8),
                                Color(hexFull: "0a0e27").opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

// Color Extension
extension Color {
    init(hexFull: String) {
        let hex = hexFull.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255) //Trắng :3
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ViewModel Extension for Sorting
extension AstronomicalNewsViewModel {
    func sortedNews(sortBy option: AstronomicalNewsView.SortOption) -> [APOD] {
        let filtered = filteredNews
        
        switch option {
        case .newest:
            return filtered.sorted { $0.date > $1.date }
        case .alphabeticalAsc:
            return filtered.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .alphabeticalDesc:
            return filtered.sorted { $0.title.lowercased() > $1.title.lowercased() }
        }
    }
}

#Preview {
    AstronomicalNewsView()
}
