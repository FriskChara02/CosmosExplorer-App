//
//  EditPlanetView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 19/9/25.
//

import SwiftUI
import PhotosUI

struct EditPlanetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SolarSystemViewModel
    let planet: PlanetModel
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
    
    // Tab By the Numbers
    @State private var planetType: String
    @State private var showPlanetTypePicker: Bool = false
    private let planetTypes = [
        "G-type main-sequence star",
        "Terrestrial Planet",
        "Gas Giant",
        "Ice Giant",
        "Dwarf Planet",
        "Exoplanet",
        "Other"
    ]
    @State private var radius: String
    @State private var distanceFromSun: String
    @State private var moons: String
    @State private var gravity: String
    @State private var tiltOfAxis: String
    @State private var lengthOfYear: String
    @State private var lengthOfDay: String
    @State private var temperature: String
    @State private var age: String
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?]
    @State private var galleryImageData: [Data?]
    
    // Tab Myth
    @State private var mythTitle: String
    @State private var mythDescription: String
    @State private var myths: [(culture: String, godName: String, description: String, selectedImage: PhotosPickerItem?, imageData: Data?)]
    
    // Tab Internal
    @State private var internalTitle: String
    @State private var layers: [(name: String, description: String, colorStart: Color, colorEnd: Color, selectedIcon: String)]
    private let iconOptions = [
        "star.fill", "circle.fill", "sun.max.fill", "moon.fill", "gauge",
        "arrow.triangle.2.circlepath", "calendar", "clock", "thermometer", "hourglass",
        "wave.3.forward.circle.fill", "flame.fill", "bolt.fill", "airplane",
        "camera.metering.matrix", "paperplane.fill", "sparkles", "globe.americas.fill", "rays", "waveform.path.ecg"
    ]
    @State private var internalImage: String = ""
    @State private var internalImagePicker: PhotosPickerItem? = nil
    @State private var internalImageData: Data?
    
    // Tab In Depth
    @State private var inDepthTitle: String
    @State private var headerImageInDepth: PhotosPickerItem? = nil
    @State private var headerImageInDepthData: Data?
    @State private var infoCards: [(icon: String, title: String, description: String, iconColor: Color)]
    
    // Tab Exploration
    @State private var explorationTitle: String
    @State private var headerImageExploration: PhotosPickerItem? = nil
    @State private var headerImageExplorationData: Data?
    @State private var missions: [(title: String, description: String, icon: String, id: String)]
    @State private var highlightQuote: String
    @State private var showcaseImage: PhotosPickerItem? = nil
    @State private var showcaseImageData: Data?
    
    // Wiki
    @State private var wikiLink: String
    
    // MARK: - Init & Populate Data
    init(viewModel: SolarSystemViewModel, planet: PlanetModel) {
        self.viewModel = viewModel
        self.planet = planet
        
        self._name = State(initialValue: planet.name)
        self._description = State(initialValue: planet.planetDescription)
        self._selectedImageData = State(initialValue: planet.imageData)
        
        self._randomInfos = State(initialValue: planet.randomInfos.isEmpty ? [""] : planet.randomInfos)
        self._aboutDescription = State(initialValue: planet.aboutDescription)
        self._videoURLs = State(initialValue: planet.videoURLs.isEmpty ? [""] : planet.videoURLs)
        
        self._planetType = State(initialValue: planet.planetType)
        self._radius = State(initialValue: planet.radius)
        self._distanceFromSun = State(initialValue: planet.distanceFromSun)
        self._moons = State(initialValue: planet.moons)
        self._gravity = State(initialValue: planet.gravity)
        self._tiltOfAxis = State(initialValue: planet.tiltOfAxis)
        self._lengthOfYear = State(initialValue: planet.lengthOfYear)
        self._lengthOfDay = State(initialValue: planet.lengthOfDay)
        self._temperature = State(initialValue: planet.temperature)
        self._age = State(initialValue: planet.age)
        
        self._galleryImageData = State(initialValue: planet.galleryImageData.isEmpty ? [nil] : planet.galleryImageData)
        self._galleryImages = State(initialValue: Array(repeating: nil, count: planet.galleryImageData.count))
        
        self._mythTitle = State(initialValue: planet.mythTitle)
        self._mythDescription = State(initialValue: planet.mythDescription)
        self._myths = State(initialValue: planet.myths.isEmpty ? [("", "", "", nil, nil)] : planet.myths.map { myth in
            (myth.culture, myth.godName, myth.mythDescription, nil, myth.imageData)
        })
        
        self._internalTitle = State(initialValue: planet.internalTitle)
        self._layers = State(initialValue: planet.layers.isEmpty ? [("", "", .white, .white, "star.fill")] : planet.layers.map { layer in
            (layer.name, layer.layerDescription, Color(hex: layer.colorStart) ?? .white, Color(hex: layer.colorEnd) ?? .white, layer.icon)
        })
        self._internalImageData = State(initialValue: planet.internalImage)
        
        self._inDepthTitle = State(initialValue: planet.inDepthTitle)
        self._headerImageInDepthData = State(initialValue: planet.headerImageInDepthData)
        self._infoCards = State(initialValue: planet.infoCards.isEmpty ? [("", "", "", .white)] : planet.infoCards.map { card in
            (card.icon, card.title, card.infoCardDescription, Color(hex: card.iconColor) ?? .white)
        })
        
        self._explorationTitle = State(initialValue: planet.explorationTitle)
        self._headerImageExplorationData = State(initialValue: planet.headerImageExplorationData)
        self._missions = State(initialValue: planet.missions.isEmpty ? [("", "", "star.fill", UUID().uuidString)] : planet.missions.map { mission in
            (mission.title, mission.missionDescription, mission.icon, mission.missionId)
        })
        self._highlightQuote = State(initialValue: planet.highlightQuote)
        self._showcaseImageData = State(initialValue: planet.showcaseImageData)
        
        self._wikiLink = State(initialValue: planet.wikiLink)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                BasicInfoSection(name: $name, description: $description, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                OverviewSection(randomInfos: $randomInfos, selectedImage: $selectedImage, selectedImageData: $selectedImageData)
                InformationSection(aboutDescription: $aboutDescription, videoURLs: $videoURLs)
                ByTheNumbersSection(
                    planetType: $planetType,
                    showPlanetTypePicker: $showPlanetTypePicker,
                    planetTypes: planetTypes,
                    radius: $radius,
                    distanceFromSun: $distanceFromSun,
                    moons: $moons,
                    gravity: $gravity,
                    tiltOfAxis: $tiltOfAxis,
                    lengthOfYear: $lengthOfYear,
                    lengthOfDay: $lengthOfDay,
                    temperature: $temperature,
                    age: $age
                )
                GalleriesSection(galleryImages: $galleryImages, galleryImageData: $galleryImageData)
                MythSection(mythTitle: $mythTitle, mythDescription: $mythDescription, myths: $myths)
                InternalSection(
                    internalTitle: $internalTitle,
                    layers: $layers,
                    iconOptions: iconOptions,
                    internalImage: $internalImage,
                    internalImageData: $internalImageData
                )
                InDepthSection(
                    inDepthTitle: $inDepthTitle,
                    headerImageInDepth: $headerImageInDepth,
                    headerImageInDepthData: $headerImageInDepthData,
                    infoCards: $infoCards,
                    iconOptions: iconOptions
                )
                ExplorationSection(
                    explorationTitle: $explorationTitle,
                    headerImageExploration: $headerImageExploration,
                    headerImageExplorationData: $headerImageExplorationData,
                    missions: $missions,
                    highlightQuote: $highlightQuote,
                    showcaseImage: $showcaseImage,
                    showcaseImageData: $showcaseImageData,
                    iconOptions: iconOptions
                )
                WikiSection(wikiLink: $wikiLink)
            }
            .scrollContentBackground(.hidden)
            .background(.thinMaterial) // Ngoài ra còn: ultraThinMaterial (ổn) - regularMaterial (đẹp) - thickMaterial & ultraThickMaterial (được thôi à)
            .navigationTitle(LanguageManager.current.string("Edit Planet"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        savePlanet()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .destructiveAction) {
                    if planet.planet_order > 8 {
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
                    viewModel.deletePlanet(planet)
                    dismiss()
                }
                Button(LanguageManager.current.string("Cancel"), role: .cancel) {}
            } message: {
                Text(LanguageManager.current.string("Are you sure you want to delete \(planet.name)?"))
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
            .onChange(of: headerImageInDepth) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        headerImageInDepthData = data
                    }
                }
            }
            .onChange(of: headerImageExploration) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        headerImageExplorationData = data
                    }
                }
            }
            .onChange(of: showcaseImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        showcaseImageData = data
                    }
                }
            }
            .onChange(of: internalImagePicker) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        internalImageData = data
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
    private func savePlanet() {
        let updatedPlanet = PlanetModel(
            id: planet.id,
            name: name,
            planetDescription: description,
            viewCount: planet.viewCount,
            isFavorite: planet.isFavorite,
            planet_order: planet.planet_order,
            imageData: selectedImageData ?? planet.imageData,
            randomInfos: randomInfos.filter { !$0.isEmpty },
            aboutDescription: aboutDescription,
            videoURLs: videoURLs.map { convertYouTubeURL($0) }.filter { !$0.isEmpty },
            planetType: planetType,
            radius: radius,
            distanceFromSun: distanceFromSun,
            moons: moons,
            gravity: gravity,
            tiltOfAxis: tiltOfAxis,
            lengthOfYear: lengthOfYear,
            lengthOfDay: lengthOfDay,
            temperature: temperature,
            age: age,
            galleryImageData: galleryImageData.compactMap { $0 },
            mythTitle: mythTitle,
            mythDescription: mythDescription,
            myths: myths.compactMap { tuple in
                if !tuple.culture.isEmpty || !tuple.godName.isEmpty || !tuple.description.isEmpty {
                    return PlanetMyth(culture: tuple.culture, godName: tuple.godName, mythDescription: tuple.description, imageData: tuple.imageData)
                }
                return nil
            },
            internalTitle: internalTitle,
            layers: layers.compactMap { tuple in
                if !tuple.name.isEmpty {
                    return PlanetLayer(name: tuple.name, layerDescription: tuple.description, colorStart: tuple.colorStart.toHex(), colorEnd: tuple.colorEnd.toHex(), icon: tuple.selectedIcon)
                }
                return nil
            },
            internalImage: internalImageData ?? planet.internalImage,
            inDepthTitle: inDepthTitle,
            headerImageInDepthData: headerImageInDepthData ?? planet.headerImageInDepthData,
            infoCards: infoCards.compactMap { tuple in
                if !tuple.title.isEmpty {
                    return PlanetInfoCard(icon: tuple.icon, title: tuple.title, infoCardDescription: tuple.description, iconColor: tuple.iconColor.toHex())
                }
                return nil
            },
            explorationTitle: explorationTitle,
            headerImageExplorationData: headerImageExplorationData ?? planet.headerImageExplorationData,
            missions: missions.compactMap { tuple in
                if !tuple.title.isEmpty {
                    return PlanetMission(title: tuple.title, missionDescription: tuple.description, icon: tuple.icon, missionId: tuple.id)
                }
                return nil
            },
            highlightQuote: highlightQuote,
            showcaseImageData: showcaseImageData ?? planet.showcaseImageData,
            wikiLink: wikiLink
        )
        viewModel.updatePlanet(updatedPlanet)
    }
}

#Preview {
    EditPlanetView(viewModel: SolarSystemViewModel(), planet: PlanetModel(name: "Test", planetDescription: "Test", planet_order: 9, randomInfos: [], videoURLs: []))
}
