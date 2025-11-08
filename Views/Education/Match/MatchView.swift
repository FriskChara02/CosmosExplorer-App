//
//  MatchView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI

// Match game: 4x4 grid, half terms half defs, select pair to match/disappear.
struct MatchView: View {
    @StateObject private var viewModel: MatchViewModel
    @Environment(\.dismiss) private var dismiss
        
        init(quiz: Quiz, service: SwiftDataService) {
            let viewModel = MatchViewModel(quiz: quiz, service: service)
            _viewModel = StateObject(wrappedValue: viewModel)
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isCompleted {
                    MatchCompletionView(
                        correct: viewModel.correctCount,
                        total: viewModel.matchedPairs.count,
                        continueAction: viewModel.reset
                    )
                    .transition(.scale.combined(with: .opacity))
                } else {
                    MatchGridView(viewModel: viewModel)
                }
            }
            .navigationTitle("Match Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if viewModel.attempt.id == 0 {
                    viewModel.startMatch()
                }
            }
        }
    }
}

// MARK: - Grid View
private struct MatchGridView: View {
    @ObservedObject var viewModel: MatchViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        VStack {
            // Progress
            ProgressView(value: Double(viewModel.matchedPairs.count), total: Double(viewModel.gridItems.count / 2))
                .progressViewStyle(.linear)
                .tint(.green)
                .padding(.horizontal)
            
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
            
            // Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.gridItems) { item in
                    if !viewModel.matchedPairs.contains(item.cardId) {
                        MatchCardView(
                            item: item,
                            isSelected: viewModel.selectedItem1?.id == item.id || viewModel.selectedItem2?.id == item.id,
                            isWrong: viewModel.selectedItem1 != nil &&
                                     viewModel.selectedItem2 != nil &&
                                     !viewModel.matchedPairs.contains(item.cardId) &&
                                     item.id != viewModel.selectedItem1?.id &&
                                     item.id != viewModel.selectedItem2?.id
                        ) {
                            viewModel.selectItem(item)
                        }
                        .animation(.spring(response: 0.3), value: viewModel.matchedPairs)
                    }
                }
            }
            .padding()
            .environment(\.matchedPairs, viewModel.matchedPairs)
            
            Spacer()
        }
        .animation(.easeInOut, value: viewModel.selectedItem1)
        .animation(.easeInOut, value: viewModel.selectedItem2)
    }
}

// MARK: - Card View
private struct MatchCardView: View {
    let item: MatchItem
    let isSelected: Bool
    let isWrong: Bool
    let onTap: () -> Void
    
    @Environment(\.matchedPairs) private var matchedPairs: Set<Int64>
    
    var body: some View {
        Text(item.text)
            .font(.system(size: 13, weight: .medium))
            .multilineTextAlignment(.center)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1.5)
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.4), value: matchedPairs)
            .onTapGesture(perform: onTap)
            .disabled(matchedPairs.contains(item.cardId))
    }
    
    // MARK: - Visual Properties
    private var backgroundColor: Color {
        if matchedPairs.contains(item.cardId) {
            return .green.opacity(0.2)
        }
        return isSelected ? .blue.opacity(0.3) : .gray.opacity(0.15)
    }
    
    private var textColor: Color {
        matchedPairs.contains(item.cardId) ? .green : .primary
    }
    
    private var borderColor: Color {
        if isWrong { return .red }
        if isSelected { return .blue }
        if matchedPairs.contains(item.cardId) { return .green }
        return .gray.opacity(0.3)
    }
}

private struct MatchedPairsKey: EnvironmentKey {
    static let defaultValue: Set<Int64> = []
}

extension EnvironmentValues {
    var matchedPairs: Set<Int64> {
        get { self[MatchedPairsKey.self] }
        set { self[MatchedPairsKey.self] = newValue }
    }
}

#Preview {
    let service = SwiftDataService()
    let quiz = Quiz(title: "Demo", quizDescription: "", isPublic: true, createdBy: nil, categories: ["Match"])
    return MatchView(quiz: quiz, service: service)
}
