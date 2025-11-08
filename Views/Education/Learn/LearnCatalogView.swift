//
//  LearnCatalogView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 7/11/25.
//

import SwiftUI
import SwiftData

struct LearnCatalogView: View {
    @StateObject private var viewModel = QuizListViewModel(service: SwiftDataService(), mode: "Learn")
    @State private var isSearchActive = false
    @State private var editingQuiz: Quiz? = nil
    @State private var hasLoadedQuizzes = false
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss

    // Display limits
    @State private var appSamplesLimit: Int = 6
    @State private var ownLearnLimit: Int = 6
    @State private var othersLearnLimit: Int = 6

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
                    Text("Learn")
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

                Text(DateHelper.formatDate(Date()))
                    .font(.subheadline)
                    .foregroundColor(.white)

                // Quiz List
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // App Samples
                        Section(header: Text("App's Sample Learn Sets").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy == nil }.prefix(appSamplesLimit)) { quiz in
                                    LearnItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy == nil }).count > appSamplesLimit {
                                Button("See more") {
                                    appSamplesLimit += 6
                                }
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }

                        // Your Learn Sets
                        Section(header: Text("Your Learn Sets").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy == viewModel.currentUserId }.prefix(ownLearnLimit)) { quiz in
                                    LearnItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy == viewModel.currentUserId }).count > ownLearnLimit {
                                Button("See more") {
                                    ownLearnLimit += 6
                                }
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }

                        // Community
                        Section(header: Text("Community Learn Sets").font(.headline).foregroundColor(.white)) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.filteredQuizzes.filter { $0.createdBy != nil && $0.createdBy != viewModel.currentUserId && $0.isPublic }.prefix(othersLearnLimit)) { quiz in
                                    LearnItemView(quiz: quiz, viewModel: viewModel, editingQuiz: $editingQuiz)
                                }
                            }
                            if viewModel.filteredQuizzes.filter({ $0.createdBy != nil && $0.createdBy != viewModel.currentUserId && $0.isPublic }).count > othersLearnLimit {
                                Button("See more") {
                                    othersLearnLimit += 6
                                }
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
                    prompt: Text("Search learn sets")
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

struct LearnItemView: View {
    let quiz: Quiz
    @ObservedObject var viewModel: QuizListViewModel
    @Binding var editingQuiz: Quiz?
    @Namespace private var animation
    @State private var isFavorite: Bool = false

    var body: some View {
        NavigationLink(destination: LearnView(quiz: quiz, service: viewModel.service)) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(width: 170, height: 180)
                    .shadow(radius: 5)

                VStack {
                    // Menu
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

                    // Image
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
    LearnCatalogView()
}
