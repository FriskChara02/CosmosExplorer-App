//
//  AddPlanetsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 23/10/25.
//

import SwiftUI
import PhotosUI

struct AddPlanetsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PlanetsViewModel
    
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
                BasicInfoPlanetsSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewPlanetsSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationPlanetsSection(
                    aboutDescription: $aboutDescription,
                    videoURLs: $videoURLs,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    age: $age
                )
                GalleriesPlanetsSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                WikiPlanetsSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .navigationTitle(LanguageManager.current.string("Add Your New Planets"))
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
                            
                            let newPlanets = PlanetsModel(
                                name: name,
                                planetsDescription: description,
                                planets_order: viewModel.planets.count,
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
                            viewModel.addPlanets(newPlanets)
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

#Preview {
    AddPlanetsView(viewModel: PlanetsViewModel())
}

