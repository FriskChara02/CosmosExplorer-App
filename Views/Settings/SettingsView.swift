//
//  SettingsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager.current
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State private var selectedLanguage: String
    @State private var showConfirmationAlert = false
    @State private var showRestartAlert = false
    @State private var currentUser: UserModel?
    @State private var animateContent = false
    @State private var scrollOffset: CGFloat = 0
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.current.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                // Animated particles
                ParticleField()
                    .opacity(0.4)
                
                // Main Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 100)
                        
                        // Header with profile
                        headerProfileSection
                            .padding(.bottom, 32)
                        
                        // Content sections
                        VStack(spacing: 20) {
                            quickActionsSection
                            customizeSection
                            accountSection
                            supportSection
                            aboutSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .coordinateSpace(name: "scroll")
                
                // Floating navigation bar
                VStack {
                    floatingNavBar
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentUser()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animateContent = true
                }
            }
            .alert(languageManager.string("Are you sure you want to change the language?"), isPresented: $showConfirmationAlert) {
                Button(languageManager.string("Cancel"), role: .cancel) {
                    selectedLanguage = languageManager.currentLanguage
                }
                Button(languageManager.string("Yes")) {
                    languageManager.currentLanguage = selectedLanguage
                    showRestartAlert = true
                }
            }
            
            // MARK: - Language Changed Alert
            .alert(languageManager.string("Language Changed"), isPresented: $showRestartAlert) {
                Button(languageManager.string("OK")) {
                    dismiss()
                }
            } message: {
                Text(languageManager.string("The language has been changed to \(selectedLanguage == "en" ? "English" : "Vietnamese")."))
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
            
            Text("Settings")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .opacity(scrollOffset > 80 ? 1 : 0)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 10)
        .background(
            .ultraThinMaterial
                .opacity(scrollOffset > 50 ? 1 : 0)
        )
    }
    
    // MARK: - Header Profile Section
    private var headerProfileSection: some View {
        VStack(spacing: 20) {
            // Avatar with glow effect
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(0.5),
                                Color.purple.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                    .scaleEffect(animateContent ? 1 : 0.5)
                
                // Middle ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.6), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 106, height: 106)
                    .rotationEffect(.degrees(animateContent ? 360 : 0))
                    .animation(
                        .linear(duration: 20)
                        .repeatForever(autoreverses: false),
                        value: animateContent
                    )
                
                // Avatar
                if let avatar = currentUser?.avatar, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        defaultAvatarIcon
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                } else {
                    defaultAvatarIcon
                }
                
                // Edit button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                    .offset(x: 35, y: 35)
            }
            .scaleEffect(animateContent ? 1 : 0.8)
            .opacity(animateContent ? 1 : 0)
            
            // User info
            VStack(spacing: 8) {
                Text(currentUser?.username ?? "Guest User")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text(currentUser?.email ?? "email@gmail.com")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                // Verified badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                    Text("Verified Account")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.cyan.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.top, 4)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
        }
        .padding(.horizontal, 20)
    }
    
    private var defaultAvatarIcon: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 96, height: 96)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
            )
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
            }
            
            HStack(spacing: 12) {
                quickActionCard(
                    icon: "bell.badge.fill",
                    title: "Notifications",
                    color: .orange,
                    destination: AnyView(NotificationView())
                )
                
                quickActionCard(
                    icon: "link.circle.fill",
                    title: "Linked Services",
                    color: .purple,
                    destination: AnyView(LinkedServicesView())
                )
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    private func quickActionCard(icon: String, title: String, color: Color, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .stroke(color.opacity(0.4), lineWidth: 1)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
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
        .buttonStyle(ScaleButtonStyles())
    }
    
    // MARK: - Customize Section
    private var customizeSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "Customize", icon: "paintbrush.fill")
            
            // Language Picker
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "globe")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageManager.string("Select Language"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Change app language")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Picker("", selection: $selectedLanguage) {
                    HStack {
                        Text("English")
                    }.tag("en")
                    
                    HStack {
                        Text("Vietnamese")
                    }.tag("vi")
                }
                .pickerStyle(.menu)
                .tint(.green)
                .onChange(of: selectedLanguage) { oldValue, newValue in
                    if newValue != languageManager.currentLanguage {
                        HapticManager.notification(type: .warning)
                        showConfirmationAlert = true
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
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .teal.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.2), value: animateContent)
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "Account", icon: "person.fill")
            
            NavigationLink(destination: ProfileView()) {
                settingRow(
                    icon: "person.circle.fill",
                    title: "Edit Profile",
                    color: .cyan,
                    showBadge: false
                )
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.3), value: animateContent)
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "Support", icon: "lifepreserver.fill")
            
            NavigationLink(destination: HelpView()) {
                settingRow(icon: "questionmark.circle.fill", title: "Help Center", color: .blue)
            }
            
            NavigationLink(destination: FAQView()) {
                settingRow(icon: "list.bullet.circle.fill", title: "FAQ", color: .orange)
            }
            
            NavigationLink(destination: SendFeedbackView()) {
                settingRow(icon: "envelope.fill", title: "Send Feedback", color: .pink)
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "About", icon: "info.circle.fill")
            
            NavigationLink(destination: PrivacyPolicyView()) {
                settingRow(icon: "lock.shield.fill", title: "Privacy Policy", color: .green)
            }
            
            NavigationLink(destination: TermsOfServiceView()) {
                settingRow(icon: "doc.text.fill", title: "Terms of Service", color: .purple)
            }
            
            NavigationLink(destination: RateUsView()) {
                settingRow(icon: "star.fill", title: "Rate Us", color: .yellow)
            }
            
            NavigationLink(destination: ShareAppView()) {
                settingRow(icon: "square.and.arrow.up.fill", title: "Share App", color: .indigo)
            }
            
            // Version info
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "app.badge.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Version")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Current version")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Text("1.0.2")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.5), value: animateContent)
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String) -> some View {
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
    }
    
    private func settingRow(icon: String, title: String, color: Color, showBadge: Bool = false) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            if showBadge {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .buttonStyle(ScaleButtonStyles())
    }
    
    // MARK: - Helper Functions
    private func loadCurrentUser() {
        viewModel.loadCurrentUserIfNeeded { user in
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
}

// MARK: - Particle Field Effect
struct ParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .linear(duration: Double.random(in: 10...20))
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

// MARK: - Button Styles
struct ScaleButtonStyles: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Haptic Manager
struct HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .font(.system(size: 15))
            
            if !text.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            text.isEmpty ? Color.white.opacity(0.2) : Color.cyan.opacity(0.4),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
