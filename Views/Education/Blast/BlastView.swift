//
//  BlastView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI
import AVFoundation

// Blast game: Question top, floating answers, tap correct/green wrong/red.
struct BlastView: View {
    @StateObject private var viewModel: BlastViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tappedOption: String? = nil
    
    init(quiz: Quiz, service: SwiftDataService) {
        _viewModel = StateObject(wrappedValue: BlastViewModel(quiz: quiz, service: service))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.isCompleted {
                    BlastCompletionView(
                        correct: viewModel.correctCount,
                        total: viewModel.quiz.cards.count,
                        backToLast: viewModel.backToLast,
                        continueAction: {
                            viewModel.reset()
                            withAnimation {
                                viewModel.isCompleted = false
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                } else if viewModel.quiz.cards.isEmpty {
                    Text("No cards available for this quiz")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                } else if let card = viewModel.currentCard {
                    mainContent(card: card)
                }
            }
            .navigationTitle("Blast Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.loadCurrentCard()
            }
        }
    }
    
    private func mainContent(card: Card) -> some View {
        VStack(spacing: 16) {
            // Progress
            ProgressView(value: Double(viewModel.attempt.currentIndex), total: Double(viewModel.quiz.cards.count))
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)
                .animation(.easeInOut, value: viewModel.attempt.currentIndex)
            
            // Score
            HStack {
                Label("\(viewModel.correctCount)", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Spacer()
                Label("\(viewModel.incorrectCount)", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .font(.headline)
            .padding(.horizontal)
            
            // Question
            VStack(spacing: 12) {
                if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12)
                }
                
                Text(card.term)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Tap the correct definition")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Floating Bubbles
            GeometryReader { geometry in
                ZStack {
                    ForEach(viewModel.floatingOptions, id: \.0) { option, position in
                        FloatingOptionView(
                            option: option,
                            isCorrect: option == card.definition,
                            isTapped: tappedOption == option,
                            geometry: geometry,
                            onTap: {
                                withAnimation(.spring(response: 0.4)) {
                                    tappedOption = option
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation {
                                        viewModel.tapOption(option)
                                        tappedOption = nil
                                    }
                                }
                            }
                        )
                        .position(position)
                        .offset(y: -100)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Floating Option with Circular Bubble & Explosion
struct FloatingOptionView: View {
    let option: String
    let isCorrect: Bool
    let isTapped: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    @State private var floatOffset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var showExplosion: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    private let bubbleSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Quả bóng tròn
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isTapped
                                ? (isCorrect ? [.green.opacity(0.5), .green.opacity(0.3)] : [.red.opacity(0.5), .red.opacity(0.3)])
                                : [.white.opacity(0.7), .white.opacity(0.4)],
                            center: .center,
                            startRadius: 10,
                            endRadius: bubbleSize / 2
                        )
                    )
                    .frame(width: bubbleSize, height: bubbleSize)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .scaleEffect(isTapped ? 1.15 : pulseScale)
                
                Circle()
                    .strokeBorder(
                        isTapped
                            ? (isCorrect ? Color.green : Color.red)
                            : Color.gray.opacity(0.6),
                        lineWidth: isTapped ? 4 : 2
                    )
                    .frame(width: bubbleSize, height: bubbleSize)
                
                Text(option)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isTapped ? .white : .primary)
                    .padding(8)
                    .frame(maxWidth: bubbleSize - 20)
            }
            .offset(floatOffset)
            .rotationEffect(.degrees(rotation))
            .zIndex(1)
            .onTapGesture {
                guard !isTapped else { return }
                triggerTapFeedback()
                onTap()
            }
            
            // Hiệu ứng nổ
            if showExplosion {
                BubbleExplosionEffect()
                    .frame(width: 140, height: 140)
                    .zIndex(0)
            }
        }
        .onAppear {
            startFloatingAnimation()
            startPulseAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        withAnimation(
            Animation.easeInOut(duration: Double.random(in: 2.5...4.0))
                .repeatForever(autoreverses: true)
        ) {
            floatOffset = CGSize(
                width: CGFloat.random(in: -25...25),
                height: CGFloat.random(in: -25...25)
            )
            rotation = Double.random(in: -8...8)
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }
    }
    
    private func triggerTapFeedback() {
        showExplosion = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            showExplosion = false
        }
    }
}

// MARK: - Bubble Explosion Effect
struct BubbleExplosionEffect: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 1.0
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        let offset: CGSize
        let delay: Double
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.yellow.opacity(0.8), .orange.opacity(0.4), .clear], center: .center, startRadius: 5, endRadius: 70))
                .frame(width: 140, height: 140)
                .scaleEffect(scale)
                .opacity(opacity)
            
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: 16, height: 16)
                    .offset(particle.offset)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeOut(duration: 0.6).delay(particle.delay),
                        value: scale
                    )
            }
        }
        .onAppear {
            particles = (0..<12).map { i in
                let angle = Double(i) * 30 * .pi / 180
                let distance: CGFloat = CGFloat.random(in: 60...100)
                return Particle(
                    offset: CGSize(width: cos(angle) * distance, height: sin(angle) * distance),
                    delay: Double.random(in: 0...0.15)
                )
            }
            
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.8
                opacity = 0
            }
        }
    }
}

#Preview {
    let service = SwiftDataService()
    let quiz = Quiz(title: "Demo", quizDescription: "", isPublic: true, createdBy: nil, categories: ["Blast"])
    return BlastView(quiz: quiz, service: service)
}
