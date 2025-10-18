//
//  EditNebulaView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI
import PhotosUI

struct EditNebulaView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NebulaViewModel
    let nebula: NebulaModel
    @State private var showDeleteConfirmation: Bool = false
    
    // Basic Info
    @State private var name: String
    @State private var description: String
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data?
    
    // Tab Overview
    @State private var randomInfos: [String]
    
    // Tab Information
    @State private var aboutDescription: String
    @State private var videoURLs: [String]
    @State private var radius: String
    @State private var distanceFromSun: String
    @State private var age: String
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?]
    @State private var galleryImageData: [Data?]
    
    // Wiki
    @State private var wikiLink: String
    
    // MARK: - Init & Populate Data
    init(viewModel: NebulaViewModel, nebula: NebulaModel) {
        self.viewModel = viewModel
        self.nebula = nebula
        
        self._name = State(initialValue: nebula.name)
        self._description = State(initialValue: nebula.nebulaDescription)
        self._selectedImageData = State(initialValue: nebula.imageData)
        
        self._randomInfos = State(initialValue: nebula.randomInfos.isEmpty ? [""] : nebula.randomInfos)
        self._aboutDescription = State(initialValue: nebula.aboutDescription)
        self._videoURLs = State(initialValue: nebula.videoURLs.isEmpty ? [""] : nebula.videoURLs)
        self._radius = State(initialValue: nebula.radius)
        self._distanceFromSun = State(initialValue: nebula.distanceFromSun)
        self._age = State(initialValue: nebula.age)
        
        self._galleryImageData = State(initialValue: nebula.galleryImageData.isEmpty ? [nil] : nebula.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: nebula.galleryImageData.count))
        
        self._wikiLink = State(initialValue: nebula.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoNebulaSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewNebulaSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationNebulaSection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    age: $age
                )
                GalleriesNebulaSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiNebulaSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Edit Nebula"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        saveNebula()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if nebula.nebula_order > 2 {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(LanguageManager.current.string("Confirm Delete"), isPresented: $showDeleteConfirmation) {
                Button(LanguageManager.current.string("Delete"), role: .destructive) {
                    viewModel.deleteNebula(nebula)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(nebula.name)?"))
            }
            .background(
                Image("cosmos_background1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .onChange(of: selectedImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func convertYouTubeURL(_ url: String) -> String {
        guard !url.isEmpty else { return url }
        
        if url.contains("watch?v=") {
            let components = url.components(separatedBy: "watch?v=")
            if components.count > 1, let videoID = components.last?.components(separatedBy: "&").first {
                return "https://www.youtube.com/embed/\(videoID)"
            }
        } else if url.contains("youtu.be/") {
            let components = url.components(separatedBy: "youtu.be/")
            if components.count > 1, let videoID = components.last?.components(separatedBy: "?").first {
                return "https://www.youtube.com/embed/\(videoID)"
            }
        }
        return url
    }
    
    // MARK: - Save Logic
    private func saveNebula() {
        let updatedNebula = NebulaModel(
            id: nebula.id,
            name: name,
            nebulaDescription: description,
            viewCount: nebula.viewCount,
            isFavorite: nebula.isFavorite,
            nebula_order: nebula.nebula_order,
            imageData: selectedImageData ?? nebula.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            radius: radius,
            distanceFromSun: distanceFromSun,
            age: age,
            galleryImageData: galleryImageData.compactMap { $0 },
            wikiLink: wikiLink
        )
        viewModel.updateNebula(updatedNebula)
    }
}

#Preview {
    EditNebulaView(viewModel: NebulaViewModel(), nebula: NebulaModel(name: "Test", nebulaDescription: "Test", nebula_order: 3, randomInfos: [], videoURLs: []))
}
