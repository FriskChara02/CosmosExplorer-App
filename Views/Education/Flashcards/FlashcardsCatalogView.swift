//
//  FlashcardsCatalogView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 6/11/25.
//

import SwiftUI
import SwiftData

struct FlashcardsCatalogView: View {
    @StateObject private var viewModel = QuizListViewModel(service: SwiftDataService(), mode: "Flashcards")
    @State private var isSearchActive = false
    @State private var editingQuiz: Quiz? = nil
    @State private var hasLoadedQuizzes = false
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss

    @State private var appSamplesLimit: Int = 6
    @State private var ownFlashcardsLimit: Int = 6
    @State private var othersFlashcardsLimit: Int = 6

    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Flashcards")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSearchActive.toggle()
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "search", in: animation)
                        }
                        NavigationLink(destination: AddQuizView(service: viewModel.service)
                            .environmentObject(viewModel)) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)

                // Ngày tháng
                Text(DateHelper.formatDate(Date()))
                    .font(.subheadline)
                    .foregroundColor(.white)

                // Danh sách quizzes
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Phần 1: Flashcards mẫu của app (createdBy == nil)
                        Section(header: Text("App's Sample Flashcards").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy == nil }.prefix(appSamplesLimit)) { quiz in
                                    FlashcardItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy == nil }).count > appSamplesLimit {
                                HStack {
                                    Spacer()
                                
                                    Button {
                                        withAnimation(.easeInOut) {
                                            appSamplesLimit += 6
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text("See more")
                                                .font(.subheadline.bold())
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .overlay(Capsule().stroke(Color.blue.opacity(0.5), lineWidth: 1))
                                    }
                                    Spacer()
                                }
                                .padding(.top, 8)
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }

                        // Phần 2: Flashcards tự tạo (createdBy == currentUserId)
                        Section(header: Text("Your Flashcards").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy == viewModel.currentUserId }.prefix(ownFlashcardsLimit)) { quiz in
                                    FlashcardItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy == viewModel.currentUserId }).count > ownFlashcardsLimit {
                                HStack {
                                    Spacer()
                                
                                    Button {
                                        withAnimation(.easeInOut) {
                                            ownFlashcardsLimit += 6
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text("See more")
                                                .font(.subheadline.bold())
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .overlay(Capsule().stroke(Color.blue.opacity(0.5), lineWidth: 1))
                                    }
                                    Spacer()
                                }
                                .padding(.top, 8)
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }

                        // Phần 3: Flashcards của users khác (createdBy != nil && != currentUserId && isPublic)
                        Section(header: Text("Community Flashcards").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy != nil && $0.createdBy != viewModel.currentUserId && $0.isPublic }.prefix(othersFlashcardsLimit)) { quiz in
                                    FlashcardItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy != nil && $0.createdBy != viewModel.currentUserId && $0.isPublic }).count > othersFlashcardsLimit {
                                HStack {
                                    Spacer()
                                
                                    Button {
                                        withAnimation(.easeInOut) {
                                            othersFlashcardsLimit += 6
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text("See more")
                                                .font(.subheadline.bold())
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .overlay(Capsule().stroke(Color.blue.opacity(0.5), lineWidth: 1))
                                    }
                                    Spacer()
                                }
                                .padding(.top, 8)
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }
                    }
                    .padding()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteredQuizzes)
                    .refreshable {
                        viewModel.loadQuizzes()
                    }
                }
                .sheet(item: $editingQuiz) { quiz in
                    EditQuizView(service: viewModel.service, quiz: quiz)
                }
            }
            .background(Image("cosmos_background1").resizable().scaledToFill().ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .bottom)
            .animation(.easeInOut(duration: 0.3), value: isSearchActive)
            .if(isSearchActive) { view in
                view.searchable(
                    text: $viewModel.searchText,
                    isPresented: $isSearchActive,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: Text("Search flashcards")
                )
                .foregroundColor(.blue)
                .fontWeight(.bold)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                if !hasLoadedQuizzes {
                    viewModel.loadQuizzes()
                    hasLoadedQuizzes = true
                }
            }
        }
    }
}

struct FlashcardItemView: View {
    let quiz: Quiz
    @ObservedObject var viewModel: QuizListViewModel
    @Binding var editingQuiz: Quiz?
    @Namespace private var animation
    @State private var isFavorite: Bool = false

    var body: some View {
        NavigationLink(destination: FlashcardsView(quiz: quiz, service: viewModel.service)) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(width: 170, height: 180)
                    .shadow(radius: 5)

                VStack {
                    // Menu 3 chấm
                    HStack {
                        Spacer()
                        Menu {
                            Button(action: {
                                withAnimation(.spring()) {
                                    isFavorite.toggle()
                                    viewModel.toggleQuizFavorite(quiz.id)
                                }
                            }) {
                                Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                            }
                            if quiz.createdBy == viewModel.currentUserId {
                                Button("Edit") {
                                    editingQuiz = quiz
                                }
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteQuiz(quiz)
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .padding(1)
                                .background(Circle().fill(.ultraThinMaterial))
                                .matchedGeometryEffect(id: "menu-\(quiz.id)", in: animation)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 1)

                    // Title và desc
                    if let firstCard = quiz.cards.first, let imageData = firstCard.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .clipped()
                            .cornerRadius(25)
                            .padding(.bottom, 2)
                    }
                    
                    Text(quiz.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(quiz.quizDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
        }
        .onAppear {
            isFavorite = viewModel.isQuizFavorite(quiz.id)
        }
        .onChange(of: viewModel.favoriteQuizIds) { _, _ in
            viewModel.sortQuizzesByFavorites()
        }
    }
}

#Preview {
    FlashcardsCatalogView()
}
