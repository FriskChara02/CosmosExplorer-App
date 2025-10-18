//
//  AddStarView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI
import PhotosUI

struct AddStarView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StarViewModel
    
    // Basic Info
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Tab Overview
    @State private var randomInfos: [String] = [""]
    
    // Tab Information
    @State private var aboutDescription: String = ""
    @State private var videoURLs: [String] = [""]
    @State private var radius: String = ""
    @State private var distanceFromSun: String = ""
    @State private var age: String = ""
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?] = [nil]
    @State private var galleryImageData: [Data?] = [nil]
    
    // Wiki
    @State private var wikiLink: String = ""
    
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
            .navigationTitle(LanguageManager.current.string("Add Your New Star"))
            .background(
                Image("cosmos_background1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        if !name.isEmpty {
                            let convertedURLs = videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty }
                            
                            let newStar = StarModel(
                                name: name,
                                starDescription: description,
                                star_order: viewModel.stars.count,
                                imageData: selectedImageData,
                                randomInfos: randomInfos.filter { !$0.isEmpty },
                                aboutDescription: aboutDescription,
                                videoURLs: convertedURLs,
                                radius: radius,
                                distanceFromSun: distanceFromSun,
                                age: age,
                                galleryImageData: galleryImageData,
                                wikiLink: wikiLink
                            )
                            viewModel.addStar(newStar)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationBarBackButtonHidden(true)
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
}

// MARK: - Subviews

struct BasicInfoStarSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Basic information"))) {
            TextField(LanguageManager.current.string("Star name"), text: $name)
            TextField(LanguageManager.current.string("Short description"), text: $description, axis: .vertical)
                .lineLimit(3)
            HStack {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text(LanguageManager.current.string("Star Image"))
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

struct OverviewStarSection: View {
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

            AddButtonStarViewOverview(randomInfos: $randomInfos)
            
            RemoveButtonStarViewOverview(randomInfos: $randomInfos)
        }
    }
}

struct AddButtonStarViewOverview: View {
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

struct RemoveButtonStarViewOverview: View {
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

struct InformationStarSection: View {
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
            AddButtonStarViewInformation(videoURLs: $videoURLs)
            RemoveButtonStarViewInformation(videoURLs: $videoURLs)
            TextField(LanguageManager.current.string("Radius"), text: $radius)
            TextField(LanguageManager.current.string("Distance from Earth"), text: $distanceFromSun)
            TextField(LanguageManager.current.string("Age"), text: $age)
        }
        .id(videoURLs.count)
    }
}

struct AddButtonStarViewInformation: View {
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

struct RemoveButtonStarViewInformation: View {
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

struct GalleriesStarSection: View {
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
            AddButtonStarViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
            RemoveButtonStarViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
        }
        .id(galleryImages.count)
    }
}

struct AddButtonStarViewGalleries: View {
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

struct RemoveButtonStarViewGalleries: View {
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

struct WikiStarSection: View {
    @Binding var wikiLink: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Wikipedia link"))) {
            TextField(LanguageManager.current.string("Wikipedia"), text: $wikiLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    AddStarView(viewModel: StarViewModel())
}
