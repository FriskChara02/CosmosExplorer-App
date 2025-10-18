//
//  EditGalaxyView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 15/10/25.
//

import SwiftUI
import PhotosUI

struct EditGalaxyView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GalaxyViewModel
    let galaxy: GalaxyModel
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
    init(viewModel: GalaxyViewModel, galaxy: GalaxyModel) {
        self.viewModel = viewModel
        self.galaxy = galaxy
        
        self._name = State(initialValue: galaxy.name)
        self._description = State(initialValue: galaxy.galaxyDescription)
        self._selectedImageData = State(initialValue: galaxy.imageData)
        
        self._randomInfos = State(initialValue: galaxy.randomInfos.isEmpty ? [""] : galaxy.randomInfos)
        self._aboutDescription = State(initialValue: galaxy.aboutDescription)
        self._videoURLs = State(initialValue: galaxy.videoURLs.isEmpty ? [""] : galaxy.videoURLs)
        self._radius = State(initialValue: galaxy.radius)
        self._distanceFromSun = State(initialValue: galaxy.distanceFromSun)
        self._age = State(initialValue: galaxy.age)
        
        self._galleryImageData = State(initialValue: galaxy.galleryImageData.isEmpty ? [nil] : galaxy.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: galaxy.galleryImageData.count))
        
        self._wikiLink = State(initialValue: galaxy.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoGalaxySection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewGalaxySection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationGalaxySection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    age: $age
                )
                GalleriesGalaxySection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiGalaxySection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Edit Galaxy"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        saveGalaxy()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if galaxy.galaxy_order > 2 {
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
                    viewModel.deleteGalaxy(galaxy)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(galaxy.name)?"))
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
    private func saveGalaxy() {
        let updatedGalaxy = GalaxyModel(
            id: galaxy.id,
            name: name,
            galaxyDescription: description,
            viewCount: galaxy.viewCount,
            isFavorite: galaxy.isFavorite,
            galaxy_order: galaxy.galaxy_order,
            imageData: selectedImageData ?? galaxy.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            radius: radius,
            distanceFromSun: distanceFromSun,
            age: age,
            galleryImageData: galleryImageData.compactMap { $0 },
            wikiLink: wikiLink
        )
        viewModel.updateGalaxy(updatedGalaxy)
    }
}

#Preview {
    EditGalaxyView(viewModel: GalaxyViewModel(), galaxy: GalaxyModel(name: "Test", galaxyDescription: "Test", galaxy_order: 3, randomInfos: [], videoURLs: []))
}
