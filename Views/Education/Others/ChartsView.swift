//
//  ChartsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 3/12/25.
//

import SwiftUI
import Charts
import SwiftData

struct ChartsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Environment(\.dismiss) private var dismiss
    
    @State private var attempts: [Attempt] = []
    @State private var selectedTab: Tab = .today
    @State private var refreshID = UUID()
    @State private var animateCards = false
    @State private var animateCharts = false
    @State private var showStats = false
    
    let service = SwiftDataService.shared
    let userId = AuthManager.shared.currentUserId ?? UUID()
    
    // Tab Today / All Time
    private enum Tab: String, CaseIterable {
        case today = "Today"
        case allTime = "All Time"
    }
    
    init() {
        let userId = AuthManager.shared.currentUserId ?? UUID()
        _userProgress = Query(FetchDescriptor<UserProgress>(
            predicate: #Predicate { $0.userId == userId }
        ))
    }
    
    // MARK: - Tính toán dữ liệu
    private var todayAttempts: [Attempt] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return attempts.filter { attempt in
            let lastUpdated = attempt.lastUpdated
            return calendar.isDate(lastUpdated, inSameDayAs: today)
        }
    }
    
    private var todayTotal: Int { todayAttempts.reduce(0) { $0 + $1.correctCount + $1.incorrectCount } }
    private var todayCorrect: Int { todayAttempts.reduce(0) { $0 + $1.correctCount } }
    private var todayIncorrect: Int { todayAttempts.reduce(0) { $0 + $1.incorrectCount } }
    
    private var allTimeTotal: Int { attempts.reduce(0) { $0 + $1.correctCount + $1.incorrectCount } }
    private var allTimeCorrect: Int { attempts.reduce(0) { $0 + $1.correctCount } }
    private var allTimeIncorrect: Int { attempts.reduce(0) { $0 + $1.incorrectCount } }
    
    private var currentScore: Int {
        guard let localUser = try? modelContext.fetch(FetchDescriptor<UserModel>()).first else { return 0 }
        return localUser.score
    }
    
    private var currentRank: Int {
        guard let localUser = try? modelContext.fetch(FetchDescriptor<UserModel>()).first else { return 1 }
        return localUser.rank
    }
    
    private var yesterdayScore: Int {
        guard let localUser = try? modelContext.fetch(FetchDescriptor<UserModel>()).first else { return 0 }
        return max(0, localUser.score - (todayCorrect * 20))
    }
    
    private var yesterdayRank: Int {
        guard let localUser = try? modelContext.fetch(FetchDescriptor<UserModel>()).first else { return 1 }
        return max(1, localUser.rank - (todayCorrect * 20))
    }
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            backgroundLayer
            animatedParticlesLayer
            
            ScrollView {
                VStack(spacing: 0) {
                    navigationBar
                    
                    VStack(spacing: 24) {
                        tabSelector
                        scoreRankCard
                        barChartSection
                        pieChartSection
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .id(refreshID)
        .onAppear {
            loadAttempts()
            withAnimation {
                animateCards = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateCharts = true
                    showStats = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("QuizCompleted"))) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                loadAttempts()
                refreshID = UUID()
            }
        }
    }
    
    // MARK: - Background Layer
    private var backgroundLayer: some View {
        ZStack {
            Image("BlackBG2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.blue.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Animated Particles
    private var animatedParticlesLayer: some View {
        GeometryReader { geometry in
            ForEach(0..<8, id: \.self) { index in
                let particleGradient = LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(particleGradient)
                    .frame(width: CGFloat.random(in: 60...120))
                    .offset(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .blur(radius: 40)
                    .opacity(0.4)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.3),
                        value: animateCards
                    )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            backButton
            Spacer()
            titleText
            Spacer()
            
            Circle()
                .fill(.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var backButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dismiss()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                
                let strokeGradient = LinearGradient(
                    colors: [.white.opacity(0.3), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .stroke(strokeGradient, lineWidth: 1)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private var titleText: some View {
        let titleGradient = LinearGradient(
            colors: [.white, .white.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        return Text("Learning statistics")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(titleGradient)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 12) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .offset(y: animateCards ? 0 : 20)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateCards)
    }
    
    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            Text(tab.rawValue)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.6))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background {
                    if selectedTab == tab {
                        let activeGradient = LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        
                        Capsule()
                            .fill(activeGradient)
                            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            .matchedGeometryEffect(id: "TAB", in: namespace)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    }
                }
        }
    }
    
    // MARK: - Score & Rank Card
    private var scoreRankCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                scoreSection
                rankSection
            }
            
            if selectedTab == .today {
                Divider()
                    .background(.white.opacity(0.2))
                
                HStack {
                    Text("Yesterday: Score \(yesterdayScore) • Rank #\(yesterdayRank)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
            }
        }
        .padding(24)
        .background {
            cardBackground
        }
        .padding(.horizontal, 24)
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
    }
    
    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                let starGradient = LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(starGradient)
                
                Text("Score")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                let scoreGradient = LinearGradient(
                    colors: [.white, .white.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Text("\(currentScore)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreGradient)
                
                if selectedTab == .today && todayCorrect > 0 {
                    let increaseGradient = LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    Text("+\(todayCorrect * 20)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(increaseGradient)
                        .offset(y: showStats ? 0 : -10)
                        .opacity(showStats ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showStats)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var rankSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text("Rank")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                let trophyGradient = LinearGradient(
                    colors: [.orange, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(trophyGradient)
            }
            
            let rankGradient = LinearGradient(
                colors: [.white, .white.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Text("#\(currentRank)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(rankGradient)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Bar Chart Section
    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                let chartIconGradient = LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(chartIconGradient)
                
                Text("Question Statistics")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            barChart
        }
        .padding(24)
        .background {
            cardBackground
        }
        .padding(.horizontal, 24)
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
    }
    
    private var barChart: some View {
        let totalGradient = LinearGradient(
            colors: [.blue, .cyan],
            startPoint: .bottom,
            endPoint: .top
        )
        let correctGradient = LinearGradient(
            colors: [.green, .mint],
            startPoint: .bottom,
            endPoint: .top
        )
        let incorrectGradient = LinearGradient(
            colors: [.red, .pink],
            startPoint: .bottom,
            endPoint: .top
        )
        
        return Chart {
            BarMark(
                x: .value("Type", "Total"),
                y: .value("Number of Questions", selectedTab == .today ? todayTotal : allTimeTotal)
            )
            .foregroundStyle(totalGradient)
            .cornerRadius(8)
            
            BarMark(
                x: .value("Type", "Correct"),
                y: .value("Number of Questions", selectedTab == .today ? todayCorrect : allTimeCorrect)
            )
            .foregroundStyle(correctGradient)
            .cornerRadius(8)
            
            BarMark(
                x: .value("Type", "Incorrect"),
                y: .value("Number of Questions", selectedTab == .today ? todayIncorrect : allTimeIncorrect)
            )
            .foregroundStyle(incorrectGradient)
            .cornerRadius(8)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
                AxisGridLine()
                    .foregroundStyle(.white.opacity(0.1))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 240)
        .opacity(animateCharts ? 1 : 0)
        .scaleEffect(animateCharts ? 1 : 0.8)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animateCharts)
    }
    
    // MARK: - Pie Chart Section
    private var pieChartSection: some View {
        let total = selectedTab == .today ? todayTotal : allTimeTotal
        let correct = selectedTab == .today ? todayCorrect : allTimeCorrect
        let accuracy = total > 0 ? Double(correct) / Double(total) * 100 : 0
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                let pieIconGradient = LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(pieIconGradient)
                
                Text("Accuracy Rate")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            pieChart(total: total, correct: correct, accuracy: accuracy)
            legend(total: total, correct: correct)
            accuracyBadge(accuracy: accuracy)
        }
        .padding(24)
        .background {
            cardBackground
        }
        .padding(.horizontal, 24)
        .offset(y: animateCards ? 0 : 30)
        .opacity(animateCards ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateCards)
    }
    
    private func pieChart(total: Int, correct: Int, accuracy: Double) -> some View {
        let correctGradient = LinearGradient(
            colors: [.green, .mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        let incorrectGradient = LinearGradient(
            colors: [.red, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return ZStack {
            Chart {
                SectorMark(
                    angle: .value("Correct", correct),
                    innerRadius: .ratio(0.618),
                    angularInset: 3
                )
                .foregroundStyle(correctGradient)
                .cornerRadius(6)
                
                SectorMark(
                    angle: .value("Incorrect", total - correct),
                    innerRadius: .ratio(0.618),
                    angularInset: 3
                )
                .foregroundStyle(incorrectGradient)
                .cornerRadius(6)
            }
            .frame(height: 280)
            
            centerPercentageView(accuracy: accuracy)
        }
        .opacity(animateCharts ? 1 : 0)
        .scaleEffect(animateCharts ? 1 : 0.8)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: animateCharts)
    }
    
    private func centerPercentageView(accuracy: Double) -> some View {
        let percentageGradient = LinearGradient(
            colors: [.white, .white.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return VStack(spacing: 4) {
            Text(String(format: "%.1f%%", accuracy))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(percentageGradient)
            
            Text("Accuracy")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .scaleEffect(showStats ? 1 : 0.5)
        .opacity(showStats ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: showStats)
    }
    
    private func legend(total: Int, correct: Int) -> some View {
        let correctLegendGradient = LinearGradient(
            colors: [.green, .mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        let incorrectLegendGradient = LinearGradient(
            colors: [.red, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return HStack(spacing: 24) {
            HStack(spacing: 8) {
                Circle()
                    .fill(correctLegendGradient)
                    .frame(width: 12, height: 12)
                Text("Correct: \(correct)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Circle()
                    .fill(incorrectLegendGradient)
                    .frame(width: 12, height: 12)
                Text("Incorrect: \(total - correct)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func accuracyBadge(accuracy: Double) -> some View {
        let badgeColors: [Color] = accuracy >= 80 ? [.green, .mint] : accuracy >= 50 ? [.orange, .yellow] : [.red, .pink]
        let badgeGradient = LinearGradient(
            colors: badgeColors,
            startPoint: .leading,
            endPoint: .trailing
        )
        let shadowColor = accuracy >= 80 ? Color.green : accuracy >= 50 ? Color.orange : Color.red
        
        return HStack {
            Spacer()
            VStack(spacing: 4) {
                Text(accuracy >= 80 ? "Excellent ^^! 🎉" : accuracy >= 50 ? "Good job :3 👍" : "Keep it up!!! 💪")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .fill(badgeGradient)
                    .shadow(color: shadowColor.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            Spacer()
        }
        .scaleEffect(showStats ? 1 : 0.8)
        .opacity(showStats ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: showStats)
    }
    
    // MARK: - Card Background
    private var cardBackground: some View {
        let strokeGradient = LinearGradient(
            colors: [.white.opacity(0.3), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(strokeGradient, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Data Loading
    private func loadAttempts() {
        attempts = service.fetchAttemptsFromPostgreSQL(userId: userId)
        print("📊 Loaded \(attempts.count) attempts from PostgreSQL")
        print("Today: \(todayTotal) câu, Correct: \(todayCorrect)")
        print("All Time: \(allTimeTotal) câu, Correct: \(allTimeCorrect)")
    }
}

#Preview {
    ChartsView()
        .modelContainer(for: [Attempt.self, UserProgress.self, UserModel.self], inMemory: true)
}
