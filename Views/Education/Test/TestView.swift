//
//  TestView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI

// Test mode with initial type selection, then random types per question, I don't know.
struct TestView: View {
    @StateObject private var viewModel: TestViewModel
    @State private var showTypes = true
    @Environment(\.dismiss) private var dismiss
    
    init(quiz: Quiz, service: SwiftDataService) {
        _viewModel = StateObject(wrappedValue: TestViewModel(quiz: quiz, service: service))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                Group {
                    if showTypes {
                        typeSelectionView
                    } else if viewModel.isCompleted {
                        TestCompletionView(
                            correct: viewModel.correctCount,
                            total: viewModel.quiz.cards.count,
                            backToLast: viewModel.backToLast,
                            continueAction: {
                                viewModel.reset()
                                viewModel.selectedTypes = ["Multiple Choice", "True or False", "Written", "Fill in the Blank"]
                                viewModel.startTest()
                                withAnimation {
                                    showTypes = true
                                    viewModel.isCompleted = false
                                }
                            }
                        )
                    } else if let card = viewModel.currentCard {
                        questionView(card: card)
                    }
                }
            }
            .navigationTitle(showTypes ? "Test Settings" : viewModel.isCompleted ? "Results" : "Test")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Type Selection
    private var typeSelectionView: some View {
        Form {
            Section("Question Types") {
                ForEach(["Multiple Choice", "True or False", "Written", "Fill in the Blank"], id: \.self) { type in
                    Toggle(type, isOn: binding(for: type))
                }
            }
            
            Button("Start Test") {
                viewModel.startTest()
                withAnimation { showTypes = false }
            }
            .disabled(viewModel.selectedTypes.isEmpty)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
    
    // MARK: - Question View
    @ViewBuilder
    private func questionView(card: Card) -> some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(viewModel.attempt.currentIndex + 1), total: Double(viewModel.quiz.cards.count))
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)

            VStack(spacing: 16) {
                Text(card.term)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding()

                switch viewModel.currentType {
                case "Multiple Choice":
                    multipleChoiceView
                case "True or False":
                    trueFalseView
                case "Written":
                    writtenView
                case "Fill in the Blank":
                    fillInBlankView
                default:
                    EmptyView()
                }

                Button("I don’t know", role: .destructive) {
                    viewModel.dontKnow()
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Multiple Choice
    private var multipleChoiceView: some View {
        ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, option in
            Button {
                viewModel.userAnswer = option
                viewModel.submitAnswer()
            } label: {
                HStack {
                    Text(option)
                    Spacer()
                    if viewModel.userAnswer == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            }
            .disabled(!viewModel.userAnswer.isEmpty)
        }
    }
    
    // MARK: - True or False
    private var trueFalseView: some View {
        VStack(spacing: 20) {
            Text(viewModel.displayedDefinition)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            HStack(spacing: 30) {
                Button("True") {
                    viewModel.isTrueFalse = true
                    viewModel.submitAnswer()
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isTrueFalse == true ? .green : .blue)
                .frame(maxWidth: .infinity)

                Button("False") {
                    viewModel.isTrueFalse = false
                    viewModel.submitAnswer()
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isTrueFalse == false ? .red : .blue)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Written
    private var writtenView: some View {
        VStack {
            TextField("Type your answer...", text: $viewModel.userAnswer)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            Button("Submit") {
                viewModel.submitAnswer()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
    
    // MARK: - Fill in the Blank
    private var fillInBlankView: some View {
        VStack(spacing: 20) {
            Text(viewModel.blankedTerm)
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(viewModel.fillOptions.enumerated()), id: \.offset) { index, option in
                    Button {
                        viewModel.userAnswer = option
                        viewModel.submitAnswer()
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.userAnswer == option ? Color.blue.opacity(0.2) : Color(.systemGray6))
                            )
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func binding(for type: String) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedTypes.contains(type) },
            set: { if $0 { viewModel.selectedTypes.insert(type) } else { viewModel.selectedTypes.remove(type) } }
        )
    }
}

#Preview {
    let service = SwiftDataService(inMemory: true)
    let quiz = Quiz(title: "Sample Test", quizDescription: "", isPublic: true, createdBy: nil, categories: ["Test"])
    quiz.cards = [
        Card(term: "Earth", definition: "Blue planet"),
        Card(term: "Mars", definition: "Red planet"),
        Card(term: "Jupiter", definition: "Largest planet"),
        Card(term: "Venus", definition: "Hottest planet")
    ]
    return TestView(quiz: quiz, service: service)
}
