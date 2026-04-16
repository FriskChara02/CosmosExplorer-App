//
//  RateUsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 4/12/25.
//

import SwiftUI
import PostgresClientKit
import Foundation
import SwiftData

// MARK: - Rating Model
@Model
final class RatingModel: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var username: String
    var avatar: String?
    var rating: Int
    var review: String
    var timestamp: Date
    
    init(id: UUID = UUID(), userId: UUID, username: String, avatar: String? = nil, rating: Int, review: String, timestamp: Date = Date()) {
        self.id = id
        self.userId = userId
        self.username = username
        self.avatar = avatar
        self.rating = rating
        self.review = review
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, username, avatar, rating, review, timestamp
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        rating = try container.decode(Int.self, forKey: .rating)
        review = try container.decode(String.self, forKey: .review)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(username, forKey: .username)
        try container.encodeIfPresent(avatar, forKey: .avatar)
        try container.encode(rating, forKey: .rating)
        try container.encode(review, forKey: .review)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - Rate Us View
struct RateUsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var userRating = 0
    @State private var review = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var animatingReviews: [RatingModel] = []
    @State private var offset: CGFloat = 0
    @State private var animateContent = false
    @State private var showThankYou = false
    
    // Mock data
    let allReviews: [RatingModel] = [
        RatingModel(userId: UUID(), username: "Hieu Nguyen", avatar: nil, rating: 5, review: "Amazing app! Love exploring the cosmos!", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Jake Emma", avatar: nil, rating: 4, review: "Great features and beautiful design", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Cu Duc Dung", avatar: nil, rating: 5, review: "Best astronomy app ever!", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Loi Nguyen", avatar: nil, rating: 5, review: "Incredibly educational and fun", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Tuyet Nguyen", avatar: nil, rating: 4, review: "Love the quiz feature!", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Anh Nguyet", avatar: nil, rating: 5, review: "I Love this App ^^", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Darling", avatar: nil, rating: 5, review: "App dùng đã ghê", timestamp: Date()),
        RatingModel(userId: UUID(), username: "Sayaka", avatar: nil, rating: 4, review: "Ngonnnnnnn", timestamp: Date())
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            // Animated particles
            RateParticleField()
                .opacity(0.3)
            
            // Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 100)
                    
                    // Header
                    headerSection
                        .padding(.bottom, 32)
                    
                    // Stats Card
                    statsCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    
                    // Rating Section
                    ratingSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Review Section
                    reviewSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Submit Button
                    submitButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    
                    // Review Carousel
                    if !animatingReviews.isEmpty {
                        reviewCarousel
                            .padding(.bottom, 24)
                    }
                    
                    // Why Rate Section
                    whyRateSection
                        .padding(.horizontal, 20)
                    
                    Color.clear.frame(height: 40)
                }
            }
            
            // Floating navigation bar
            VStack {
                floatingNavBar
                Spacer()
            }
            
            // Thank You Animation
            if showThankYou {
                thankYouOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startReviewAnimation()
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
                                Color.yellow.opacity(0.5),
                                Color.orange.opacity(0.3),
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
                            colors: [.yellow.opacity(0.6), .orange.opacity(0.6)],
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
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animateContent ? 1 : 0.5)
            }
            
            // Title and description
            VStack(spacing: 12) {
                Text("Rate Cosmos Explorer")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Your feedback helps us improve and grow")
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
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            statItem(
                icon: "star.fill",
                value: "4.8",
                label: "Average",
                color: .yellow
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "person.3.fill",
                value: "1.2K",
                label: "Reviews",
                color: .cyan
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            statItem(
                icon: "chart.line.uptrend.xyaxis",
                value: "95%",
                label: "5-Star",
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
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
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
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Tap Stars to Rate")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        HapticManager.impact(style: .medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            userRating = star
                        }
                    } label: {
                        ZStack {
                            if star <= userRating {
                                Circle()
                                    .fill(Color.yellow.opacity(0.2))
                                    .frame(width: 56, height: 56)
                                    .blur(radius: 10)
                            }
                            
                            Image(systemName: star <= userRating ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundStyle(
                                    star <= userRating ?
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .scaleEffect(star == userRating ? 1.2 : 1.0)
                                .shadow(
                                    color: star <= userRating ? Color.yellow.opacity(0.5) : .clear,
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.vertical, 10)
            
            if userRating > 0 {
                Text(ratingMessage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.yellow)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: userRating > 0 ?
                                    [.yellow.opacity(0.5), .orange.opacity(0.3)] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: userRating > 0 ? Color.yellow.opacity(0.2) : .clear,
                    radius: 15,
                    x: 0,
                    y: 8
                )
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.2), value: animateContent)
    }
    
    private var ratingMessage: String {
        switch userRating {
        case 5: return "Awesome!"
        case 4: return "Great!"
        case 3: return "Good!"
        case 2: return "Could be better"
        case 1: return "We'll improve!"
        default: return ""
        }
    }
    
    // MARK: - Review Section
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Write a Review (Optional)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                if review.isEmpty {
                    Text("Tell us what you think about Cosmos Explorer...")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $review)
                    .frame(height: 120)
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
                                review.isEmpty ?
                                LinearGradient(
                                        colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.4), .orange.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                lineWidth: 1
                            )
                    )
            )
            
            HStack {
                Spacer()
                Text("\(review.count)/500")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.3), value: animateContent)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            HapticManager.impact(style: .heavy)
            submitRating()
        } label: {
            HStack(spacing: 12) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                    Text("Submit Rating")
                        .font(.system(size: 17, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        userRating == 0 ?
                            LinearGradient(
                                colors: [.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                userRating > 0 ?
                                    Color.yellow.opacity(0.5) :
                                    Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: userRating > 0 ? Color.yellow.opacity(0.4) : .clear,
                        radius: 15,
                        x: 0,
                        y: 8
                    )
            )
        }
        .disabled(userRating == 0 || isSubmitting)
        .buttonStyle(ScaleButtonStyle())
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6).delay(0.4), value: animateContent)
    }
    
    // MARK: - Review Carousel
    private var reviewCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Recent Reviews")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            GeometryReader { geometry in
                HStack(spacing: 16) {
                    ForEach(animatingReviews) { review in
                        ReviewCard(review: review)
                            .frame(width: geometry.size.width * 0.85)
                    }
                }
                .offset(x: offset)
                .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: offset)
            }
            .frame(height: 200)
            .clipped()
        }
        .opacity(animateContent ? 1 : 0)
        .animation(.spring(response: 0.6).delay(0.5), value: animateContent)
    }
    
    // MARK: - Why Rate Section
    private var whyRateSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Why Your Rating Matters")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                whyRatePoint(
                    icon: "sparkles",
                    text: "Helps us improve the app",
                    color: .yellow
                )
                
                whyRatePoint(
                    icon: "person.3.fill",
                    text: "Assists other users in making decisions",
                    color: .cyan
                )
                
                whyRatePoint(
                    icon: "heart.fill",
                    text: "Shows support for our small team",
                    color: .pink
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
    
    private func whyRatePoint(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    // MARK: - Thank You Overlay
    private var thankYouOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success Animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .scaleEffect(showThankYou ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showThankYou)
                
                VStack(spacing: 12) {
                    Text("Thank You!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your rating has been submitted successfully")
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
    private func startReviewAnimation() {
        animatingReviews = allReviews + allReviews
        offset = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.85 + 16
            offset = -cardWidth * CGFloat(allReviews.count)
        }
    }
    
    private func submitRating() {
        isSubmitting = true
        
        viewModel.loadCurrentUserIfNeeded { user in
            guard let user = user else {
                errorMessage = "User not found"
                showErrorAlert = true
                isSubmitting = false
                return
            }
            
            let rating = RatingModel(
                userId: user.id,
                username: user.username ?? "Unknown",
                avatar: user.avatar,
                rating: userRating,
                review: review.isEmpty ? "" : review,
                timestamp: Date()
            )
            
            viewModel.submitRating(rating: rating) { result in
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

// MARK: - Review Card Component
struct ReviewCard: View {
    let review: RatingModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                if let avatar = review.avatar, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        defaultAvatar
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                } else {
                    defaultAvatar
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(review.username)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(star <= review.rating ? .yellow : .white.opacity(0.3))
                        }
                    }
                    
                    Text(review.timestamp, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
            }
            
            Text(review.review)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)
                .lineSpacing(4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.yellow.opacity(0.4), .orange.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay(
                Text(String(review.username.prefix(1)))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - Particle Field Effect
struct RateParticleField: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.4),
                                Color.orange.opacity(0.3),
                                Color.pink.opacity(0.2)
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
    RateUsView()
        .environmentObject(AuthViewModel())
}
