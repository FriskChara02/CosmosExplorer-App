//
//  RanksView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 27/11/25.
//

import SwiftUI
import PostgresClientKit

// MARK: - Main View
struct RanksView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RanksViewModel()
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                Image("BlackBG2")
                    .resizable()
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.3),
                        Color.clear,
                        Color.blue.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // MARK: - Header
                HeaderView(onBack: { dismiss() })
                
                // MARK: - Trophy Carousel
                TrophyCarouselView(trophies: vm.trophyData)
                    .padding(.vertical, 8)
                
                // MARK: - Current Rank Button
                CurrentRankButtonView(vm: vm)
                
                // MARK: - Users List
                UsersListView(vm: vm)
            }
        }
        .navigationBarHidden(true)
        .task {
            await vm.fetchInitialData()
        }
    }
}

// MARK: - Header View
private struct HeaderView: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("🏆 LEADERBOARD")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// MARK: - Trophy Carousel View
private struct TrophyCarouselView: View {
    let trophies: [Trophy]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 18) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(trophies.enumerated()), id: \.element.id) { index, trophy in
                        TrophyCardView(
                            trophy: trophy,
                            isSelected: index == selectedIndex
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal, 35)
                .padding(.vertical, 35)
            }
            
            // Trophy indicators
            HStack(spacing: 8) {
                ForEach(Array(trophies.enumerated()), id: \.element.id) { index, _ in
                    Capsule()
                        .fill(index == selectedIndex ? Color.yellow : Color.white.opacity(0.3))
                        .frame(width: index == selectedIndex ? 20 : 8, height: 4)
                        .animation(.spring(response: 0.3), value: selectedIndex)
                }
            }
            .padding(.top, 0)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

// MARK: - Trophy Card View
private struct TrophyCardView: View {
    let trophy: Trophy
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Trophy image
            ZStack {
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                }
                
                Image(trophy.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isSelected ? 100 : 85, height: isSelected ? 120 : 105)
                    .shadow(color: .yellow.opacity(isSelected ? 0.5 : 0), radius: 20)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            
            // Title with badge
            Text(trophy.title)
                .font(.system(size: isSelected ? 18 : 16, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .yellow : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isSelected
                                ? [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]
                                : [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Current Rank Button View
private struct CurrentRankButtonView: View {
    @ObservedObject var vm: RanksViewModel
    
    var body: some View {
        if let currentRank = vm.currentUserRank, currentRank > 20 {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    vm.scrollToCurrentUser()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your current rank")
                            .font(.caption)
                            .opacity(0.9)
                        Text("TOP \(currentRank)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.down.circle")
                        .font(.title3)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.5), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Users List View
private struct UsersListView: View {
    @ObservedObject var vm: RanksViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(vm.users.enumerated()), id: \.element.id) { index, user in
                    UserRankRowView(index: index, user: user)
                        .id(index)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                }
                
                // Show More Button
                if vm.canLoadMore {
                    Button {
                        Task { await vm.loadMore() }
                    } label: {
                        HStack {
                            Spacer()
                            
                            if vm.isLoadingMore {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("More")
                                    .font(.headline)
                                
                                Image(systemName: "chevron.down")
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .onAppear {
                vm.scrollProxy = proxy
            }
        }
    }
}

// MARK: - User Rank Row View
private struct UserRankRowView: View {
    let index: Int
    let user: UserRank
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank indicator
            RankIndicatorView(index: index)
            
            // Avatar
            AvatarView(avatarURL: user.avatar, username: user.username)
            
            // User info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(user.username)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Image(trophyImageName(for: user.rank))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .offset(y: -2)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(user.rank) Elo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Score badge
            VStack(spacing: 4) {
                Text("\(user.score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange],
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("score")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.1))
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: index < 3
                        ? [Color.white.opacity(0.2), Color.white.opacity(0.1)]
                        : [Color.white.opacity(0.12), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: index < 3
                        ? [Color.yellow.opacity(0.5), Color.orange.opacity(0.3)]
                        : [Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: index < 3 ? 2 : 0
                )
        )
        .listRowBackground(Color.clear)
    }
}

private func trophyImageName(for rank: Int) -> String {
    switch rank {
    case 1800...: return "Trophy06"
    case 1600...: return "Trophy05"
    case 1400...: return "Trophy04"
    case 1200...: return "Trophy03"
    case 1000...: return "Trophy02"
    default:      return "Trophy01"
    }
}

// MARK: - Rank Indicator View
private struct RankIndicatorView: View {
    let index: Int
    
    var body: some View {
        ZStack {
            if index < 3 {
                // Top 3 trophy icons
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    getMedalColor(index).opacity(0.3),
                                    getMedalColor(index).opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image("Rank\(index + 1)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 60)
                }
            } else {
                // Regular rank number
                Text("\(index + 1)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
    }
    
    private func getMedalColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .clear
        }
    }
}

// MARK: - Avatar View
private struct AvatarView: View {
    let avatarURL: String?
    let username: String?
    
    var body: some View {
        AsyncImage(url: URL(string: avatarURL ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Text(String((username ?? "U").first ?? "U").uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: 42, height: 42)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - ViewModel
@MainActor
final class RanksViewModel: ObservableObject {
    @Published var users: [UserRank] = []
    @Published var currentUserRank: Int?
    @Published var canLoadMore = true
    @Published var isLoadingMore = false
    
    private var offset = 0
    private let limit = 20
    private var isLoading = false
    
    @State public var scrollProxy: ScrollViewProxy?
    
    let trophyData = [
        Trophy(id: 0, imageName: "Trophy01", title: "0+"),
        Trophy(id: 1, imageName: "Trophy02", title: "1000+"),
        Trophy(id: 2, imageName: "Trophy03", title: "1200+"),
        Trophy(id: 3, imageName: "Trophy04", title: "1400+"),
        Trophy(id: 4, imageName: "Trophy05", title: "1600+"),
        Trophy(id: 5, imageName: "Trophy06", title: "1800+")
    ]
    
    func fetchInitialData() async {
        offset = 0
        users.removeAll()
        canLoadMore = true
        
        await loadTop20()
        await loadCurrentUserRank()
    }
    
    private func loadTop20() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let connection = try DatabaseConfig.createConnection()
            defer { connection.close() }
            
            let text = """
            SELECT username, avatar, rank, score
            FROM users
            ORDER BY score DESC, rank DESC
            LIMIT $1 OFFSET $2
            """
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [limit, offset])
            defer { cursor.close() }
            
            var fetched: [UserRank] = []
            for row in cursor {
                let r = try row.get()
                let username = try r.columns[0].optionalString() ?? "Player"
                let avatar = try r.columns[1].optionalString()
                let rank = (try? r.columns[2].int()) ?? 0
                let score = (try? r.columns[3].int()) ?? 0
                
                fetched.append(UserRank(
                    id: UUID(),
                    username: username,
                    avatar: avatar,
                    rank: rank,
                    score: score
                ))
            }
            
            users = fetched
            offset += limit
            canLoadMore = fetched.count == limit
        } catch {
            print("Lỗi load rank: \(error)")
        }
    }
    
    func loadMore() async {
        guard canLoadMore, !isLoading else { return }
        isLoading = true
        isLoadingMore = true
        defer {
            isLoading = false
            isLoadingMore = false
        }
        
        do {
            let connection = try DatabaseConfig.createConnection()
            defer { connection.close() }
            
            let text = """
            SELECT username, avatar, rank, score
            FROM users
            ORDER BY score DESC, rank DESC
            LIMIT $1 OFFSET $2
            """
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [limit, offset])
            defer { cursor.close() }
            
            var fetched: [UserRank] = []
            for row in cursor {
                let r = try row.get()
                let username = try r.columns[0].optionalString() ?? "Player"
                let avatar = try r.columns[1].optionalString()
                let rank = (try? r.columns[2].int()) ?? 0
                let score = (try? r.columns[3].int()) ?? 0
                
                fetched.append(UserRank(
                    id: UUID(),
                    username: username,
                    avatar: avatar,
                    rank: rank,
                    score: score
                ))
            }
            
            users.append(contentsOf: fetched)
            offset += limit
            canLoadMore = fetched.count == limit
        } catch {
            print("Lỗi load more: \(error)")
        }
    }
    
    private func loadCurrentUserRank() async {
        guard let userId = AuthManager.shared.currentUserId else { return }
        
        do {
            let connection = try DatabaseConfig.createConnection()
            defer { connection.close() }
            
            let text = """
            SELECT COUNT(*) + 1
            FROM users
            WHERE score > (SELECT score FROM users WHERE id = $1)
               OR (score = (SELECT score FROM users WHERE id = $1) AND rank > (SELECT rank FROM users WHERE id = $1))
            """
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            if let row = try cursor.next()?.get(),
               let rank = try? row.columns[0].int() {
                currentUserRank = rank
            }
        } catch {
            print("Lỗi lấy rank hiện tại: \(error)")
        }
    }
    
    func scrollToCurrentUser() {
        guard let rank = currentUserRank, rank > 20 else { return }
        
        let targetIndex = rank - 1
        
        let neededOffset = (targetIndex / limit) * limit
        if offset <= neededOffset {
            Task {
                while offset <= neededOffset + limit {
                    await loadMore()
                }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    scrollProxy?.scrollTo(targetIndex, anchor: .center)
                }
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                scrollProxy?.scrollTo(targetIndex, anchor: .center)
            }
        }
    }
}

// MARK: - Models
struct Trophy: Identifiable {
    let id: Int
    let imageName: String
    let title: String
}

struct UserRank: Identifiable {
    let id: UUID
    let username: String
    let avatar: String?
    let rank: Int
    let score: Int
}

// MARK: - Preview
struct RanksView_Previews: PreviewProvider {
    static var previews: some View {
        RanksView()
    }
}
