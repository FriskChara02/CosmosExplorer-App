//
//  EditBlackholeView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 18/10/25.
//

import SwiftUI
import PhotosUI

struct EditBlackholeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BlackholeViewModel
    let blackhole: BlackholeModel
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
    init(viewModel: BlackholeViewModel, blackhole: BlackholeModel) {
        self.viewModel = viewModel
        self.blackhole = blackhole
        
        self._name = State(initialValue: blackhole.name)
        self._description = State(initialValue: blackhole.blackholeDescription)
        self._selectedImageData = State(initialValue: blackhole.imageData)
        
        self._randomInfos = State(initialValue: blackhole.randomInfos.isEmpty ? [""] : blackhole.randomInfos)
        self._aboutDescription = State(initialValue: blackhole.aboutDescription)
        self._videoURLs = State(initialValue: blackhole.videoURLs.isEmpty ? [""] : blackhole.videoURLs)
        self._radius = State(initialValue: blackhole.radius)
        self._distanceFromSun = State(initialValue: blackhole.distanceFromSun)
        self._age = State(initialValue: blackhole.age)
        
        self._galleryImageData = State(initialValue: blackhole.galleryImageData.isEmpty ? [nil] : blackhole.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: blackhole.galleryImageData.count))
        
        self._wikiLink = State(initialValue: blackhole.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoBlackholeSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewBlackholeSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationBlackholeSection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    age: $age
                )
                GalleriesBlackholeSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiBlackholeSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Edit Blackhole"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        saveBlackhole()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if blackhole.blackhole_order > 2 {
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
                    viewModel.deleteBlackhole(blackhole)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(blackhole.name)?"))
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
    private func saveBlackhole() {
        let updatedBlackhole = BlackholeModel(
            id: blackhole.id,
            name: name,
            blackholeDescription: description,
            viewCount: blackhole.viewCount,
            isFavorite: blackhole.isFavorite,
            blackhole_order: blackhole.blackhole_order,
            imageData: selectedImageData ?? blackhole.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            radius: radius,
            distanceFromSun: distanceFromSun,
            age: age,
            galleryImageData: galleryImageData.compactMap { $0 },
            wikiLink: wikiLink
        )
        viewModel.updateBlackhole(updatedBlackhole)
    }
}

// MARK: - Subviews

struct BasicInfoBlackholeSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Basic information"))) {
            TextField(LanguageManager.current.string("Blackhole name"), text: $name)
            TextField(LanguageManager.current.string("Short description"), text: $description, axis: .vertical)
                .lineLimit(3)
            HStack {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text(LanguageManager.current.string("Blackhole Image"))
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedImage) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                Spacer()
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct OverviewBlackholeSection: View {
    @Binding var randomInfos: [String]
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Overview"))) {
            if selectedImage != nil, let data = selectedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                Text(LanguageManager.current.string("Image from Basic Information"))
                    .foregroundColor(.blue)
            }

            ForEach(randomInfos.indices, id: \.self) { index in
                TextField(LanguageManager.current.string("Random information")
                            .replacingOccurrences(of: "{index}", with: "\(index + 1)"),
                          text: $randomInfos[index], axis: .vertical)
                    .lineLimit(3)
            }

            AddButtonBlackholeViewOverview(randomInfos: $randomInfos)
            
            RemoveButtonBlackholeViewOverview(randomInfos: $randomInfos)
        }
    }
}

struct AddButtonBlackholeViewOverview: View {
    @Binding var randomInfos: [String]
    
    var body: some View {
        Button {
            randomInfos.append("")
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

struct RemoveButtonBlackholeViewOverview: View {
    @Binding var randomInfos: [String]
    
    var body: some View {
        Button {
            if randomInfos.count > 1 {
                randomInfos.removeLast()
            }
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
        }
        .disabled(randomInfos.count <= 1)
        .opacity(randomInfos.count <= 1 ? 0.5 : 1)
    }
}

struct InformationBlackholeSection: View {
    @Binding var aboutDescription: String
    @Binding var videoURLs: [String]
    @Binding var radius: String
    @Binding var distanceFromSun: String
    @Binding var age: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Information"))) {
            TextField(LanguageManager.current.string("About description"), text: $aboutDescription, axis: .vertical)
                .lineLimit(5)
            ForEach(videoURLs.indices, id: \.self) { index in
                TextField(LanguageManager.current.string("Your link video").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $videoURLs[index])
            }
            AddButtonBlackholeViewInformation(videoURLs: $videoURLs)
            RemoveButtonBlackholeViewInformation(videoURLs: $videoURLs)
            TextField(LanguageManager.current.string("Radius"), text: $radius)
            TextField(LanguageManager.current.string("Distance from Sun"), text: $distanceFromSun)
            TextField(LanguageManager.current.string("Age"), text: $age)
        }
        .id(videoURLs.count)
    }
}

struct AddButtonBlackholeViewInformation: View {
    @Binding var videoURLs: [String]
    
    var body: some View {
        Button {
            videoURLs.append("")
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

struct RemoveButtonBlackholeViewInformation: View {
    @Binding var videoURLs: [String]
    
    var body: some View {
        Button {
            if videoURLs.count > 1 {
                videoURLs.removeLast()
            }
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
        }
        .disabled(videoURLs.count <= 1)
        .opacity(videoURLs.count <= 1 ? 0.5 : 1)
    }
}

struct GalleriesBlackholeSection: View {
    @Binding var galleryImages: [PhotosPickerItem?]
    @Binding var galleryImageData: [Data?]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Galleries"))) {
            ForEach(galleryImages.indices, id: \.self) { index in
                HStack {
                    PhotosPicker(selection: $galleryImages[index], matching: .images) {
                        Text(LanguageManager.current.string("Select photo").replacingOccurrences(of: "{index}", with: "\(index + 1)"))
                            .foregroundColor(.blue)
                    }
                    .onChange(of: galleryImages[index]) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if galleryImageData.count <= index {
                                    galleryImageData.append(contentsOf: Array(repeating: nil, count: index - galleryImageData.count + 1))
                                }
                                galleryImageData[index] = data
                            }
                        }
                    }
                    Spacer()
                    if let data = galleryImageData[index], let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    }
                }
            }
            AddButtonBlackholeViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
            RemoveButtonBlackholeViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
        }
        .id(galleryImages.count)
    }
}

struct AddButtonBlackholeViewGalleries: View {
    @Binding var galleryImages: [PhotosPickerItem?]
    @Binding var galleryImageData: [Data?]
    
    var body: some View {
        Button {
            galleryImages.append(nil)
            galleryImageData.append(nil)
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

struct RemoveButtonBlackholeViewGalleries: View {
    @Binding var galleryImages: [PhotosPickerItem?]
    @Binding var galleryImageData: [Data?]
    
    var body: some View {
        Button {
            if galleryImages.count > 1 {
                galleryImages.removeLast()
                galleryImageData.removeLast()
            }
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
        }
        .disabled(galleryImages.count <= 1)
        .opacity(galleryImages.count <= 1 ? 0.5 : 1)
    }
}

struct WikiBlackholeSection: View {
    @Binding var wikiLink: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Wikipedia link"))) {
            TextField(LanguageManager.current.string("Wikipedia"), text: $wikiLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    EditBlackholeView(viewModel: BlackholeViewModel(), blackhole: BlackholeModel(name: "Test", blackholeDescription: "Test", blackhole_order: 3, randomInfos: [], videoURLs: []))
}
