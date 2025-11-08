//
//  LearnView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI
import SwiftData

// Similar to Flashcards, but with multiple choice options.
struct LearnView: View {
    @StateObject private var viewModel: LearnViewModel
    @Environment(\.dismiss) private var dismiss

    init(quiz: Quiz, service: SwiftDataService) {
        _viewModel = StateObject(wrappedValue: LearnViewModel(quiz: quiz, service: service))
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

                VStack(spacing: 20) {
                    if viewModel.isCompleted {
                        completionView
                            .transition(.scale.combined(with: .opacity))
                    } else if let card = viewModel.currentCard {
                        mainContent(card: card)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
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

    // MARK: - Completion View
    @ViewBuilder
    private var completionView: some View {
        LearnCompletionView(
            correct: viewModel.correctCount,
            total: viewModel.quiz.cards.count,
            backToLast: viewModel.backToLast,
            continueAction: {
                viewModel.reset()
                viewModel.isCompleted = false
            }
        )
    }

    // MARK: - Main Content
    @ViewBuilder
    private func mainContent(card: Card) -> some View {
        VStack(spacing: 16) {
            // Progress
            ProgressView(value: progressValue, total: progressTotal)
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)
                .animation(.easeInOut, value: progressValue)

            // Term + Image
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
                    .padding()

                Text("Choose the correct answer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Options
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.options, id: \.self) { option in
                    Button(action: {
                        viewModel.selectOption(option)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                viewModel.nextCard()
                            }
                        }
                    }) {
                        optionButtonContent(option: option, correct: card.definition)
                    }
                    .disabled(viewModel.selectedOption != nil)
                }
            }
            .padding(.horizontal)

            // I don't know
            Button("I don't know") {
                viewModel.dontKnow()
                withAnimation {
                    viewModel.nextCard()
                }
            }
            .foregroundColor(.red)
            .padding(.top, 8)

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

    // MARK: - Option Button Content
    @ViewBuilder
    private func optionButtonContent(option: String, correct: String) -> some View {
        HStack {
            Text(option)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)

            if viewModel.selectedOption == option {
                Image(systemName: option == correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            backgroundColor(for: option, correct: correct)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(borderColor(for: option, correct: correct), lineWidth: 2)
        )
    }

    // MARK: - Background Color
    @ViewBuilder
    private func backgroundColor(for option: String, correct: String) -> some View {
        if viewModel.selectedOption == option {
            if option == correct {
                Color.green.opacity(0.2)
            } else {
                Color.red.opacity(0.2)
            }
        } else {
            Color(.systemGray6)
        }
    }

    // MARK: - Border Color
    private func borderColor(for option: String, correct: String) -> Color {
        if viewModel.selectedOption == option {
            return option == correct ? .green : .red
        } else {
            return .gray
        }
    }
    
    private var progressValue: Double {
        let total = Double(viewModel.quiz.cards.count)
        guard total > 0 else { return 0 }
        
        return min(Double(viewModel.attempt.currentIndex + 1), total)
    }

    private var progressTotal: Double {
        max(Double(viewModel.quiz.cards.count), 1)
    }
}

// MARK: - Preview
#Preview {
    ValueTransformer.registerIfNeeded()
    let service = SwiftDataService(inMemory: true)
    let quiz = Quiz(
        title: "Sample Learn",
        quizDescription: "Multiple choice learning",
        isPublic: true,
        createdBy: nil,
        categories: ["Learn"]
    )
    quiz.cards = [
        Card(term: "Sun", definition: "Star at center"),
        Card(term: "Moon", definition: "Natural satellite")
    ]
    return LearnView(quiz: quiz, service: service)
}
