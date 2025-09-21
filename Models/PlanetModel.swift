//
//  PlanetModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData

@Model
class PlanetModel: Identifiable {
    var id: UUID
    var name: String
    var planetDescription: String
    var viewCount: Int
    var isFavorite: Bool
    var planet_order: Int
    var imageData: Data?
    var randomInfosData: Data
    var aboutDescription: String
    var videoURLsData: Data
    var planetType: String
    var radius: String
    var distanceFromSun: String
    var moons: String
    var gravity: String
    var tiltOfAxis: String
    var lengthOfYear: String
    var lengthOfDay: String
    var temperature: String
    var age: String
    @Attribute(.externalStorage)
    var galleryImageData: [Data?]
    var mythTitle: String
    var mythDescription: String
    var myths: [PlanetMyth]
    var internalTitle: String
    var layers: [PlanetLayer]
    var internalImage: Data?
    var inDepthTitle: String
    var headerImageInDepthData: Data?
    var infoCards: [PlanetInfoCard]
    var explorationTitle: String
    var headerImageExplorationData: Data?
    var missions: [PlanetMission]
    var highlightQuote: String
    var showcaseImageData: Data?
    var wikiLink: String
    
    var randomInfos: [String] {
        get {
            guard let data = try? JSONDecoder().decode([String].self, from: randomInfosData) else { return [] }
            return data
        }
        set {
            randomInfosData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    var videoURLs: [String] {
        get {
            guard let data = try? JSONDecoder().decode([String].self, from: videoURLsData) else { return [] }
            return data
        }
        set {
            videoURLsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        planetDescription: String,
        viewCount: Int = 0,
        isFavorite: Bool = false,
        planet_order: Int = 0,
        imageData: Data? = nil,
        randomInfos: [String] = [],
        aboutDescription: String = "",
        videoURLs: [String] = [],
        planetType: String = "",
        radius: String = "",
        distanceFromSun: String = "",
        moons: String = "",
        gravity: String = "",
        tiltOfAxis: String = "",
        lengthOfYear: String = "",
        lengthOfDay: String = "",
        temperature: String = "",
        age: String = "",
        galleryImageData: [Data?] = [],
        mythTitle: String = "",
        mythDescription: String = "",
        myths: [PlanetMyth] = [],
        internalTitle: String = "",
        layers: [PlanetLayer] = [],
        internalImage: Data? = nil,
        inDepthTitle: String = "",
        headerImageInDepthData: Data? = nil,
        infoCards: [PlanetInfoCard] = [],
        explorationTitle: String = "",
        headerImageExplorationData: Data? = nil,
        missions: [PlanetMission] = [],
        highlightQuote: String = "",
        showcaseImageData: Data? = nil,
        wikiLink: String = ""
    ) {
        self.id = id
        self.name = name
        self.planetDescription = planetDescription
        self.viewCount = viewCount
        self.isFavorite = isFavorite
        self.planet_order = planet_order
        self.imageData = imageData
        self.randomInfosData = (try? JSONEncoder().encode(randomInfos)) ?? Data()
        self.aboutDescription = aboutDescription
        self.videoURLsData = (try? JSONEncoder().encode(videoURLs)) ?? Data()
        self.planetType = planetType
        self.radius = radius
        self.distanceFromSun = distanceFromSun
        self.moons = moons
        self.gravity = gravity
        self.tiltOfAxis = tiltOfAxis
        self.lengthOfYear = lengthOfYear
        self.lengthOfDay = lengthOfDay
        self.temperature = temperature
        self.age = age
        self.galleryImageData = galleryImageData
        self.mythTitle = mythTitle
        self.mythDescription = mythDescription
        self.myths = myths
        self.internalTitle = internalTitle
        self.layers = layers
        self.internalImage = internalImage
        self.inDepthTitle = inDepthTitle
        self.headerImageInDepthData = headerImageInDepthData
        self.infoCards = infoCards
        self.explorationTitle = explorationTitle
        self.headerImageExplorationData = headerImageExplorationData
        self.missions = missions
        self.highlightQuote = highlightQuote
        self.showcaseImageData = showcaseImageData
        self.wikiLink = wikiLink
    }
}

@Model
class PlanetMyth: Identifiable {
    var id: UUID
    var culture: String
    var godName: String
    var mythDescription: String
    var imageData: Data?

    init(id: UUID = UUID(), culture: String, godName: String, mythDescription: String, imageData: Data? = nil) {
        self.id = id
        self.culture = culture
        self.godName = godName
        self.mythDescription = mythDescription
        self.imageData = imageData
    }
}

@Model
class PlanetLayer: Identifiable {
    var id: UUID
    var name: String
    var layerDescription: String
    var colorStart: String
    var colorEnd: String
    var icon: String

    init(id: UUID = UUID(), name: String, layerDescription: String, colorStart: String, colorEnd: String, icon: String) {
        self.id = id
        self.name = name
        self.layerDescription = layerDescription
        self.colorStart = colorStart
        self.colorEnd = colorEnd
        self.icon = icon
    }
}

@Model
class PlanetInfoCard: Identifiable {
    var id: UUID
    var icon: String
    var title: String
    var infoCardDescription: String
    var iconColor: String

    init(id: UUID = UUID(), icon: String, title: String, infoCardDescription: String, iconColor: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.infoCardDescription = infoCardDescription
        self.iconColor = iconColor
    }
}

@Model
class PlanetMission: Identifiable {
    var id: UUID
    var title: String
    var missionDescription: String
    var icon: String
    var missionId: String

    init(id: UUID = UUID(), title: String, missionDescription: String, icon: String, missionId: String) {
        self.id = id
        self.title = title
        self.missionDescription = missionDescription
        self.icon = icon
        self.missionId = missionId
    }
}
