//
//  EditConstellationView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/10/25.
//

import SwiftUI
import PhotosUI

struct EditConstellationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConstellationViewModel
    let constellation: ConstellationModel
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
    @State private var mainStars: Int
    @State private var namedStars: [String]
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?]
    @State private var galleryImageData: [Data?]
    
    // Wiki
    @State private var wikiLink: String
    
    // MARK: - Init & Populate Data
    init(viewModel: ConstellationViewModel, constellation: ConstellationModel) {
        self.viewModel = viewModel
        self.constellation = constellation
        
        self._name = State(initialValue: constellation.name)
        self._description = State(initialValue: constellation.constellationDescription)
        self._selectedImageData = State(initialValue: constellation.imageData)
        
        self._randomInfos = State(initialValue: constellation.randomInfos.isEmpty ? [""] : constellation.randomInfos)
        self._aboutDescription = State(initialValue: constellation.aboutDescription)
        self._videoURLs = State(initialValue: constellation.videoURLs.isEmpty ? [""] : constellation.videoURLs)
        self._mainStars = State(initialValue: constellation.mainStars)
        self._namedStars = State(initialValue: constellation.namedStars.isEmpty ? [""] : constellation.namedStars)
        
        self._galleryImageData = State(initialValue: constellation.galleryImageData.isEmpty ? [nil] : constellation.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: constellation.galleryImageData.count))
        
        self._wikiLink = State(initialValue: constellation.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoConstellationSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewConstellationSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationConstellationSection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    mainStars: $mainStars,
                    namedStars: $namedStars
                )
                GalleriesConstellationSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiConstellationSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Edit Constellation"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        saveConstellation()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if constellation.constellation_order > 2 {
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
                    viewModel.deleteConstellation(constellation)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(constellation.name)?"))
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
    private func saveConstellation() {
        let updatedConstellation = ConstellationModel(
            id: constellation.id,
            name: name,
            constellationDescription: description,
            viewCount: constellation.viewCount,
            isFavorite: constellation.isFavorite,
            constellation_order: constellation.constellation_order,
            imageData: selectedImageData ?? constellation.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            mainStars: mainStars,
            namedStars: namedStars.filter { !$0.isEmpty },
            galleryImageData: galleryImageData.compactMap { $0 },
            wikiLink: wikiLink
        )
        viewModel.updateConstellation(updatedConstellation)
    }
}

#Preview {
    EditConstellationView(viewModel: ConstellationViewModel(), constellation: ConstellationModel(name: "Test", constellationDescription: "Test", constellation_order: 3, randomInfos: [], videoURLs: [], mainStars: 0, namedStars: []))
}
