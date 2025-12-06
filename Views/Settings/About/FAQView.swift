//
//  FAQView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var expandedItems: Set<UUID> = []
    @State private var animateContent = false
    @State private var selectedCategory: FAQCategory = .all
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            FAQParticleField()
                .opacity(0.3)
            
            // Main Content
            VStack(spacing: 0) {
                // Spacer for navigation bar
                Color.clear.frame(height: 100)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                            .padding(.bottom, 8)
                        
                        // Search Bar
                        modernSearchBar
                            .padding(.horizontal, 20)
                        
                        // Category Filter
                        categoryFilterSection
                            .padding(.horizontal, 20)
                        
                        // Stats Card
                        statsCard
                            .padding(.horizontal, 20)
                        
                        // FAQ Items
                        faqListSection
                            .padding(.horizontal, 20)
                        
                        // Contact Support Card
                        contactSupportCard
                            .padding(.horizontal, 20)
                        
                        Color.clear.frame(height: 40)
                    }
                }
            }
            
            // Floating navigation bar
            VStack {
                floatingNavBar
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.08, green: 0.05, blue: 0.12),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Floating Navigation Bar
    private var floatingNavBar: some View {
        HStack {
            Button(action: {
                HapticManager.impact(style: .light)
                withAnimation(.spring(response: 0.3)) {
                    dismiss()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
            
            Spacer()
            
            
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 10)
        .background(Color.clear)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.5),
                                Color.yellow.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
                
                // Rotating ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.6), .yellow.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(animateContent ? 360 : 0))
                    .animation(
                        .linear(duration: 20)
                        .repeatForever(autoreverses: false),
                        value: animateContent
                    )
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Frequently Asked Questions")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("Find quick answers to common questions")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Modern Search Bar
    private var modernSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
            
            TextField("Search FAQs...", text: $searchText)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    HapticManager.impact(style: .light)
                    withAnimation(.spring(response: 0.3)) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            searchText.isEmpty ?
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [.orange.opacity(0.5), .yellow.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    // MARK: - Category Filter
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FAQCategory.allCases, id: \.self) { category in
                    categoryChip(category)
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6).delay(0.15), value: animateContent)
    }
    
    private func categoryChip(_ category: FAQCategory) -> some View {
        Button {
            HapticManager.impact(style: .light)
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        selectedCategory == category ?
                            LinearGradient(
                                colors: [.orange.opacity(0.6), .yellow.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                selectedCategory == category ?
                                    Color.orange.opacity(0.6) :
                                    Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            statItem(
                icon: "doc.text.fill",
                value: "\(faqItems.count)",
                label: "Questions",
                color: .orange
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "magnifyingglass",
                value: "\(filteredFAQs.count)",
                label: "Results",
                color: .yellow
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "checkmark.circle.fill",
                value: "24/7",
                label: "Support",
                color: .green
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.2), value: animateContent)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - FAQ List
    private var faqListSection: some View {
        VStack(spacing: 12) {
            if filteredFAQs.isEmpty {
                emptyStateView
            } else {
                ForEach(Array(filteredFAQs.enumerated()), id: \.element.id) { index, item in
                    FAQItemView(
                        item: item,
                        isExpanded: expandedItems.contains(item.id),
                        delay: Double(index) * 0.03 + 0.25
                    ) {
                        HapticManager.impact(style: .light)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            if expandedItems.contains(item.id) {
                                expandedItems.remove(item.id)
                            } else {
                                expandedItems.insert(item.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Try adjusting your search or category filter")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Contact Support Card
    private var contactSupportCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Still need help?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Contact our support team")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.cyan)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
    }
    
    // MARK: - Data
    let faqItems = [
        FAQItem(
            question: "What is Cosmos Explorer?",
            answer: "Cosmos Explorer is an interactive educational app that helps you explore and learn about the universe, planets, stars and astronomical phenomena through engaging content and quizzes.",
            category: .general
        ),
        FAQItem(
            question: "How do I earn stars?",
            answer: "You can earn stars by completing quizzes, achieving daily streaks, exploring new content and participating in community challenges.",
            category: .account
        ),
        FAQItem(
            question: "What is the rank system?",
            answer: "The rank system is based on your Elo rating, which increases as you answer questions correctly and decreases with incorrect answers. Ranks range from White (0-999) to Red (1600+).",
            category: .account
        ),
        FAQItem(
            question: "How do I add friends?",
            answer: "Go to the Friends section in Settings, tap the + button and search for users by username or email address.",
            category: .account
        ),
        FAQItem(
            question: "Can I change my username?",
            answer: "Yes! Go to Profile > Edit Profile and update your username. Changes will be reflected immediately.",
            category: .account
        ),
        FAQItem(
            question: "How do I reset my password?",
            answer: "On the login screen, tap 'Forgot Password' and follow the instructions sent to your email.",
            category: .account
        ),
        FAQItem(
            question: "Is my data secure?",
            answer: "Yes! We use industry-standard encryption and security measures to protect your data. Read our Privacy Policy for more details.",
            category: .privacy
        ),
        FAQItem(
            question: "Can I use the app offline?",
            answer: "Some features like viewing saved content are available offline, but quizzes and real-time features require an internet connection.",
            category: .technical
        ),
        FAQItem(
            question: "How do I delete my account?",
            answer: "Go to Profile > Edit Profile and scroll down to find the 'Delete Account' option. This action is permanent and cannot be undone.",
            category: .account
        ),
        FAQItem(
            question: "How do I report a bug?",
            answer: "Go to Settings > Send Feedback, select 'Bug Report' as the category and describe the issue you're experiencing.",
            category: .technical
        )
    ]
    
    var filteredFAQs: [FAQItem] {
        var items = faqItems
        
        // Filter by category
        if selectedCategory != .all {
            items = items.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            items = items.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
}

// MARK: - FAQ Category
enum FAQCategory: CaseIterable {
    case all, general, account, privacy, technical
    
    var title: String {
        switch self {
        case .all: return "All"
        case .general: return "General"
        case .account: return "Account"
        case .privacy: return "Privacy"
        case .technical: return "Technical"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .general: return "info.circle.fill"
        case .account: return "person.circle.fill"
        case .privacy: return "lock.shield.fill"
        case .technical: return "gear"
        }
    }
}

// MARK: - FAQ Item Model
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let category: FAQCategory
}

// MARK: - FAQ Item View
struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let delay: Double
    let onTap: () -> Void
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Question Header
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: isExpanded ?
                                        [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)] :
                                        [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: isExpanded ? "questionmark.circle.fill" : "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(isExpanded ? .orange : .white.opacity(0.5))
                    }
                    
                    Text(item.question)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isExpanded ? .orange : .white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(18)
            }
            
            // Answer Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.horizontal, 18)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                            .padding(.top, 2)
                        
                        Text(item.answer)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(18)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: isExpanded ?
                                    [Color.orange.opacity(0.5), Color.yellow.opacity(0.3)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isExpanded ? Color.orange.opacity(0.2) : .clear,
                    radius: 15,
                    x: 0,
                    y: 8
                )
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                appear = true
            }
        }
    }
}

// MARK: - Particle Field Effect
struct FAQParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.4),
                                Color.yellow.opacity(0.3),
                                Color.pink.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 3...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ?
                            CGFloat.random(in: 0...UIScreen.main.bounds.height) :
                            CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    FAQView()
}
