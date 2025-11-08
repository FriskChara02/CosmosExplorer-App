//
//  AddQuizView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddQuizView: View {
    @ObservedObject var viewModel: AddEditQuizViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var quizListVM: QuizListViewModel
    
    @State private var editingCard: Card?
    @State private var showCardEditor = false
    
    @State private var hintText = ""
    @State private var selectedImageData: Data?
    @State private var termAttributed: NSAttributedString = NSAttributedString()
    @State private var definitionAttributed: NSAttributedString = NSAttributedString()
    
    private let categories = ["Flashcards", "Learn", "Test", "Blocks", "Blast", "Match"]
    private let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange, .pink, .brown, .gray]
    
    init(service: SwiftDataService, quiz: Quiz? = nil) {
        self.viewModel = AddEditQuizViewModel(service: service, quiz: quiz)
    }
    
    var body: some View {
        NavigationView {
            Form {
                quizInfoSection
                categoriesSection
                cardsSection
            }
            .background(.thinMaterial)
            .background(
                Image("cosmos_background1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden)
            .navigationTitle(viewModel.isEdit ? "Edit Quiz" : "Add Quiz")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.save()
                        quizListVM.loadQuizzes()
                        dismiss()
                        viewModel.service.container.mainContext.processPendingChanges()
                    }
                    .disabled(viewModel.title.isEmpty)
                }
            }
            .sheet(isPresented: $showCardEditor) {
                cardEditorSheet
            }
            .onChange(of: viewModel.selectedImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    private var quizInfoSection: some View {
        Section("Quiz Info") {
            TextField("Title", text: $viewModel.title)
            TextField("Description", text: $viewModel.description)
            Toggle("Public", isOn: $viewModel.isPublic)
        }
    }
    
    private var categoriesSection: some View {
        Section("Categories") {
            ForEach(categories, id: \.self) { category in
                Toggle(category, isOn: categoryBinding(for: category))
            }
        }
    }
    
    private func categoryBinding(for category: String) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedCategories.contains(category) },
            set: { isSelected in
                if isSelected {
                    viewModel.selectedCategories.insert(category)
                } else {
                    viewModel.selectedCategories.remove(category)
                }
            }
        )
    }
    
    private var cardsSection: some View {
        Section("Cards") {
            ForEach(viewModel.cards) { card in
                HStack {
                    Text(card.term)
                        .lineLimit(1)
                    Spacer()
                    Button("Edit") {
                        startEditing(card)
                    }
                    .foregroundColor(.blue)
                }
            }
            .onDelete { indexSet in
                let cardsToDelete = indexSet.map { viewModel.cards[$0] }
                cardsToDelete.forEach { viewModel.deleteCard($0) }
            }
            
            Button("Add Card") {
                startAddingNewCard()
            }
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - Card Editor Sheet
    private var cardEditorSheet: some View {
        NavigationView {
            Form {
                termSection
                definitionSection
                hintSection
                imageSection
            }
            .navigationTitle(editingCard == nil ? "Add Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCurrentCard()
                        showCardEditor = false
                    }
                    .disabled(termAttributed.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        editingCard = nil
                        showCardEditor = false
                    }
                }
            }
            .toolbar {
                if editingCard != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Card", role: .destructive) {
                            if let card = editingCard {
                                viewModel.deleteCard(card)
                            }
                            editingCard = nil
                            showCardEditor = false
                        }
                    }
                }
            }
        }
    }

    private var termSection: some View {
        Section("Term") {
            RichTextEditor(attributedText: $termAttributed)
                .frame(minHeight: 100)
            formattingButtons(isTerm: true)
        }
    }

    private var definitionSection: some View {
        Section("Definition") {
            RichTextEditor(attributedText: $definitionAttributed)
                .frame(minHeight: 100)
            formattingButtons(isTerm: false)
        }
    }

    private var hintSection: some View {
        Section("Hint") {
            TextField("Hint (optional)", text: $hintText)
        }
    }

    private var imageSection: some View {
        Section("Image") {
            PhotosPicker("Select Image", selection: $viewModel.selectedImage, matching: .images)
            
            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipped()
            }
        }
    }

    // MARK: - Formatting
    private func formattingButtons(isTerm: Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(colors, id: \.self) { color in
                Button {
                    applyColor(color, isTerm: isTerm)
                } label: {
                    Circle().fill(color).frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }

    private func applyColor(_ color: Color, isTerm: Bool) {
        let attr = isTerm ? termAttributed : definitionAttributed
        let mutable = NSMutableAttributedString(attributedString: attr)
        let range = NSRange(location: 0, length: mutable.length)
        mutable.addAttribute(.foregroundColor, value: UIColor(color), range: range)
        
        if isTerm {
            termAttributed = mutable
        } else {
            definitionAttributed = mutable
        }
    }

    // MARK: - Card Actions
    private func startEditing(_ card: Card) {
        editingCard = card
        hintText = card.hint ?? ""
        selectedImageData = card.imageData
        
        termAttributed = loadAttributedString(from: card.termFormatting) ?? NSAttributedString(string: card.term)
        definitionAttributed = loadAttributedString(from: card.definitionFormatting) ?? NSAttributedString(string: card.definition)
        
        viewModel.selectedImage = nil
        
        showCardEditor = true
    }

    private func startAddingNewCard() {
        editingCard = nil
        hintText = ""
        selectedImageData = nil
        termAttributed = NSAttributedString()
        definitionAttributed = NSAttributedString()
        viewModel.selectedImage = nil
        
        showCardEditor = true
    }

    private func saveCurrentCard() {
        let termData = dataFromAttributedString(termAttributed)
        let defData = dataFromAttributedString(definitionAttributed)
        let termString = termAttributed.string
        let defString = definitionAttributed.string
        
        if let card = editingCard {
            viewModel.updateCard(
                card,
                term: termString,
                definition: defString,
                hint: hintText.isEmpty ? nil : hintText,
                imageData: selectedImageData,
                termFormatting: termData,
                definitionFormatting: defData
            )
        } else {
            viewModel.addCard(
                term: termString,
                definition: defString,
                hint: hintText.isEmpty ? nil : hintText,
                imageData: selectedImageData,
                termFormatting: termData,
                definitionFormatting: defData
            )
        }
        editingCard = nil
    }

    private func loadAttributedString(from data: Data?) -> NSAttributedString? {
        guard let data = data else { return nil }
        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtfd],
            documentAttributes: nil
        )
    }
    
    private func dataFromAttributedString(_ attributed: NSAttributedString) -> Data? {
        try? attributed.data(
            from: NSRange(location: 0, length: attributed.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
        )
    }
}

#Preview {
    AddQuizView(service: SwiftDataService())
}
