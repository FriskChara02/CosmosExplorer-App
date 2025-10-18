//
//  EditStarView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI
import PhotosUI

struct EditStarView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StarViewModel
    let star: StarModel
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
    init(viewModel: StarViewModel, star: StarModel) {
        self.viewModel = viewModel
        self.star = star
        
        self._name = State(initialValue: star.name)
        self._description = State(initialValue: star.starDescription)
        self._selectedImageData = State(initialValue: star.imageData)
        
        self._randomInfos = State(initialValue: star.randomInfos.isEmpty ? [""] : star.randomInfos)
        self._aboutDescription = State(initialValue: star.aboutDescription)
        self._videoURLs = State(initialValue: star.videoURLs.isEmpty ? [""] : star.videoURLs)
        self._radius = State(initialValue: star.radius)
        self._distanceFromSun = State(initialValue: star.distanceFromSun)
        self._age = State(initialValue: star.age)
        
        self._galleryImageData = State(initialValue: star.galleryImageData.isEmpty ? [nil] : star.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: star.galleryImageData.count))
        
        self._wikiLink = State(initialValue: star.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoStarSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewStarSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationStarSection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    age: $age
                )
                GalleriesStarSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiStarSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Edit Star"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        saveStar()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if star.star_order > 2 {
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
                    viewModel.deleteStar(star)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(star.name)?"))
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
    private func saveStar() {
        let updatedStar = StarModel(
            id: star.id,
            name: name,
            starDescription: description,
            viewCount: star.viewCount,
            isFavorite: star.isFavorite,
            star_order: star.star_order,
            imageData: selectedImageData ?? star.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            radius: radius,
            distanceFromSun: distanceFromSun,
            age: age,
            galleryImageData: galleryImageData.compactMap { $0 },
            wikiLink: wikiLink
        )
        viewModel.updateStar(updatedStar)
    }
}

#Preview {
    EditStarView(viewModel: StarViewModel(), star: StarModel(name: "Test", starDescription: "Test", star_order: 3, randomInfos: [], videoURLs: []))
}
