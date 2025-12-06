//
//  LinkedServicesView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct LinkedServicesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var googleLinked = false
    @State private var facebookLinked = false
    @State private var appleLinked = false
    @State private var animateContent = false
    @State private var selectedService: String? = nil
    @State private var showSuccessAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            ServiceParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 40)
                    
                    // Services Grid
                    VStack(spacing: 16) {
                        // Primary Services
                        VStack(spacing: 12) {
                            sectionLabel(title: "Popular Services", icon: "star.fill")
                            
                            ServiceCard(
                                service: "Google",
                                icon: "GoogleIcon",
                                usesSystemIcon: false,
                                color: .red,
                                gradient: [.red, .orange],
                                description: "Sign in with your Google account",
                                isLinked: $googleLinked,
                                delay: 0.1,
                                onLink: {
                                    guard let rootVC = getRootViewController() else { return }
                                    GoogleService.shared.signIn(presentingViewController: rootVC) { result in
                                        switch result {
                                        case .success(let googleUser):
                                            print("✅ Linked Google: \(googleUser.email)")
                                            googleLinked = true
                                        case .failure(let error):
                                            print("❌ Failed to link Google: \(error)")
                                        }
                                    }
                                },
                                onUnlink: {
                                    GoogleService.shared.signOut()
                                    googleLinked = false
                                }
                            )
                            
                            ServiceCard(
                                service: "Apple",
                                icon: "apple.logo",
                                usesSystemIcon: true,
                                color: .white,
                                gradient: [.white, .gray],
                                description: "Use your Apple ID for quick access",
                                isLinked: $appleLinked,
                                delay: 0.2
                            )
                        }
                        
                        // Social Services
                        VStack(spacing: 12) {
                            sectionLabel(title: "Social Networks", icon: "person.2.fill")
                            
                            ServiceCard(
                                service: "Facebook",
                                icon: "FacebookIcon",
                                usesSystemIcon: false,
                                color: .blue,
                                gradient: [.blue, .cyan],
                                description: "Connect with Facebook",
                                isLinked: $facebookLinked,
                                delay: 0.3
                            )
                        }
                        
                        // Stats Card
                        statsCard
                        
                        // Info Card
                        infoCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Floating navigation bar
            VStack {
                floatingNavBar
                Spacer()
            }
            
            // Success overlay
            if showSuccessAnimation {
                successOverlay
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
                                Color.cyan.opacity(0.5),
                                Color.blue.opacity(0.3),
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
                            colors: [.cyan.opacity(0.6), .blue.opacity(0.6), .purple.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(animateContent ? 360 : 0))
                    .animation(
                        .linear(duration: 15)
                        .repeatForever(autoreverses: false),
                        value: animateContent
                    )
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Linked Services")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Connect your accounts for seamless authentication")
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
    
    // MARK: - Section Label
    private func sectionLabel(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
                .tracking(1.2)
            
            Spacer()
        }
        .padding(.top, 8)
        .opacity(animateContent ? 1 : 0)
        .offset(x: animateContent ? 0 : -20)
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            statItem(
                icon: "checkmark.circle.fill",
                value: "\(connectedServicesCount)",
                label: "Connected",
                color: .green
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "shield.checkered",
                value: "100%",
                label: "Secure",
                color: .cyan
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "bolt.fill",
                value: "Fast",
                label: "Sign In",
                color: .yellow
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
                                colors: [.cyan.opacity(0.3), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.5), value: animateContent)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
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
    
    private var connectedServicesCount: Int {
        [googleLinked, facebookLinked, appleLinked].filter { $0 }.count
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text("Security & Privacy")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                infoPoint(
                    icon: "lock.shield.fill",
                    text: "Your credentials are encrypted end-to-end"
                )
                
                infoPoint(
                    icon: "eye.slash.fill",
                    text: "We never store your account passwords"
                )
                
                infoPoint(
                    icon: "hand.raised.fill",
                    text: "Unlink services anytime without data loss"
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
        .animation(.spring(response: 0.6).delay(0.6), value: animateContent)
    }
    
    private func infoPoint(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.cyan)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showSuccessAnimation ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                
                Text("Successfully Linked!")
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSuccessAnimation = false
                }
            }
        }
    }
}

// MARK: - Service Card Component
struct ServiceCard: View {
    let service: String
    let icon: String
    let usesSystemIcon: Bool
    let color: Color
    let gradient: [Color]
    let description: String
    @Binding var isLinked: Bool
    let delay: Double
    var onLink: (() -> Void)? = nil
    var onUnlink: (() -> Void)? = nil
    @State private var appear = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Service Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: 60, height: 60)
                
                if usesSystemIcon {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 28, height: 28)
                }
            }
            
            // Service Info
            VStack(alignment: .leading, spacing: 6) {
                Text(service)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                
                // Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(isLinked ? Color.green : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                    
                    Text(isLinked ? "Connected" : "Not connected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isLinked ? .green : .white.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(
                            isLinked ?
                                Color.green.opacity(0.15) :
                                Color.white.opacity(0.05)
                        )
                )
            }
            
            Spacer()
            
            // Action Button
            Button {
                HapticManager.impact(style: .medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        if isLinked {
                            onUnlink?()
                        } else {
                            onLink?()
                        }
                        isLinked.toggle()
                    }
                } label: {
                Text(isLinked ? "Unlink" : "Link")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: isLinked ?
                                        [.red.opacity(0.8), .orange.opacity(0.8)] :
                                        gradient.map { $0.opacity(0.8) },
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: isLinked ?
                                        [.red, .orange] :
                                        gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: (isLinked ? Color.red : color).opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: isLinked ?
                                    [color.opacity(0.4), color.opacity(0.2)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isLinked ? color.opacity(0.2) : .clear,
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

private func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        return nil
    }
    return rootViewController
}

// MARK: - Particle Field Effect
struct ServiceParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.4),
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 3...8))
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
    LinkedServicesView()
}
