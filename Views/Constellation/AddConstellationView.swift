//
//  AddConstellationView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/10/25.
//

import SwiftUI
import PhotosUI

struct AddConstellationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConstellationViewModel
    
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
    @State private var mainStars: Int = 0
    @State private var namedStars: [String] = [""]
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?] = [nil]
    @State private var galleryImageData: [Data?] = [nil]
    
    // Wiki
    @State private var wikiLink: String = ""
    
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
            .navigationTitle(LanguageManager.current.string("Add Your New Constellation"))
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
                            
                            let newConstellation = ConstellationModel(
                                name: name,
                                constellationDescription: description,
                                constellation_order: viewModel.constellations.count,
                                imageData: selectedImageData,
                                randomInfos: randomInfos.filter { !$0.isEmpty },
                                aboutDescription: aboutDescription,
                                videoURLs: convertedURLs,
                                mainStars: mainStars,
                                namedStars: namedStars.filter { !$0.isEmpty },
                                galleryImageData: galleryImageData,
                                wikiLink: wikiLink
                            )
                            viewModel.addConstellation(newConstellation)
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
struct BasicInfoConstellationSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Basic information"))) {
            TextField(LanguageManager.current.string("Constellation name"), text: $name)
            TextField(LanguageManager.current.string("Short description"), text: $description, axis: .vertical)
                .lineLimit(3)
            HStack {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text(LanguageManager.current.string("Constellation Image"))
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

struct OverviewConstellationSection: View {
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
            AddButtonConstellationViewOverview(randomInfos: $randomInfos)
            
            RemoveButtonConstellationViewOverview(randomInfos: $randomInfos)
        }
    }
}

struct AddButtonConstellationViewOverview: View {
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

struct RemoveButtonConstellationViewOverview: View {
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

struct InformationConstellationSection: View {
    @Binding var aboutDescription: String
    @Binding var videoURLs: [String]
    @Binding var mainStars: Int
    @Binding var namedStars: [String]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Information"))) {
            TextField(LanguageManager.current.string("About description"), text: $aboutDescription, axis: .vertical)
                .lineLimit(5)
            ForEach(videoURLs.indices, id: \.self) { index in
                TextField(LanguageManager.current.string("Your link video").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $videoURLs[index])
            }
            AddButtonConstellationViewInformation(videoURLs: $videoURLs)
            RemoveButtonConstellationViewInformation(videoURLs: $videoURLs)
            HStack {
                Text(LanguageManager.current.string("Main Stars:"))
                TextField("", value: $mainStars, format: .number)
            }
            ForEach(namedStars.indices, id: \.self) { index in
                TextField(LanguageManager.current.string("Named Star").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $namedStars[index])
            }
            AddButtonNamedStars(namedStars: $namedStars)
            RemoveButtonNamedStars(namedStars: $namedStars)
        }
        .id(videoURLs.count + namedStars.count)
    }
}

struct AddButtonConstellationViewInformation: View {
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

struct RemoveButtonConstellationViewInformation: View {
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

struct AddButtonNamedStars: View {
    @Binding var namedStars: [String]
    
    var body: some View {
        Button {
            namedStars.append("")
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

struct RemoveButtonNamedStars: View {
    @Binding var namedStars: [String]
    
    var body: some View {
        Button {
            if namedStars.count > 1 {
                namedStars.removeLast()
            }
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
                .font(.title3)
        }
        .disabled(namedStars.count <= 1)
        .opacity(namedStars.count <= 1 ? 0.5 : 1)
    }
}

struct GalleriesConstellationSection: View {
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
            AddButtonConstellationViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
            RemoveButtonConstellationViewGalleries(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
        }
        .id(galleryImages.count)
    }
}

struct AddButtonConstellationViewGalleries: View {
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

struct RemoveButtonConstellationViewGalleries: View {
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

struct WikiConstellationSection: View {
    @Binding var wikiLink: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Wikipedia link"))) {
            TextField(LanguageManager.current.string("Wikipedia"), text: $wikiLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    AddConstellationView(viewModel: ConstellationViewModel())
}
