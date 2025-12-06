//
//  PrivacyPolicyView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @State private var acceptedPolicy = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            PrivacyParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Summary Card
                    summaryCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Privacy Sections
                    privacySectionsView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Commitments Section
                    commitmentsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
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
                                Color.green.opacity(0.5),
                                Color.teal.opacity(0.3),
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
                            colors: [.green.opacity(0.6), .teal.opacity(0.6)],
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
                                colors: [.green.opacity(0.3), .teal.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Privacy Policy")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Your privacy and security are our top priorities")
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
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("In Summary")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                summaryPoint(
                    icon: "checkmark.seal.fill",
                    text: "We protect your personal information"
                )
                
                summaryPoint(
                    icon: "hand.raised.fill",
                    text: "We don't sell your data to third parties"
                )
                
                summaryPoint(
                    icon: "person.badge.shield.checkmark.fill",
                    text: "You control your privacy settings"
                )
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
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    private func summaryPoint(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    // MARK: - Privacy Sections
    private var privacySectionsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Policy Details")
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
            
            ForEach(Array(privacySections.enumerated()), id: \.offset) { index, section in
                PrivacySection(
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
    
    // MARK: - Commitments Section
    private var commitmentsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Our Commitments")
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
                commitmentCard(
                    icon: "lock.fill",
                    title: "Encrypted",
                    color: .blue,
                    delay: 0.55
                )
                
                commitmentCard(
                    icon: "eye.slash.fill",
                    title: "No Tracking",
                    color: .purple,
                    delay: 0.6
                )
                
                commitmentCard(
                    icon: "shield.checkered",
                    title: "Secure",
                    color: .cyan,
                    delay: 0.65
                )
                
                commitmentCard(
                    icon: "hand.raised.fill",
                    title: "No Ads",
                    color: .pink,
                    delay: 0.7
                )
            }
        }
    }
    
    private func commitmentCard(icon: String, title: String, color: Color, delay: Double) -> some View {
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
    
    // MARK: - Last Updated Card
    private var lastUpdatedCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 18))
                .foregroundColor(.cyan)
            
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
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.75), value: animateContent)
    }
    
    // MARK: - Contact Card
    private var contactCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Questions about privacy?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("We're here to help")
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
                    Text("privacy@cosmosexplorer.com")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
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
                                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.8), value: animateContent)
    }
    
    // MARK: - Data
    let privacySections: [(String, String, String, String, Color)] = [
        ("1", "Information Collection", "doc.text.fill", "We collect information you provide directly to us, including your name, email address, profile information and any other information you choose to provide.", .blue),
        ("2", "How We Use Data", "document.badge.gearshape.fill", "We use the information we collect to provide, maintain and improve our services, to communicate with you and to personalize your experience.", .purple),
        ("3", "Information Sharing", "arrow.triangle.branch", "We do not share your personal information with third parties except as described in this policy or with your consent.", .cyan),
        ("4", "Data Security", "lock.shield.fill", "We implement appropriate security measures to protect your personal information from unauthorized access, alteration or destruction.", .green),
        ("5", "Your Rights", "person.badge.key.fill", "You have the right to access, update or delete your personal information at any time through your account settings.", .orange),
        ("6", "Children's Privacy", "figure.2.and.child.holdinghands", "Our service is not directed to children under 13. We do not knowingly collect personal information from children.", .pink)
    ]
}

// MARK: - Privacy Section Component
struct PrivacySection: View {
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
struct PrivacyParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.4),
                                Color.teal.opacity(0.3),
                                Color.cyan.opacity(0.2)
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
    PrivacyPolicyView()
}
