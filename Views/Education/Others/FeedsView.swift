//
//  FeedsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/11/25.
//

import SwiftUI

struct FeedItem: Identifiable {
    let id = UUID()
    let userId: UUID
    let username: String
    let avatar: String?
    let rank: Int
    let content: String
    let quizTitle: String
    let scorePercentage: Int
    let timestamp: Date
    let icon: String
    var likes: Int = 0
    var likedByUser = false
    var comments: [String] = []
}

struct FeedsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var feeds: [FeedItem] = []
    @State private var isLoading = true
    
    private let cuteIcons = [
        "moon.stars.fill", "sparkles", "wand.and.stars", "star.circle.fill",
        "cloud.moon.fill", "flame.fill", "bolt.fill", "leaf.fill",
        "heart.circle.fill", "gift.fill", "crown.fill", "rainbow"
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. GRADIENT
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.05, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 2. Floating particles effect
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header - back button + title
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.2), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    // Animated Title
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink.opacity(0.4), .purple.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .blur(radius: 8)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .symbolEffect(.pulse, options: .repeating)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activity Feed")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .pink.opacity(0.5), radius: 15, x: 0, y: 0)
                                
                                Text("Friends' achievements")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Content area
                    if isLoading {
                        Spacer(minLength: 100)
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.pink)
                            Text("Loading activities...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer(minLength: 100)
                    } else if feeds.isEmpty {
                        Spacer(minLength: 100)
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                Image(systemName: "star.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Text("No Activity Yet")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Complete quizzes to see activities here")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer(minLength: 100)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(feeds) { item in
                                FeedCardView(
                                    item: item,
                                    currentUserId: authViewModel.currentUser?.id ?? UUID()
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 40)
            }
        }
        .task {
            await loadRealFeeds()
        }
        .onChange(of: authViewModel.currentUser?.score) { _, _ in
            Task { await loadRealFeeds() }
        }
        .onAppear {
            Task { await loadRealFeeds() }
        }
    }
    
    // MARK: - Load Real Feeds
    private func loadRealFeeds() async {
        guard authViewModel.currentUser?.id != nil else {
            isLoading = false
            return
        }
        
        isLoading = true
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            isLoading = false
            return
        }
        defer { connection.close() }
        
        do {
            let query = """
            SELECT
                u.id, u.username, u.avatar, u.rank,
                a.correct_count::int, a.incorrect_count::int,
                a.last_updated,
                q.title AS quiz_title_server,
                a.id as attempt_id
            FROM attempts a
            JOIN users u ON a.user_id = u.id
            LEFT JOIN quizzes q ON a.quiz_id = q.id
            WHERE a.is_completed = true
              AND (
                a.user_id = $1                                          
                OR a.user_id IN (                                        
                    SELECT user_id2 FROM friendships WHERE user_id1 = $1
                    UNION
                    SELECT user_id1 FROM friendships WHERE user_id2 = $1
                )
              )
            ORDER BY a.last_updated DESC
            LIMIT 30
            """
            
            let statement = try connection.prepareStatement(text: query)
            let cursor = try statement.execute(parameterValues: [authViewModel.currentUser!.id.uuidString])
            var items: [FeedItem] = []
            
            for row in cursor {
                let r = try row.get()
                
                let userIdStr = try? r.columns[0].optionalString()
                let username = try? r.columns[1].optionalString()
                let avatar = try? r.columns[2].optionalString()
                let rank = try? r.columns[3].optionalInt()
                let correct = try? r.columns[4].optionalInt()
                let incorrect = try? r.columns[5].optionalInt()
                let dateStr = try? r.columns[6].optionalString()
                let quizTitleRaw = try? r.columns[7].optionalString()
                
                guard let userIdStr = userIdStr,
                      let userId = UUID(uuidString: userIdStr),
                      let username = username,
                      let correct = correct,
                      let incorrect = incorrect,
                      let dateStr = dateStr,
                      let date = parseFeedDate(dateStr)
                else {
                    continue
                }
                
                let quizTitle = quizTitleRaw ?? "Unknown Quiz"
                let total = correct + incorrect
                let percentage = total > 0 ? Int(Double(correct) / Double(total) * 100) : 0
                
                let content: String = {
                    let perfectMsgs = [
                        " just scored a perfect 100% on \"\(quizTitle)\"!",
                        " absolutely nailed 100% on \"\(quizTitle)\"!",
                        " crushed it with a flawless 100% in \"\(quizTitle)\"!",
                        " total domination – 100% on \"\(quizTitle)\"!",
                        " is a genius! Max score on \"\(quizTitle)\"!"
                    ]

                    let highMsgs = [
                        " smashed \"\(quizTitle)\" with an awesome \(percentage)%!",
                        " straight-up crushed \"\(quizTitle)\" – \(percentage)%!",
                        " destroyed \"\(quizTitle)\" with \(percentage)% accuracy!",
                        " too good! Scored \(percentage)% on \"\(quizTitle)\"!",
                        " went off – \(percentage)% on \"\(quizTitle)\"!"
                    ]

                    let goodMsgs = [
                        " just finished \"\(quizTitle)\" with \(percentage)%!",
                        " conquered \"\(quizTitle)\" scoring \(percentage)%!",
                        " completed \"\(quizTitle)\" – got \(percentage)%!",
                        " nice one! \(percentage)% on \"\(quizTitle)\"!",
                        " wrapped up \"\(quizTitle)\" with \(percentage)%!"
                    ]
                    
                    if percentage == 100 {
                        return perfectMsgs.randomElement()!
                    } else if percentage >= 90 {
                        return highMsgs.randomElement()!
                    } else {
                        return goodMsgs.randomElement()!
                    }
                }()
                
                items.append(FeedItem(
                    userId: userId,
                    username: username,
                    avatar: avatar,
                    rank: rank ?? 1000,
                    content: content,
                    quizTitle: quizTitle,
                    scorePercentage: percentage,
                    timestamp: date,
                    icon: cuteIcons.randomElement()!
                ))
            }
            
            print("Found \(items.count) feed items")
            
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.feeds = items
                    self.isLoading = false
                }
            }
            
        } catch {
            print("Lỗi load feeds: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

private func parseFeedDate(_ dateString: String) -> Date? {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [
        .withInternetDateTime,
        .withFractionalSeconds
    ]
    if let date = isoFormatter.date(from: dateString) {
        return date
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.date(from: dateString)
}

// MARK: - Modern Feed Card
struct FeedCardView: View {
    let item: FeedItem
    let currentUserId: UUID
    
    @State private var isLiked = false
    @State private var showComment = false
    @State private var commentText = ""
    @State private var showingProfileUserId: UUID?
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var trophyName: String {
        switch item.rank {
        case 1800...: return "Trophy06"
        case 1600...: return "Trophy05"
        case 1400...: return "Trophy04"
        case 1200...: return "Trophy03"
        case 1000...: return "Trophy02"
        default: return "Trophy01"
        }
    }
    
    private var scoreGradient: LinearGradient {
        switch item.scorePercentage {
        case 90...100:
            return LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        case 70..<90:
            return LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var timeAgo: String {
        let interval = Date().timeIntervalSince(item.timestamp)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Section
            HStack(spacing: 14) {
                Button {
                    showingProfileUserId = item.userId
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.4), .pink.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                            .blur(radius: 8)
                        
                        AsyncImage(url: URL(string: item.avatar ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.system(size: 22))
                                )
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                    }
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.username)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(trophyName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("\(item.rank)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.yellow.opacity(0.9))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.15))
                        )
                        
                        Text("• \(timeAgo)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.pulse, options: .repeating)
                }
            }
            .padding(18)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 18)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(item.username + item.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
                
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.cyan)
                        
                        Text(item.quizTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.cyan)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cyan.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
                    
                    HStack(spacing: 4) {
                        Image(systemName: item.scorePercentage >= 90 ? "star.fill" : "star.leadinghalf.filled")
                            .font(.system(size: 12))
                        Text("\(item.scorePercentage)%")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(scoreGradient)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
            }
            .padding(18)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 18)
            
            HStack(spacing: 24) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isLiked ? .pink : .white.opacity(0.6))
                            .symbolEffect(.bounce, value: isLiked)
                        
                        if isLiked || item.likes > 0 {
                            Text("\(isLiked ? item.likes + 1 : item.likes)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isLiked ? .pink : .white.opacity(0.6))
                        }
                    }
                }
                
                Button {
                    showComment.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubbles.and.sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if !item.comments.isEmpty {
                            Text("\(item.comments.count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    // Share action
                } label: {
                    Image(systemName: "moon.stars")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(18)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .fullScreenCover(isPresented: Binding(
            get: { showingProfileUserId != nil },
            set: { if !$0 { showingProfileUserId = nil } }
        )) {
            if let userId = showingProfileUserId {
                ProfileViewForFriend(userId: userId)
                    .environmentObject(authViewModel)
            }
        }
    }
}

#Preview {
    FeedsView()
        .environmentObject(AuthViewModel())
}
