//
//  FlashcardsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI
import SwiftData

// This view displays the flashcards mode, with card flip, hint, edit (if owner), left/right arrows, and completion screen.
struct FlashcardsView: View {
    @StateObject private var viewModel: FlashcardsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(quiz: Quiz, service: SwiftDataService, currentUserId: UUID? = nil) {
        _viewModel = StateObject(wrappedValue: FlashcardsViewModel(quiz: quiz, service: service))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if viewModel.isCompleted {
                        FlashcardsCompletion(
                            correct: viewModel.correctCount,
                            total: viewModel.totalCount,
                            backToLast: viewModel.backToLast,
                            continueAction: {
                                viewModel.reset()
                                viewModel.isCompleted = false
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    } else if let card = viewModel.currentCard {
                        // Progress
                        ProgressView(value: Double(viewModel.attempt.currentIndex + 1), total: Double(viewModel.quiz.cards.count))
                            .progressViewStyle(.linear)
                            .tint(.blue)
                            .padding(.horizontal)
                            .animation(.easeInOut, value: viewModel.attempt.currentIndex)
                        
                        // Card
                        VStack(spacing: 16) {
                            // Flip card
                            ZStack(alignment: .bottomTrailing) {
                                FlipCardView(
                                    front: cardFrontView(card),
                                    back: cardBackView(card),
                                    showBack: $viewModel.showAnswer
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                                .padding(.horizontal)
                                .onTapGesture { viewModel.flipCard() }
                            }
                            
                            // Hint
                            if viewModel.showHint, let hint = card.hint {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text("Hint: \(hint)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // Action buttons
                            HStack(spacing: 4) {
                                Button(action: { viewModel.previousCard() }) {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(Color(.systemGray5))
                                        .clipShape(Circle())
                                }
                                .disabled(viewModel.attempt.currentIndex == 0)
                                .opacity(viewModel.attempt.currentIndex == 0 ? 0.5 : 1.0)
                                
                                HStack(spacing: 8) {
                                    Button("Know") {
                                        withAnimation { viewModel.nextCard(correct: true) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                    .cornerRadius(25)
                                    
                                    Button("Don't Know") {
                                        withAnimation { viewModel.nextCard(correct: false) }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    .cornerRadius(25)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                            
                            // Get Hint Button
                            HStack {
                                Button(action: {
                                    withAnimation { viewModel.showHint.toggle() }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: viewModel.showHint ? "lightbulb.slash.fill" : "lightbulb.fill")
                                        Text(viewModel.showHint ? "Hide Hint" : "Get Hint")
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.showHint ? Color.orange.gradient : Color.blue.gradient)
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showHint)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.toggleFavorite() }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isFavorite ? .red : .primary)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.loadCurrentCard()
            }
        }
    }
    
    // MARK: - Card Views
    @ViewBuilder
    private func cardFrontView(_ card: Card) -> some View {
        VStack(spacing: 16) {
            if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)
            }
            
            if let formattingData = card.termFormatting,
               let attributed = try? NSAttributedString(
                   data: formattingData,
                   options: [.documentType: NSAttributedString.DocumentType.rtfd],
                   documentAttributes: nil
               ) {
                Text(attributed.string)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding()
            } else {
                Text(card.term)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding()
            }
            
            Spacer()
            Text("Tap to flip")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    private func cardBackView(_ card: Card) -> some View {
        VStack(spacing: 16) {
            if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)
            }
            
            if let formattingData = card.definitionFormatting,
               let attributed = try? NSAttributedString(
                   data: formattingData,
                   options: [.documentType: NSAttributedString.DocumentType.rtfd],
                   documentAttributes: nil
               ) {
                Text(AttributedString(attributed))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text(card.definition)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.opacity(0.1))
                .shadow(radius: 4)
        )
        .padding(.horizontal, 4)
    }
}

// MARK: - FlipCardView
struct FlipCardView<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @Binding var showBack: Bool
    
    var body: some View {
        ZStack {
            front
                .modifier(FlipModifier(isFlipped: showBack, axis: (x: 0, y: 1, z: 0)))
                .opacity(showBack ? 0 : 1)
            
            back
                .modifier(FlipModifier(isFlipped: !showBack, axis: (x: 0, y: 1, z: 0)))
                .opacity(showBack ? 1 : 0)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showBack)
    }
}

struct FlipModifier: AnimatableModifier {
    var isFlipped: Bool
    let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    
    var animatableData: CGFloat {
        get { isFlipped ? 1 : 0 }
        set { }
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: axis
            )
    }
}

#Preview {
    ValueTransformer.registerIfNeeded()
    let service = SwiftDataService(inMemory: true)
    let sampleQuiz = Quiz(
        title: "Sample Flashcards",
        quizDescription: "Demo",
        isPublic: true,
        createdBy: nil,
        categories: ["Flashcards"]
    )
    sampleQuiz.cards = [
        Card(term: "Cosmos", definition: "Wowwwww"),
        Card(term: "Universe", definition: "Naniiiiii")
    ]
    
    return FlashcardsView(quiz: sampleQuiz, service: service)
}
