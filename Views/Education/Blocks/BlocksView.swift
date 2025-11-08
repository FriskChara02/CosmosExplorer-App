//
//  BlocksView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI

// Blocks game: 10x10 grid, drag shapes to fill, every 2 placements ask question, 3 wrong restart.
struct BlocksView: View {
    @StateObject private var viewModel: BlocksViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var gridFrame: CGRect = .zero
    @State private var dragOffset: CGSize = .zero
    
    init(quiz: Quiz, service: SwiftDataService) {
        _viewModel = StateObject(wrappedValue: BlocksViewModel(quiz: quiz, service: service))
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
                    BlocksCompletionView(
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
                } else {
                    mainContent
                }
            }
            .navigationTitle("Blocks Game")
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
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if viewModel.currentShape.isEmpty {
                    viewModel.generateNextShape()
                }
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 16) {
            // Progress
            ProgressView(value: Double(viewModel.placeCount), total: Double(viewModel.quiz.cards.count * 2))
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)
            
            // Score and Attempts
            HStack {
                Label("\(viewModel.correctCount)", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Spacer()
                Label("\(viewModel.incorrectCount)", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
                Spacer()
                Label("\(viewModel.attemptsLeft)", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
            }
            .font(.headline)
            .padding(.horizontal)
            
            GeometryReader { geometry in
                GridView(grid: viewModel.grid)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        gridFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                        gridFrame = newFrame
                    }
            }
            .frame(height: 360)
            .padding()
            
            if !viewModel.currentShape.isEmpty {
                ShapeView(shape: viewModel.currentShape)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.3)) {
                                    dragOffset = .zero
                                }
                                
                                let cellSize: CGFloat = 34
                                let padding: CGFloat = 4
                                
                                // 1. Lấy vị trí thả (global)
                                let dropGlobal = value.location
                                
                                // 2. Chuyển về local trong grid
                                let gridLocalX = dropGlobal.x - gridFrame.minX
                                let gridLocalY = dropGlobal.y - gridFrame.minY
                                
                                // 3. Tính toán tâm của shape (rộng bao nhiêu ô?)
                                let shapeWidth = viewModel.currentShape[0].count
                                let shapeHeight = viewModel.currentShape.count
                                
                                // 4. Tính offset tâm shape so với góc trên-trái
                                let shapeCenterOffsetX = CGFloat(shapeWidth) * cellSize / 2
                                let shapeCenterOffsetY = CGFloat(shapeHeight) * cellSize / 2
                                
                                // 5. Điều chỉnh lại vị trí local để tâm shape nằm đúng chỗ thả
                                let adjustedX = gridLocalX - shapeCenterOffsetX
                                let adjustedY = gridLocalY - shapeCenterOffsetY
                                
                                // 6. Tính col & row từ góc trên-trái của shape
                                let targetCol = Int((adjustedX - padding) / cellSize)
                                let targetRow = Int((adjustedY - padding) / cellSize)

                                
                                guard targetRow >= 0 && targetRow + shapeHeight <= 10,
                                      targetCol >= 0 && targetCol + shapeWidth <= 10 else {
                                    return
                                }
                                
                                if viewModel.canPlaceShape(at: targetCol, targetRow) {
                                    withAnimation(.spring(response: 0.4)) {
                                        viewModel.placeShapeInGrid(at: targetCol, targetRow)
                                        viewModel.placeShape()
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        viewModel.generateNextShape()
                                    }
                                }
                            }
                    )
                    .padding(.bottom, 4)
            }
            
            // Question
            if viewModel.showQuestion, let card = viewModel.currentCard {
                questionView(card: card)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
        .animation(.easeInOut, value: viewModel.showQuestion)
    }
    
    private func questionView(card: Card) -> some View {
        VStack(spacing: 12) {
            if let imageData = card.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(12)
            }
            
            Text(card.term)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Enter the correct definition")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(viewModel.attemptsLeft == 3 ? .green : viewModel.attemptsLeft == 2 ? .orange : .red)
                Text("\(viewModel.attemptsLeft)")
                    .font(.title3).bold()
                    .foregroundColor(viewModel.attemptsLeft == 3 ? .green : viewModel.attemptsLeft == 2 ? .orange : .red)
            }
            .padding(.top, 1)
            
            TextField("Answer", text: $viewModel.userAnswer)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Submit") {
                withAnimation {
                    viewModel.submitAnswer()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(25)
        .padding(.horizontal)
        .padding(.bottom, 110)
    }
}

// MARK: - GridView & ShapeView
struct GridView: View {
    let grid: [[Bool]]
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<10, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<10, id: \.self) { col in
                        Rectangle()
                            .fill(grid[row][col] ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .cornerRadius(4)
                            .animation(.easeInOut, value: grid[row][col])
                    }
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ShapeView: View {
    let shape: [[Int]]
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(shape.indices, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(shape[row].indices, id: \.self) { col in
                        Rectangle()
                            .fill(shape[row][col] == 1 ? Color.green.opacity(0.8) : Color.clear)
                            .frame(width: 32, height: 32)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 2)
        )
    }
}

#Preview {
    let service = SwiftDataService()
    let quiz = Quiz(title: "Demo", quizDescription: "", isPublic: true, createdBy: nil, categories: ["Blocks"])
    let card = Card(term: "Test", definition: "Answer")
    card.id = 1
    quiz.cards = Array(repeating: card, count: 5)
    return BlocksView(quiz: quiz, service: service)
}
