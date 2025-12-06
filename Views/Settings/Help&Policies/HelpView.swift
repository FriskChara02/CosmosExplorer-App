//
//  HelpView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var animateContent = false
    @State private var selectedTopic: String?
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            HelpParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Search Bar
                    modernSearchBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Quick Access Cards
                    quickAccessSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Help Categories
                    helpCategoriesSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Contact Support
                    contactSupportCard
                        .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 40)
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
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.5),
                                Color.cyan.opacity(0.3),
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
                            colors: [.blue.opacity(0.6), .cyan.opacity(0.6)],
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
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("How can we help?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Find answers to your questions or contact support")
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
            
            TextField("Search help topics...", text: $searchText)
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
                                    colors: [.blue.opacity(0.5), .cyan.opacity(0.3)],
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
    
    // MARK: - Quick Access Section
    private var quickAccessSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Quick Access")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            .padding(.bottom, 4)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -20)
            .animation(.spring(response: 0.6).delay(0.15), value: animateContent)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                quickAccessCard(
                    icon: "book.fill",
                    title: "User Guide",
                    color: .blue,
                    delay: 0.2
                )
                
                quickAccessCard(
                    icon: "video.fill",
                    title: "Tutorials",
                    color: .purple,
                    delay: 0.25
                )
                
                quickAccessCard(
                    icon: "message.fill",
                    title: "Live Chat",
                    color: .green,
                    delay: 0.3
                )
                
                quickAccessCard(
                    icon: "phone.fill",
                    title: "Call Us",
                    color: .orange,
                    delay: 0.35
                )
            }
        }
    }
    
    private func quickAccessCard(icon: String, title: String, color: Color, delay: Double) -> some View {
        Button {
            HapticManager.impact(style: .light)
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6).delay(delay), value: animateContent)
    }
    
    // MARK: - Help Categories Section
    private var helpCategoriesSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Browse Topics")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            .padding(.bottom, 4)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -20)
            .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
            
            ForEach(Array(filteredCategories.enumerated()), id: \.element.id) { index, category in
                HelpCategoryCard(
                    category: category,
                    delay: Double(index) * 0.05 + 0.45
                )
            }
        }
    }
    
    // MARK: - Contact Support Card
    private var contactSupportCard: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .teal.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Text
            VStack(spacing: 12) {
                Text("Still need help?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Our support team is available 24/7 to help you with any questions or issues.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            
            // Contact Options
            VStack(spacing: 12) {
                contactButton(
                    icon: "envelope.fill",
                    title: "Email Support",
                    subtitle: "support@cosmosexplorer.com",
                    color: .blue
                )
                
                contactButton(
                    icon: "message.fill",
                    title: "Live Chat",
                    subtitle: "Average response: 2 min",
                    color: .green
                )
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.green.opacity(0.4), .teal.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.7), value: animateContent)
    }
    
    private func contactButton(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button {
            HapticManager.impact(style: .medium)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Data
    let helpCategories = [
        HelpCategory(
            icon: "person.circle.fill",
            title: "Account",
            color: .cyan,
            topics: [
                "How to create an account",
                "Reset password",
                "Update profile information",
                "Delete account"
            ]
        ),
        HelpCategory(
            icon: "star.fill",
            title: "Features",
            color: .yellow,
            topics: [
                "How to earn stars",
                "Understanding rank system",
                "Using the quiz feature",
                "Exploring cosmos content"
            ]
        ),
        HelpCategory(
            icon: "person.2.fill",
            title: "Social",
            color: .pink,
            topics: [
                "Adding friends",
                "Creating groups",
                "Chatting with friends",
                "Managing notifications"
            ]
        ),
        HelpCategory(
            icon: "gear",
            title: "Settings",
            color: .purple,
            topics: [
                "Changing language",
                "Notification preferences",
                "Privacy settings",
                "Linked services"
            ]
        )
    ]
    
    var filteredCategories: [HelpCategory] {
        if searchText.isEmpty {
            return helpCategories
        }
        return helpCategories.filter { category in
            category.title.localizedCaseInsensitiveContains(searchText) ||
            category.topics.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Help Category Model
struct HelpCategory: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let topics: [String]
}

// MARK: - Help Category Card
struct HelpCategoryCard: View {
    let category: HelpCategory
    let delay: Double
    @State private var isExpanded = false
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                HapticManager.impact(style: .light)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [category.color.opacity(0.3), category.color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .font(.system(size: 22))
                    }
                    
                    Text(category.title)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Text("\(category.topics.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(18)
            }
            
            // Topics List
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.horizontal, 18)
                    
                    ForEach(category.topics, id: \.self) { topic in
                        Button {
                            HapticManager.impact(style: .light)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(category.color.opacity(0.7))
                                    .frame(width: 20)
                                
                                Text(topic)
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.system(size: 15))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        
                        if topic != category.topics.last {
                            Divider()
                                .background(Color.white.opacity(0.08))
                                .padding(.leading, 56)
                        }
                    }
                    .padding(.vertical, 8)
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
                                    [category.color.opacity(0.5), category.color.opacity(0.3)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isExpanded ? category.color.opacity(0.2) : .clear,
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
struct HelpParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.4),
                                Color.cyan.opacity(0.3),
                                Color.teal.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 3...7))
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
    HelpView()
}
