//
//  SendFeedbackView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI
import PostgresClientKit
import Foundation
import SwiftData

// MARK: - Feedback Model
@Model
final class FeedbackModel: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var username: String
    var email: String
    var category: String
    var subject: String
    var message: String
    var timestamp: Date
    
    init(id: UUID = UUID(), userId: UUID, username: String, email: String, category: String, subject: String, message: String, timestamp: Date = Date()) {
        self.id = id
        self.userId = userId
        self.username = username
        self.email = email
        self.category = category
        self.subject = subject
        self.message = message
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, username, email, category, subject, message, timestamp
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        category = try container.decode(String.self, forKey: .category)
        subject = try container.decode(String.self, forKey: .subject)
        message = try container.decode(String.self, forKey: .message)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(category, forKey: .category)
        try container.encode(subject, forKey: .subject)
        try container.encode(message, forKey: .message)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - Send Feedback View
struct SendFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var selectedCategory = "General"
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var animateContent = false
    @State private var showThankYou = false
    
    let categories = [
        FeedbackCategory(id: "general", name: "General", icon: "bubble.left.and.bubble.right.fill", color: .blue),
        FeedbackCategory(id: "bug", name: "Bug Report", icon: "ladybug.fill", color: .red),
        FeedbackCategory(id: "feature", name: "Feature Request", icon: "lightbulb.fill", color: .yellow),
        FeedbackCategory(id: "account", name: "Account Issue", icon: "person.crop.circle.badge.exclamationmark", color: .orange),
        FeedbackCategory(id: "other", name: "Other", icon: "ellipsis.circle.fill", color: .purple)
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            FeedbackParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Info Card
                    infoCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Category Selection
                    categorySection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Subject Field
                    subjectSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Message Field
                    messageSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Submit Button
                    submitButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    
                    // Tips Section
                    tipsSection
                        .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 40)
                }
            }
            
            // Floating navigation bar
            VStack {
                floatingNavBar
                Spacer()
            }
            
            // Loading Overlay
            if isSubmitting {
                loadingOverlay
            }
            
            // Thank You Overlay
            if showThankYou {
                thankYouOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
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
                            colors: [.cyan.opacity(0.6), .blue.opacity(0.6)],
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
                                colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "envelope.badge.fill")
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
                Text("We'd Love to Hear from You")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("Your feedback helps us improve Cosmos Explorer")
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
    
    // MARK: - Info Card
    private var infoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.cyan)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("We typically respond within 24 hours")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("All fields are required")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
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
        .animation(.spring(response: 0.6).delay(0.1), value: animateContent)
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Select Category")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    categoryCard(category, delay: Double(index) * 0.05 + 0.15)
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.15), value: animateContent)
    }
    
    private func categoryCard(_ category: FeedbackCategory, delay: Double) -> some View {
        Button {
            HapticManager.impact(style: .light)
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category.name
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(category.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            selectedCategory == category.name ?
                                category.color.opacity(0.6) :
                                category.color.opacity(0.3),
                            lineWidth: selectedCategory == category.name ? 2 : 1
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 26))
                        .foregroundColor(category.color)
                }
                
                Text(category.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                selectedCategory == category.name ?
                                    LinearGradient(
                                        colors: [category.color.opacity(0.6), category.color.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: selectedCategory == category.name ? category.color.opacity(0.3) : .clear,
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Subject Section
    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Subject")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            TextField("", text: $subject, prompt: Text("Brief description of your feedback").foregroundColor(.white.opacity(0.4)))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    subject.isEmpty ?
                                    LinearGradient(
                                            colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.5), .blue.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                    lineWidth: 1
                                )
                        )
                )
                .foregroundColor(.white)
                .font(.system(size: 15))
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.3), value: animateContent)
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Message")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
                
                Text("\(message.count)/1000")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            ZStack(alignment: .topLeading) {
                if message.isEmpty {
                    Text("Tell us more about your feedback. Include any details that might help us understand your request better...")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $message)
                    .frame(height: 160)
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .font(.system(size: 15))
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                message.isEmpty ?
                                LinearGradient(
                                        colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.5), .blue.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            HapticManager.impact(style: .heavy)
            submitFeedback()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                Text("Submit Feedback")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        (subject.isEmpty || message.isEmpty) ?
                            LinearGradient(
                                colors: [.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                (subject.isEmpty || message.isEmpty) ?
                                    Color.white.opacity(0.1) :
                                    Color.cyan.opacity(0.5),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: (subject.isEmpty || message.isEmpty) ? .clear : Color.cyan.opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
            )
        }
        .disabled(subject.isEmpty || message.isEmpty || isSubmitting)
        .buttonStyle(ScaleButtonStyle())
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.5), value: animateContent)
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Tips for Better Feedback")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                tipPoint(
                    icon: "checkmark.circle.fill",
                    text: "Be specific about the issue or feature",
                    color: .green
                )
                
                tipPoint(
                    icon: "text.bubble.fill",
                    text: "Include steps to reproduce bugs",
                    color: .blue
                )
                
                tipPoint(
                    icon: "photo.fill",
                    text: "Mention your device and app version",
                    color: .purple
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.6), value: animateContent)
    }
    
    private func tipPoint(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.cyan)
                
                Text("Sending feedback...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Thank You Overlay
    private var thankYouOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showThankYou ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showThankYou)
                
                VStack(spacing: 12) {
                    Text("Thank You!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your feedback has been received. We'll review it and get back to you soon!")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showThankYou = false
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func submitFeedback() {
        isSubmitting = true
        
        viewModel.loadCurrentUserIfNeeded { user in
            guard let user = user else {
                errorMessage = "User not found"
                showErrorAlert = true
                isSubmitting = false
                return
            }
            
            let feedback = FeedbackModel(
                userId: user.id,
                username: user.username ?? "Unknown",
                email: user.email,
                category: selectedCategory,
                subject: subject,
                message: message,
                timestamp: Date()
            )
            
            viewModel.submitFeedback(feedback: feedback) { result in
                isSubmitting = false
                switch result {
                case .success:
                    withAnimation {
                        showThankYou = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Feedback Category Model
struct FeedbackCategory {
    let id: String
    let name: String
    let icon: String
    let color: Color
}

// MARK: - Particle Field Effect
struct FeedbackParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
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
    SendFeedbackView()
        .environmentObject(AuthViewModel())
}
