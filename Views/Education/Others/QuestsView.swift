//
//  QuestsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/11/25.
//

import SwiftUI

struct QuestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Banner slideshow
    private let bannerImages = ["cosmos_background", "cosmos_background1", "Chapter04", "cosmos_background2"]
    @State private var currentBannerIndex = 0
    private let bannerTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var weeklyProgress = 0
    @State private var dailyProgress = [0, 0, 0]
    @State private var remainingTimeDaily = 0
    @State private var remainingTimeWeekly = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // Animated gradient background
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
            
            // Floating particles effect
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
                    // Header with glassmorphic back button
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
                        Text("Quest Hub")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 15, x: 0, y: 0)
                        
                        Text("Complete missions, earn rewards")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Premium Banner Slideshow with parallax effect
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 20)
                            .offset(y: 4)
                        
                        ForEach(bannerImages.indices, id: \.self) { index in
                            Image(bannerImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(20)
                                .opacity(currentBannerIndex == index ? 1 : 0)
                                .scaleEffect(currentBannerIndex == index ? 1 : 0.95)
                                .blur(radius: currentBannerIndex == index ? 0 : 15)
                                .animation(.easeInOut(duration: 1.0), value: currentBannerIndex)
                        }
                        
                        // Banner overlay gradient
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(20)
                        
                        // Page indicator
                        VStack {
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(bannerImages.indices, id: \.self) { index in
                                    Capsule()
                                        .fill(currentBannerIndex == index ? Color.white : Color.white.opacity(0.4))
                                        .frame(width: currentBannerIndex == index ? 20 : 8, height: 8)
                                        .animation(.spring(response: 0.3), value: currentBannerIndex)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                    .onReceive(bannerTimer) { _ in
                        withAnimation(.easeInOut(duration: 1.0)) {
                            currentBannerIndex = (currentBannerIndex + 1) % bannerImages.count
                        }
                    }
                    
                    // Premium Weekly Quest Card
                    QuestCard(
                        title: "Weekly Challenge",
                        icon: "calendar.badge.plus",
                        timeLeft: remainingTimeWeekly,
                        label: formatDays(remainingTimeWeekly),
                        progress: weeklyProgress,
                        max: 7,
                        reward: 150,
                        accentColor: .purple
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.purple.opacity(0.8))
                                .font(.system(size: 16))
                            Text("Complete 7 lessons this week")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Modern Daily Quests Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Missions")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Reset in \(formatTime(remainingTimeDaily))")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.orange.opacity(0.8))
                            }
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .symbolEffect(.pulse, options: .repeating)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            QuestProgressBar(
                                progress: dailyProgress[0],
                                max: 1,
                                reward: 25,
                                icon: "book.fill",
                                accentColor: .green
                            ) {
                                Text("Complete 1 lesson")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            QuestProgressBar(
                                progress: dailyProgress[1],
                                max: 2,
                                reward: 50,
                                icon: "books.vertical.fill",
                                accentColor: .blue
                            ) {
                                Text("Complete 2 lessons")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            QuestProgressBar(
                                progress: dailyProgress[2],
                                max: 1,
                                reward: 75,
                                icon: "star.fill",
                                accentColor: .yellow
                            ) {
                                Text("Score 80%+ on 1 quiz")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(20)
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
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 40)
            }
        }
        .task { await loadRealQuests() }
        .onAppear {
            Task { await loadRealQuests() }
        }
        .onChange(of: authViewModel.currentUser?.score) { _, _ in
            Task { await loadRealQuests() }
        }
        .onReceive(countdownTimer) { _ in
            if remainingTimeDaily > 0 { remainingTimeDaily -= 1 }
            if remainingTimeWeekly > 0 { remainingTimeWeekly -= 1 }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("QuizCompleted"))) { _ in
            Task {
                await loadRealQuests()
            }
        }
    }
    
    // MARK: - Load Data
    public func loadRealQuests() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        let userIdStr = userId.uuidString
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let now = Date()
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: now)
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            
            // Daily count
            let dailyQuery = """
            SELECT COUNT(*) FROM attempts 
            WHERE user_id = $1::uuid 
              AND is_completed = true 
              AND last_updated >= $2
            """
            let dailyCount = try connection.prepareStatement(text: dailyQuery)
                .execute(parameterValues: [userIdStr, ISO8601DateFormatter().string(from: todayStart)])
                .next()?.get().columns[0].int() ?? 0
            
            // Weekly count
            let weeklyQuery = """
            SELECT COUNT(*) FROM attempts 
            WHERE user_id = $1::uuid 
              AND is_completed = true 
              AND last_updated >= $2 
              AND last_updated < $3
            """
            let weekEnd = weekStart.addingTimeInterval(7*86400)
            let weeklyCount = try connection.prepareStatement(text: weeklyQuery)
                .execute(parameterValues: [userIdStr,
                                           ISO8601DateFormatter().string(from: weekStart),
                                           ISO8601DateFormatter().string(from: weekEnd)])
                .next()?.get().columns[0].int() ?? 0
            
            // High accuracy count (≥80%)
            let highCount = try connection.prepareStatement(text: """
            SELECT COUNT(*) FROM attempts 
            WHERE user_id = $1::uuid 
              AND is_completed = true 
              AND last_updated >= $2
              AND (correct_count::float / NULLIF(correct_count + incorrect_count, 0)) >= 0.8
            """).execute(parameterValues: [userIdStr, ISO8601DateFormatter().string(from: todayStart)])
                .next()?.get().columns[0].int() ?? 0
            
            // Time remaining
            let secondsInDay: TimeInterval = 86400
            let weekEndTime = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let timeRemainingInWeek = weekEndTime.timeIntervalSince(weekStart) - now.timeIntervalSince(weekStart)
            remainingTimeDaily = Int(secondsInDay - now.timeIntervalSince(todayStart))
            remainingTimeWeekly = max(0, Int(timeRemainingInWeek))
            
            await MainActor.run {
                let completionsForTwo = dailyCount >= 2 ? 2 : dailyCount
                
                self.dailyProgress = [
                    dailyCount >= 1 ? 1 : 0,
                    completionsForTwo,
                    highCount >= 1 ? 1 : 0
                ]
                self.weeklyProgress = min(weeklyCount, 7)
            }
        } catch {
            print("Lỗi load quests: \(error)")
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    private func formatDays(_ seconds: Int) -> String {
        let days = seconds / 86400
        return days > 0 ? "\(days)D" : "<1D"
    }
}

// MARK: - Modern QuestCard
struct QuestCard<Content: View>: View {
    let title: String
    let icon: String
    var timeLeft: Int
    let label: String
    let progress: Int
    let max: Int
    let reward: Int
    let accentColor: Color
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text(label)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(accentColor.opacity(0.9))
                }
                
                Spacer()
            }
            
            content()
            
            QuestProgressBar(
                progress: progress,
                max: max,
                reward: reward,
                icon: "target",
                accentColor: accentColor
            ) {
                Text("Complete \(max) lessons this week")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
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
                        colors: [accentColor.opacity(0.4), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: accentColor.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Modern QuestProgressBar
struct QuestProgressBar<Content: View>: View {
    let progress: Int
    let max: Int
    let reward: Int
    let icon: String
    let accentColor: Color
    @ViewBuilder let content: () -> Content
    
    var progressPercentage: CGFloat {
        CGFloat(progress) / CGFloat(max)
    }
    
    var isCompleted: Bool {
        progress >= max
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(accentColor.opacity(0.8))
                
                content()
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("\(reward)")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: isCompleted ? [.green, .green.opacity(0.7)] : [accentColor, accentColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 12)
                
                // Progress fill
                GeometryReader { proxy in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isCompleted
                                    ? [.green, .green.opacity(0.7)]
                                    : [accentColor, accentColor.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progressPercentage)
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                }
                .frame(height: 12)
                
                // Progress text
                HStack {
                    Spacer()
                    Text("\(progress)/\(max)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                    Spacer()
                }
            }
            .frame(height: 12)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isCompleted
                        ? LinearGradient(colors: [.green.opacity(0.5), .green.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [accentColor.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    QuestsView()
        .environmentObject(AuthViewModel())
}
