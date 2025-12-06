//
//  NotificationView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var friendRequestsEnabled = true
    @State private var messagesEnabled = true
    @State private var groupInvitesEnabled = true
    @State private var updatesEnabled = false
    @State private var animateContent = false
    @State private var showQuickToggle = false
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            NotificationParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Quick Actions
                    quickActionsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Notification Categories
                    VStack(spacing: 20) {
                        // General Notifications
                        categorySection(
                            title: "General",
                            icon: "bell.fill",
                            settings: generalSettings
                        )
                        
                        // Social Notifications
                        categorySection(
                            title: "Social",
                            icon: "person.2.fill",
                            settings: socialSettings
                        )
                        
                        // System Settings
                        categorySection(
                            title: "System",
                            icon: "gear",
                            settings: systemSettings
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Info Card
                    infoCard
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    // Spacer at bottom
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
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.5),
                                Color.red.opacity(0.3),
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
                
                // Pulsing ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.6), .red.opacity(0.6), .pink.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateContent ? 1.2 : 0.8)
                    .opacity(animateContent ? 0 : 1)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: animateContent
                    )
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, value: animateContent)
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Notification Settings")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Customize how you receive updates and alerts")
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
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            quickActionButton(
                title: "Enable All",
                icon: "bell.fill",
                color: .green,
                action: { enableAll() }
            )
            
            quickActionButton(
                title: "Disable All",
                icon: "bell.slash.fill",
                color: .red,
                action: { disableAll() }
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            withAnimation(.spring(response: 0.4)) {
                action()
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Category Section
    private func categorySection(title: String, icon: String, settings: [(type: NotificationType, icon: String, title: String, description: String, color: Color)]) -> some View {
        VStack(spacing: 12) {
            // Category Header
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
                
                Text("\(enabledCount(for: settings))/\(settings.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .padding(.top, 8)
            .opacity(animateContent ? 1 : 0)
            .offset(x: animateContent ? 0 : -20)
            
            // Settings Cards
            ForEach(Array(settings.enumerated()), id: \.element.type) { index, setting in
                NotificationToggleCard(
                    setting: setting,
                    isOn: binding(for: setting.type),
                    delay: Double(index) * 0.05 + 0.2
                )
            }
        }
    }
    
    // MARK: - Settings Data
    private var generalSettings: [(type: NotificationType, icon: String, title: String, description: String, color: Color)] {
        [
            (.push, "bell.badge.fill", "Push Notifications", "Receive push notifications on this device", .orange),
            (.email, "envelope.fill", "Email Notifications", "Get updates via email", .blue),
            (.updates, "arrow.triangle.2.circlepath", "App Updates", "Notify about new features", .purple)
        ]
    }
    
    private var socialSettings: [(type: NotificationType, icon: String, title: String, description: String, color: Color)] {
        [
            (.friendRequests, "person.badge.plus", "Friend Requests", "When someone sends a friend request", .cyan),
            (.messages, "message.fill", "Messages", "New messages from friends", .green),
            (.groupInvites, "person.3.fill", "Group Invites", "Invitations to join groups", .pink)
        ]
    }
    
    private var systemSettings: [(type: NotificationType, icon: String, title: String, description: String, color: Color)] {
        [
            (.sound, "speaker.wave.2.fill", "Sound", "Play sound for notifications", .yellow),
            (.vibration, "iphone.radiowaves.left.and.right", "Vibration", "Vibrate on notifications", .indigo)
        ]
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
                
                Text("About Notifications")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                infoPoint(
                    icon: "checkmark.shield.fill",
                    text: "Control what updates you receive"
                )
                
                infoPoint(
                    icon: "bell.badge.fill",
                    text: "Get notified about important events"
                )
                
                infoPoint(
                    icon: "hand.raised.fill",
                    text: "Change settings anytime you want"
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
        .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
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
    
    // MARK: - Helper Functions
    private func binding(for type: NotificationType) -> Binding<Bool> {
        switch type {
        case .push: return $pushEnabled
        case .email: return $emailEnabled
        case .sound: return $soundEnabled
        case .vibration: return $vibrationEnabled
        case .friendRequests: return $friendRequestsEnabled
        case .messages: return $messagesEnabled
        case .groupInvites: return $groupInvitesEnabled
        case .updates: return $updatesEnabled
        }
    }
    
    private func enabledCount(for settings: [(type: NotificationType, icon: String, title: String, description: String, color: Color)]) -> Int {
        settings.filter { binding(for: $0.type).wrappedValue }.count
    }
    
    private func enableAll() {
        pushEnabled = true
        emailEnabled = true
        soundEnabled = true
        vibrationEnabled = true
        friendRequestsEnabled = true
        messagesEnabled = true
        groupInvitesEnabled = true
        updatesEnabled = true
    }
    
    private func disableAll() {
        pushEnabled = false
        emailEnabled = false
        soundEnabled = false
        vibrationEnabled = false
        friendRequestsEnabled = false
        messagesEnabled = false
        groupInvitesEnabled = false
        updatesEnabled = false
    }
    
    enum NotificationType: Hashable {
        case push, email, sound, vibration, friendRequests, messages, groupInvites, updates
    }
}

// MARK: - Notification Toggle Card Component
struct NotificationToggleCard: View {
    let setting: (type: NotificationView.NotificationType, icon: String, title: String, description: String, color: Color)
    @Binding var isOn: Bool
    let delay: Double
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: isOn ?
                                [setting.color.opacity(0.3), setting.color.opacity(0.2)] :
                                [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isOn ?
                            setting.color.opacity(0.4) :
                            Color.white.opacity(0.1),
                        lineWidth: 1
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: setting.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isOn ?
                                [setting.color, setting.color.opacity(0.7)] :
                                [Color.white.opacity(0.4), Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(setting.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(setting.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    HapticManager.impact(style: .light)
                    withAnimation(.spring(response: 0.3)) {
                        isOn = newValue
                    }
                }
            ))
            .labelsHidden()
            .tint(setting.color)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: isOn ?
                                    [setting.color.opacity(0.4), setting.color.opacity(0.2)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isOn ? setting.color.opacity(0.2) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
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
struct NotificationParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.4),
                                Color.red.opacity(0.3),
                                Color.pink.opacity(0.2)
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
    NotificationView()
}
