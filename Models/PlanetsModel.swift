//
//  PlanetsModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 23/10/25.
//

import Foundation
import SwiftData

@Model
class PlanetsModel: Identifiable {
    var id: UUID
    var name: String
    var planetsDescription: String
    var viewCount: Int
    var isFavorite: Bool
    var planets_order: Int
    var imageData: Data?
    var randomInfosData: Data
    var aboutDescription: String
    var videoURLsData: Data
    var radius: String
    var distanceFromSun: String
    var age: String
    @Attribute(.externalStorage)
    var galleryImageData: [Data?]
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
        planetsDescription: String,
        viewCount: Int = 0,
        isFavorite: Bool = false,
        planets_order: Int = 0,
        imageData: Data? = nil,
        randomInfos: [String] = [],
        aboutDescription: String = "",
        videoURLs: [String] = [],
        radius: String = "Unknown",
        distanceFromSun: String = "Unknown",
        age: String = "Unknown",
        galleryImageData: [Data?] = [],
        wikiLink: String = ""
    ) {
        self.id = id
        self.name = name
        self.planetsDescription = planetsDescription
        self.viewCount = viewCount
        self.isFavorite = isFavorite
        self.planets_order = planets_order
        self.imageData = imageData
        self.randomInfosData = (try? JSONEncoder().encode(randomInfos)) ?? Data()
        self.aboutDescription = aboutDescription
        self.videoURLsData = (try? JSONEncoder().encode(videoURLs)) ?? Data()
        self.radius = radius
        self.distanceFromSun = distanceFromSun
        self.age = age
        self.galleryImageData = galleryImageData
        self.wikiLink = wikiLink
    }
}

extension PlanetsModel {
    func update(from other: PlanetsModel) {
        name = other.name
        planetsDescription = other.planetsDescription
        viewCount = other.viewCount
        isFavorite = other.isFavorite
        planets_order = other.planets_order
        imageData = other.imageData
        randomInfos = other.randomInfos
        aboutDescription = other.aboutDescription
        videoURLs = other.videoURLs
        radius = other.radius
        distanceFromSun = other.distanceFromSun
        age = other.age
        galleryImageData = other.galleryImageData
        wikiLink = other.wikiLink
    }
}

