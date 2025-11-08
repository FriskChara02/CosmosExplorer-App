//
//  BlastView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI

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
            
            // Floating Options với animation bay lơ lửng
            GeometryReader { geometry in
                ZStack {
                    ForEach(viewModel.floatingOptions, id: \.0) { option, position in
                        FloatingOptionView(
                            option: option,
                            isCorrect: option == card.definition,
                            isTapped: tappedOption == option,
                            geometry: geometry,
                            onTap: {
                                // Xử lý tap
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

// MARK: - Floating Option with Local Explosion
struct FloatingOptionView: View {
    let option: String
    let isCorrect: Bool
    let isTapped: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var showExplosion: Bool = false
    
    var body: some View {
        ZStack {
            // Nội dung đáp án
            Text(option)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(12)
                .frame(maxWidth: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isTapped ? (isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)) : Color.gray.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTapped ? (isCorrect ? Color.green : Color.red) : Color.gray, lineWidth: 2)
                )
                .scaleEffect(isTapped ? 1.1 : 1.0)
                .offset(offset)
                .rotationEffect(.degrees(rotation))
                .animation(.spring(response: 0.3), value: isTapped)
                .zIndex(1)
            
            if showExplosion {
                ExplosionEffect()
                    .zIndex(0)
            }
        }
        .onAppear {
            startFloatingAnimation()
        }
        .onTapGesture {
            guard !isTapped else { return }
            showExplosion = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showExplosion = false
            }
        }
    }
    
    private func startFloatingAnimation() {
        withAnimation(
            Animation.easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
        ) {
            offset = CGSize(
                width: CGFloat.random(in: -30...30),
                height: CGFloat.random(in: -30...30)
            )
            rotation = Double.random(in: -10...10)
        }
    }
}

// MARK: - Explosion Effect
struct ExplosionEffect: View {
    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 1.0
    @State private var particleOffsets: [CGSize] = []
    
    var body: some View {
        ZStack {
            // Vòng tròn chính
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [.yellow, .orange, .red]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 60
                ))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .opacity(opacity)
            
            // Particles bay ra xung quanh
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.orange)
                    .frame(width: 20, height: 20)
                    .offset(particleOffsets.indices.contains(index) ? particleOffsets[index] : .zero)
                    .opacity(opacity)
            }
        }
        .onAppear {
            particleOffsets = (0..<8).map { index in
                let angle = Double(index) * (360.0 / 8.0) * .pi / 180.0
                let distance: CGFloat = 80
                return CGSize(
                    width: cos(angle) * distance,
                    height: sin(angle) * distance
                )
            }
            
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 2.0
                opacity = 0.0
            }
        }
    }
}

#Preview {
    let service = SwiftDataService()
    let quiz = Quiz(title: "Demo", quizDescription: "", isPublic: true, createdBy: nil, categories: ["Blast"])
    return BlastView(quiz: quiz, service: service)
}
