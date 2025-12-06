//
//  TermsOfServiceView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @State private var acceptedTerms = false
    @State private var showAcceptedAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            TermsParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Important Notice
                    importantNoticeCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Terms Sections
                    termsSectionsView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Key Points Section
                    keyPointsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Acceptance Card
                    acceptanceCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    
                    // Last Updated
                    lastUpdatedCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Contact Card
                    contactCard
                        .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 40)
                }
            }
            
            // Floating navigation bar
            VStack {
                floatingNavBar
                Spacer()
            }
            
            // Acceptance Animation
            if showAcceptedAnimation {
                acceptedAnimationOverlay
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
                                Color.purple.opacity(0.5),
                                Color.pink.opacity(0.3),
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
                            colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
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
                                colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Terms of Service")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Please read these terms carefully before using our service")
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
    
    // MARK: - Important Notice Card
    private var importantNoticeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("Important Notice")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("By using Cosmos Explorer, you agree to be bound by these terms. If you do not agree to these terms, please do not use our service.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(5)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.4), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    // MARK: - Terms Sections
    private var termsSectionsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Terms & Conditions")
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
            
            ForEach(Array(termsSections.enumerated()), id: \.offset) { index, section in
                TermsSection(
                    number: section.0,
                    title: section.1,
                    icon: section.2,
                    content: section.3,
                    color: section.4,
                    delay: Double(index) * 0.05 + 0.2
                )
            }
        }
    }
    
    // MARK: - Key Points Section
    private var keyPointsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "key.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Key Points")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            .padding(.bottom, 4)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -20)
            .animation(.spring(response: 0.6).delay(0.5), value: animateContent)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                keyPointCard(
                    icon: "checkmark.shield.fill",
                    title: "Safe to Use",
                    color: .green,
                    delay: 0.55
                )
                
                keyPointCard(
                    icon: "person.fill.checkmark",
                    title: "User Rights",
                    color: .blue,
                    delay: 0.6
                )
                
                keyPointCard(
                    icon: "hand.raised.fill",
                    title: "Fair Rules",
                    color: .orange,
                    delay: 0.65
                )
                
                keyPointCard(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Can Update",
                    color: .purple,
                    delay: 0.7
                )
            }
        }
    }
    
    private func keyPointCard(icon: String, title: String, color: Color, delay: Double) -> some View {
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
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6).delay(delay), value: animateContent)
    }
    
    // MARK: - Acceptance Card
    private var acceptanceCard: some View {
        Button {
            HapticManager.impact(style: .medium)
            withAnimation(.spring(response: 0.3)) {
                acceptedTerms.toggle()
                if acceptedTerms {
                    showAcceptedAnimation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showAcceptedAnimation = false
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            acceptedTerms ?
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 28, height: 28)
                    
                    if acceptedTerms {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("I Accept the Terms")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("I have read and agree to the terms of service")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: acceptedTerms ?
                                        [.purple.opacity(0.6), .pink.opacity(0.4)] :
                                        [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: acceptedTerms ? Color.purple.opacity(0.3) : .clear,
                        radius: 15,
                        x: 0,
                        y: 8
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.75), value: animateContent)
    }
    
    // MARK: - Last Updated Card
    private var lastUpdatedCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 18))
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Last Updated")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("December 4, 2025")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.8), value: animateContent)
    }
    
    // MARK: - Contact Card
    private var contactCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Questions about terms?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Contact our legal team")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            Button {
                HapticManager.impact(style: .medium)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                    Text("legal@cosmosexplorer.com")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.85), value: animateContent)
    }
    
    // MARK: - Accepted Animation Overlay
    private var acceptedAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showAcceptedAnimation ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showAcceptedAnimation)
                
                Text("Terms Accepted!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }
    
    // MARK: - Data
    let termsSections: [(String, String, String, String, Color)] = [
        ("1", "Acceptance of Terms", "checkmark.seal.fill", "By accessing and using Cosmos Explorer, you accept and agree to be bound by the terms and provision of this agreement.", .blue),
        ("2", "Use License", "doc.text.fill", "Permission is granted to temporarily use Cosmos Explorer for personal, non-commercial transitory viewing only.", .green),
        ("3", "User Accounts", "person.text.rectangle.fill", "You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.", .orange),
        ("4", "Prohibited Uses", "hand.raised.fill", "You may not use Cosmos Explorer for any illegal or unauthorized purpose nor may you violate any laws in your jurisdiction.", .red),
        ("5", "Intellectual Property", "books.vertical.fill", "All content, features and functionality are owned by Cosmos Explorer and are protected by international copyright, trademark and other intellectual property laws.", .purple),
        ("6", "Termination", "xmark.circle.fill", "We may terminate or suspend your account and bar access to the service immediately, without prior notice or liability, under our sole discretion.", .pink),
        ("7", "Changes to Terms", "arrow.triangle.2.circlepath", "We reserve the right to modify or replace these terms at any time. It is your responsibility to check these terms periodically for changes.", .cyan)
    ]
}

// MARK: - Terms Section Component
struct TermsSection: View {
    let number: String
    let title: String
    let icon: String
    let content: String
    let color: Color
    let delay: Double
    @State private var appear = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                HapticManager.impact(style: .light)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Number Badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Text(number)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(color)
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Expand Icon
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                .padding(18)
            }
            
            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.horizontal, 18)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                            .padding(.top, 2)
                        
                        Text(content)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(6)
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
                                    [color.opacity(0.5), color.opacity(0.3)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isExpanded ? color.opacity(0.2) : .clear,
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
struct TermsParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.4),
                                Color.pink.opacity(0.3),
                                Color.blue.opacity(0.2)
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
    TermsOfServiceView()
}
