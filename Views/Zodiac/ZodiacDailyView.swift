//
//  ZodiacDailyView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import SwiftUI

struct ZodiacDailyView: View {
    @StateObject private var viewModel = ZodiacViewModel()
    @State private var selectedIndex = 0
    @AppStorage("favoriteSign") var favoriteSign: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var filteredSigns: [(index: Int, sign: (vietnamese: String, english: String))] {
        let query = searchText.lowercased().folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            return ZodiacModel.signs.enumerated().map { (index: $0.offset, sign: $0.element) }
        }
        
        return ZodiacModel.signs.enumerated().compactMap { index, sign in
            let viet = sign.vietnamese.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
            let eng = sign.english.lowercased()
            if viet.contains(query) || eng.contains(query) {
                return (index: index, sign: sign)
            }
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.clear
                .background(
                    Image("BlackBG")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.4), Color.purple.opacity(0.1)]),
                        startPoint: .top, endPoint: .bottom
                    )
                )
            
            VStack(spacing: 0) {
                headerView
                
                // Thanh tìm kiếm + kết quả
                if isSearching {
                    searchContent
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    tabViewContent
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchAllHoroscopes(day: "today")
                if let favIndex = ZodiacModel.signs.firstIndex(where: { $0.english == favoriteSign }) {
                    selectedIndex = favIndex
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "suit.heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                
                Text(LanguageManager.current.string("zodiac_love_title"))
                    .font(.custom("Audiowide", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            // Nút tìm kiếm / đóng
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if isSearching {
                        searchText = ""
                        isSearching = false
                    } else {
                        isSearching = true
                    }
                }
            }) {
                Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
        .background(
            Color.purple.opacity(0.2)
                .blur(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.purple.opacity(0.8), lineWidth: 1)
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Search Content
    private var searchContent: some View {
        VStack(spacing: 0) {
            searchBar
            searchResultsView
        }
        .padding(.top, 8)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField(LanguageManager.current.string("zodiac_search_placeholder"), text: $searchText)
                .foregroundColor(.white)
                .tint(.cyan)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 12) {
                if filteredSigns.isEmpty {
                    Text(LanguageManager.current.string("zodiac_search_no_results"))
                        .foregroundColor(.white.opacity(0.6))
                        .font(.headline)
                        .padding()
                } else {
                    ForEach(filteredSigns, id: \.index) { item in
                        let (index, sign) = item
                        zodiacSearchItem(sign: sign, index: index)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .frame(maxHeight: 500)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }
    
    // MARK: - TabView Content
    private var tabViewContent: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(ZodiacModel.signs.enumerated()), id: \.offset) { index, sign in
                let horoscope = viewModel.horoscopes[sign.english]
                let isFav = favoriteSign == sign.english
                DailyCard(
                    sign: sign,
                    horoscope: horoscope,
                    isFavorite: isFav,
                    toggleFav: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            favoriteSign = isFav ? "" : sign.english
                        }
                    },
                    isLoading: viewModel.isLoading,
                    errorMessage: viewModel.errorMessage
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(maxHeight: 600)
        .padding(.vertical, 10)
    }
    
    // MARK: - Search Item
    @ViewBuilder
    private func zodiacSearchItem(sign: (vietnamese: String, english: String), index: Int) -> some View {
        HStack(spacing: 12) {
            Image("\(sign.english)_chibi")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .shadow(color: .cyan.opacity(0.5), radius: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sign.vietnamese)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(sign.english)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: zodiacGradient(for: sign.english)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan.opacity(0.5), Color.purple.opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 6, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 15))
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedIndex = index
                searchText = ""
                isSearching = false
            }
        }
    }
    
    // Gradient cho Search Item
    private func zodiacGradient(for sign: String) -> [Color] {
        switch sign.lowercased() {
        case "aries": return [Color.red.opacity(0.4), Color.orange.opacity(0.3)]
        case "taurus": return [Color.green.opacity(0.4), Color.brown.opacity(0.3)]
        case "gemini": return [Color.yellow.opacity(0.4), Color.gray.opacity(0.3)]
        case "cancer": return [Color.blue.opacity(0.4), Color.teal.opacity(0.3)]
        case "leo": return [Color.orange.opacity(0.4), Color.yellow.opacity(0.3)]
        case "virgo": return [Color.green.opacity(0.4), Color.brown.opacity(0.3)]
        case "libra": return [Color.pink.opacity(0.4), Color.blue.opacity(0.3)]
        case "scorpio": return [Color.red.opacity(0.4), Color.black.opacity(0.3)]
        case "sagittarius": return [Color.purple.opacity(0.4), Color.blue.opacity(0.3)]
        case "capricorn": return [Color.brown.opacity(0.4), Color.gray.opacity(0.3)]
        case "aquarius": return [Color.blue.opacity(0.4), Color.cyan.opacity(0.3)]
        case "pisces": return [Color.teal.opacity(0.4), Color.green.opacity(0.3)]
        default: return [Color.purple.opacity(0.4), Color.blue.opacity(0.3)]
        }
    }
}

// MARK: - Daily Card
struct DailyCard: View {
    let sign: (vietnamese: String, english: String)
    let horoscope: ZodiacModel?
    let isFavorite: Bool
    let toggleFav: () -> Void
    let isLoading: Bool
    let errorMessage: String?
    
    var formattedDate: String {
        if let currentDate = horoscope?.currentDate {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MMMM d, yyyy"
            if let date = inputFormatter.date(from: currentDate) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "dd/MM/yyyy"
                return outputFormatter.string(from: date)
            }
        }
        return Date().formatted(.dateTime.day(.twoDigits).month(.twoDigits).year())
    }
    
    var body: some View {
        if isLoading {
            loadingView
        } else if let error = errorMessage {
            errorView(error)
        } else if let hor = horoscope {
            fullCard(hor: hor)
        } else {
            emptyView
        }
    }
    
    private var loadingView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: zodiacGradient(for: sign.english)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    .scaleEffect(1.5)
                
                Text(LanguageManager.current.string("zodiac_loading"))
                    .foregroundColor(.white.opacity(0.7))
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .padding(.horizontal, 16)
    }
    
    private func errorView(_ msg: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.3), Color.black.opacity(0.9)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 16) {
                Image("error_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                
                Text(msg)
                    .foregroundColor(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .padding(.horizontal, 16)
    }
    
    private var emptyView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: zodiacGradient(for: sign.english)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(LanguageManager.current.string("zodiac_no_data"))
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .padding(.horizontal, 16)
    }
    
    private func fullCard(hor: ZodiacModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: zodiacGradient(for: sign.english)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: zodiacGradient(for: sign.english)),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .purple.opacity(0.5), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image("\(sign.english)_chibi")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .shadow(color: .cyan.opacity(0.6), radius: 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sign.vietnamese)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                
                                Text(hor.dateRange)
                                    .font(.caption)
                                    .foregroundColor(.cyan.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.cyan.opacity(0.2)))
                            }
                        }
                        
                        Text("\(LanguageManager.current.string("zodiac_daily_prefix")) \(formattedDate)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 4)
                    }
                    
                    Spacer()
                    
                    Button(action: toggleFav) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isFavorite ? .pink : .white.opacity(0.6))
                            .shadow(color: isFavorite ? .pink.opacity(0.5) : .clear, radius: 10)
                    }
                    .buttonStyle(ScalebuttonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.cyan.opacity(0.5), Color.purple.opacity(0.5), Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 12) {
                            infoRow(label: LanguageManager.current.string("zodiac_compatibility"), value: hor.compatibility, icon: "heart.fill", color: .pink)
                            infoRow(label: LanguageManager.current.string("zodiac_lucky_time"), value: hor.luckyTime, icon: "clock.fill", color: .cyan)
                            infoRow(label: LanguageManager.current.string("zodiac_lucky_number"), value: hor.luckyNumber, icon: "dice.fill", color: .yellow)
                            infoRow(label: LanguageManager.current.string("zodiac_color"), value: hor.color, icon: "paintpalette.fill", color: .purple)
                            infoRow(label: LanguageManager.current.string("zodiac_mood"), value: hor.mood, icon: "face.smiling.fill", color: .green)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "books.vertical")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.cyan)
                                Text(LanguageManager.current.string("zodiac_detail_description"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text(hor.description)
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(8)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.cyan.opacity(0.2), lineWidth: 1))
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                Image("\(sign.english)_chibi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.15)
                    .offset(x: 110, y: 200)
                    .blur(radius: 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .padding(.horizontal, 16)
    }
    
    private func infoRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.2)).frame(width: 36, height: 36)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 16, weight: .semibold))
            }
            Text(label).foregroundColor(.white.opacity(0.8)).font(.callout)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .font(.callout.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(color.opacity(0.15)).overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1)))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }
    
    private func zodiacGradient(for sign: String) -> [Color] {
        switch sign.lowercased() {
        case "aries": return [Color.yellow.opacity(0.5), Color.orange.opacity(0.25)]
        case "taurus": return [Color.cyan.opacity(0.5), Color.teal.opacity(0.25)]
        case "gemini": return [Color.red.opacity(0.5), Color.orange.opacity(0.25)]
        case "cancer": return [Color.purple.opacity(0.5), Color.teal.opacity(0.25)]
        case "leo": return [Color.orange.opacity(0.5), Color.yellow.opacity(0.25)]
        case "virgo": return [Color.red.opacity(0.5), Color.brown.opacity(0.25)]
        case "libra": return [Color.green.opacity(0.5), Color.blue.opacity(0.25)]
        case "scorpio": return [Color.orange.opacity(0.5), Color.purple.opacity(0.25)]
        case "sagittarius": return [Color.purple.opacity(0.5), Color.blue.opacity(0.25)]
        case "capricorn": return [Color.orange.opacity(0.5), Color.gray.opacity(0.25)]
        case "aquarius": return [Color.teal.opacity(0.5), Color.cyan.opacity(0.25)]
        case "pisces": return [Color.blue.opacity(0.5), Color.green.opacity(0.25)]
        default: return [Color.purple.opacity(0.6), Color.blue.opacity(0.25)]
        }
    }
}

struct ScalebuttonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ZodiacDailyView()
}
