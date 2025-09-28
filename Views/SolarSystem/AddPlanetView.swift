//
//  AddPlanetView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/8/25.
//

import SwiftUI
import PhotosUI

struct AddPlanetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SolarSystemViewModel
    
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
    
    // Tab By the Numbers
    @State private var planetType: String = ""
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
    @State private var radius: String = ""
    @State private var distanceFromSun: String = ""
    @State private var moons: String = ""
    @State private var gravity: String = ""
    @State private var tiltOfAxis: String = ""
    @State private var lengthOfYear: String = ""
    @State private var lengthOfDay: String = ""
    @State private var temperature: String = ""
    @State private var age: String = ""
    
    // Tab Galleries
    @State private var galleryImages: [PhotosPickerItem?] = [nil]
    @State private var galleryImageData: [Data?] = [nil]
    
    // Tab Myth
    @State private var mythTitle: String = ""
    @State private var mythDescription: String = ""
    @State private var myths: [(culture: String, godName: String, description: String, selectedImage: PhotosPickerItem?, imageData: Data?)] = [("", "", "", nil, nil)]
    
    // Tab Internal
    @State private var internalTitle: String = ""
    @State private var layers: [(name: String, description: String, colorStart: Color, colorEnd: Color, selectedIcon: String)] = [("", "", .white, .white, "star.fill")]
    private let iconOptions = [
        "star.fill", "circle.fill", "sun.max.fill", "moon.fill", "gauge",
        "arrow.triangle.2.circlepath", "calendar", "clock", "thermometer", "hourglass",
        "wave.3.forward.circle.fill", "flame.fill", "bolt.fill", "airplane",
        "camera.metering.matrix", "paperplane.fill", "sparkles", "globe.americas.fill", "rays", "waveform.path.ecg"
    ]
    @State private var internalImage: String = ""
    @State private var internalImageData: Data? = nil
    
    // Tab In Depth
    @State private var inDepthTitle: String = ""
    @State private var headerImageInDepth: PhotosPickerItem? = nil
    @State private var headerImageInDepthData: Data? = nil
    @State private var infoCards: [(icon: String, title: String, description: String, iconColor: Color)] = [("", "", "", .white)]
    
    // Tab Exploration
    @State private var explorationTitle: String = ""
    @State private var headerImageExploration: PhotosPickerItem? = nil
    @State private var headerImageExplorationData: Data? = nil
    @State private var missions: [(title: String, description: String, icon: String, id: String)] = [("", "", "star.fill", UUID().uuidString)]
    @State private var highlightQuote: String = ""
    @State private var showcaseImage: PhotosPickerItem? = nil
    @State private var showcaseImageData: Data? = nil
    
    // Wiki
    @State private var wikiLink: String = ""
    
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
            .navigationTitle(LanguageManager.current.string("Add Your New Planet"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LanguageManager.current.string("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LanguageManager.current.string("Save")) {
                        if !name.isEmpty {
                            let newPlanet = PlanetModel(
                                name: name,
                                planetDescription: description,
                                planet_order: viewModel.planets.count,
                                imageData: selectedImageData,
                                randomInfos: randomInfos.filter { !$0.isEmpty },
                                aboutDescription: aboutDescription,
                                videoURLs: videoURLs.filter { !$0.isEmpty },
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
                                galleryImageData: galleryImageData,
                                mythTitle: mythTitle,
                                mythDescription: mythDescription,
                                myths: myths.map { PlanetMyth(culture: $0.culture, godName: $0.godName, mythDescription: $0.description, imageData: $0.imageData) },
                                internalTitle: internalTitle,
                                layers: layers.map { PlanetLayer(name: $0.name, layerDescription: $0.description, colorStart: $0.colorStart.toHex(), colorEnd: $0.colorEnd.toHex(), icon: $0.selectedIcon) },
                                internalImage: internalImageData,
                                inDepthTitle: inDepthTitle,
                                headerImageInDepthData: headerImageInDepthData,
                                infoCards: infoCards.map { PlanetInfoCard(icon: $0.icon, title: $0.title, infoCardDescription: $0.description, iconColor: $0.iconColor.toHex()) },
                                explorationTitle: explorationTitle,
                                headerImageExplorationData: headerImageExplorationData,
                                missions: missions.map { PlanetMission(title: $0.title, missionDescription: $0.description, icon: $0.icon, missionId: $0.id) },
                                highlightQuote: highlightQuote,
                                showcaseImageData: showcaseImageData,
                                wikiLink: wikiLink
                            )
                            viewModel.addPlanet(newPlanet)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Subviews

struct BasicInfoSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Basic information"))) {
            TextField(LanguageManager.current.string("Planet name"), text: $name)
            TextField(LanguageManager.current.string("Short description"), text: $description, axis: .vertical)
                .lineLimit(3)
            HStack {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text(LanguageManager.current.string("Planet Image"))
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

struct OverviewSection: View {
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
                TextField(LanguageManager.current.string("Random information").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $randomInfos[index], axis: .vertical)
                    .lineLimit(3)
            }
            HStack {
                Button(action: {
                    randomInfos.append("")
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if randomInfos.count > 1 {
                        randomInfos.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(randomInfos.count <= 1)
                Spacer()
            }
        }
    }
}

struct InformationSection: View {
    @Binding var aboutDescription: String
    @Binding var videoURLs: [String]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Information"))) {
            TextField(LanguageManager.current.string("About description"), text: $aboutDescription, axis: .vertical)
                .lineLimit(5)
            ForEach(videoURLs.indices, id: \.self) { index in
                TextField(LanguageManager.current.string("Your link video").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $videoURLs[index])
            }
            HStack {
                Button(action: {
                    videoURLs.append("")
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if videoURLs.count > 1 {
                        videoURLs.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(videoURLs.count <= 1)
                Spacer()
            }
        }
    }
}

struct ByTheNumbersSection: View {
    @Binding var planetType: String
    @Binding var showPlanetTypePicker: Bool
    let planetTypes: [String]
    @Binding var radius: String
    @Binding var distanceFromSun: String
    @Binding var moons: String
    @Binding var gravity: String
    @Binding var tiltOfAxis: String
    @Binding var lengthOfYear: String
    @Binding var lengthOfDay: String
    @Binding var temperature: String
    @Binding var age: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("By the Numbers"))) {
            TextField(LanguageManager.current.string("Planet Type"), text: $planetType, onEditingChanged: { isEditing in
                if isEditing {
                    showPlanetTypePicker = true
                }
            })
            if showPlanetTypePicker {
                Picker(LanguageManager.current.string("Select Planet Type"), selection: $planetType) {
                    ForEach(planetTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: planetType) {
                    showPlanetTypePicker = false
                }
            }
            TextField(LanguageManager.current.string("Radius"), text: $radius)
            TextField(LanguageManager.current.string("Distance from Sun"), text: $distanceFromSun)
            TextField(LanguageManager.current.string("Moons"), text: $moons)
            TextField(LanguageManager.current.string("Gravity"), text: $gravity)
            TextField(LanguageManager.current.string("Tilt of Axis"), text: $tiltOfAxis)
            TextField(LanguageManager.current.string("Length of Year"), text: $lengthOfYear)
            TextField(LanguageManager.current.string("Length of Day"), text: $lengthOfDay)
            TextField(LanguageManager.current.string("Temperature"), text: $temperature)
            TextField(LanguageManager.current.string("Age"), text: $age)
        }
    }
}

struct GalleriesSection: View {
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
            HStack {
                Button(action: {
                    galleryImages.append(nil)
                    galleryImageData.append(nil)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if galleryImages.count > 1 {
                        galleryImages.removeLast()
                        galleryImageData.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(galleryImages.count <= 1)
                Spacer()
            }
        }
    }
}

struct MythSection: View {
    @Binding var mythTitle: String
    @Binding var mythDescription: String
    @Binding var myths: [(culture: String, godName: String, description: String, selectedImage: PhotosPickerItem?, imageData: Data?)]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Myth"))) {
            TextField(LanguageManager.current.string("Myth Title"), text: $mythTitle)
            TextField(LanguageManager.current.string("Myth Description"), text: $mythDescription, axis: .vertical)
                .lineLimit(3)
            ForEach(myths.indices, id: \.self) { index in
                VStack {
                    TextField(LanguageManager.current.string("Culture").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $myths[index].culture)
                    TextField(LanguageManager.current.string("God Name").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $myths[index].godName)
                    TextField(LanguageManager.current.string("God Description").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $myths[index].description, axis: .vertical)
                        .lineLimit(3)
                    HStack {
                        PhotosPicker(selection: $myths[index].selectedImage, matching: .images) {
                            Text(LanguageManager.current.string("Image").replacingOccurrences(of: "{index}", with: "\(index + 1)"))
                                .foregroundColor(.blue)
                        }
                        .onChange(of: myths[index].selectedImage) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    myths[index].imageData = data
                                }
                            }
                        }
                        Spacer()
                        if let data = myths[index].imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            HStack {
                Button(action: {
                    myths.append(("", "", "", nil, nil))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if myths.count > 1 {
                        myths.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(myths.count <= 1)
                Spacer()
            }
        }
    }
}

struct InternalSection: View {
    @Binding var internalTitle: String
    @Binding var layers: [(name: String, description: String, colorStart: Color, colorEnd: Color, selectedIcon: String)]
    let iconOptions: [String]
    @Binding var internalImage: String
    @State private var internalImagePicker: PhotosPickerItem? = nil
    @Binding var internalImageData: Data?
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Internal"))) {
            TextField(LanguageManager.current.string("Internal Title"), text: $internalTitle)
            ForEach(layers.indices, id: \.self) { index in
                VStack {
                    TextField(LanguageManager.current.string("Layer name").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $layers[index].name)
                    TextField(LanguageManager.current.string("Layer description").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $layers[index].description, axis: .vertical)
                        .lineLimit(3)
                    ColorPicker(LanguageManager.current.string("Start color"), selection: $layers[index].colorStart)
                    ColorPicker(LanguageManager.current.string("End color"), selection: $layers[index].colorEnd)
                    Picker(LanguageManager.current.string("Icon").replacingOccurrences(of: "{index}", with: "\(index + 1)"), selection: $layers[index].selectedIcon) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon).tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            HStack {
                PhotosPicker(selection: $internalImagePicker, matching: .images) {
                    Text(LanguageManager.current.string("Select the last image of the tab"))
                        .foregroundColor(.blue)
                }
                .onChange(of: internalImagePicker) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            internalImageData = data
                        }
                    }
                }
                Spacer()
                if let data = internalImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
            PhotosPicker(selection: .constant(nil), matching: .images) {
                Text("Select the last image of the tab")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct InDepthSection: View {
    @Binding var inDepthTitle: String
    @Binding var headerImageInDepth: PhotosPickerItem?
    @Binding var headerImageInDepthData: Data?
    @Binding var infoCards: [(icon: String, title: String, description: String, iconColor: Color)]
    let iconOptions: [String]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("In Depth"))) {
            TextField(LanguageManager.current.string("In Depth Title"), text: $inDepthTitle)
            HStack {
                PhotosPicker(selection: $headerImageInDepth, matching: .images) {
                    Text(LanguageManager.current.string("Select header image"))
                        .foregroundColor(.blue)
                }
                .onChange(of: headerImageInDepth) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            headerImageInDepthData = data
                        }
                    }
                }
                Spacer()
                if let data = headerImageInDepthData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
            ForEach(infoCards.indices, id: \.self) { index in
                VStack {
                    Picker(LanguageManager.current.string("Icon").replacingOccurrences(of: "{index}", with: "\(index + 1)"), selection: $infoCards[index].icon) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon).tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                    TextField(LanguageManager.current.string("Card Title").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $infoCards[index].title)
                    TextField(LanguageManager.current.string("Card Description").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $infoCards[index].description, axis: .vertical)
                        .lineLimit(3)
                    ColorPicker(LanguageManager.current.string("Icon color"), selection: $infoCards[index].iconColor)
                }
            }
            HStack {
                Button(action: {
                    infoCards.append(("", "", "", .white))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if infoCards.count > 1 {
                        infoCards.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(infoCards.count <= 1)
                Spacer()
            }
        }
    }
}

struct ExplorationSection: View {
    @Binding var explorationTitle: String
    @Binding var headerImageExploration: PhotosPickerItem?
    @Binding var headerImageExplorationData: Data?
    @Binding var missions: [(title: String, description: String, icon: String, id: String)]
    @Binding var highlightQuote: String
    @Binding var showcaseImage: PhotosPickerItem?
    @Binding var showcaseImageData: Data?
    let iconOptions: [String]
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Exploration"))) {
            TextField(LanguageManager.current.string("Exploration Title"), text: $explorationTitle)
            HStack {
                PhotosPicker(selection: $headerImageExploration, matching: .images) {
                    Text(LanguageManager.current.string("Select header image"))
                        .foregroundColor(.blue)
                }
                .onChange(of: headerImageExploration) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            headerImageExplorationData = data
                        }
                    }
                }
                Spacer()
                if let data = headerImageExplorationData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }
            ForEach(missions.indices, id: \.self) { index in
                VStack {
                    TextField(LanguageManager.current.string("Mission title").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $missions[index].title)
                    TextField(LanguageManager.current.string("Mission description").replacingOccurrences(of: "{index}", with: "\(index + 1)"), text: $missions[index].description, axis: .vertical)
                        .lineLimit(3)
                    Picker(LanguageManager.current.string("Icon").replacingOccurrences(of: "{index}", with: "\(index + 1)"), selection: $missions[index].icon) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon).tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            HStack {
                Button(action: {
                    missions.append(("", "", "star.fill", UUID().uuidString))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: {
                    if missions.count > 1 {
                        missions.removeLast()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .disabled(missions.count <= 1)
                Spacer()
            }
            TextField(LanguageManager.current.string("Highlight Quote"), text: $highlightQuote, axis: .vertical)
                .lineLimit(3)
            HStack {
                PhotosPicker(selection: $showcaseImage, matching: .images) {
                    Text(LanguageManager.current.string("Select showcase photo"))
                        .foregroundColor(.blue)
                }
                .onChange(of: showcaseImage) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            showcaseImageData = data
                        }
                    }
                }
                Spacer()
                if let data = showcaseImageData, let uiImage = UIImage(data: data) {
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

struct WikiSection: View {
    @Binding var wikiLink: String
    
    var body: some View {
        Section(header: Text(LanguageManager.current.string("Wikipedia link"))) {
            TextField(LanguageManager.current.string("Wikipedia"), text: $wikiLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    AddPlanetView(viewModel: SolarSystemViewModel())
}
