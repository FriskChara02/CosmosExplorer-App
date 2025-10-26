//
//  ConstellationModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 26/10/25.
//

import Foundation
import SwiftData

@Model
class ConstellationModel: Identifiable {
    var id: UUID
    var name: String
    var constellationDescription: String
    var viewCount: Int
    var isFavorite: Bool
    var constellation_order: Int
    var imageData: Data?
    var randomInfosData: Data
    var aboutDescription: String
    var videoURLsData: Data
    var mainStars: Int
    var namedStarsData: Data
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
    
    var namedStars: [String] {
        get {
            guard let data = try? JSONDecoder().decode([String].self, from: namedStarsData) else { return [] }
            return data
        }
        set {
            namedStarsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        constellationDescription: String,
        viewCount: Int = 0,
        isFavorite: Bool = false,
        constellation_order: Int = 0,
        imageData: Data? = nil,
        randomInfos: [String] = [],
        aboutDescription: String = "",
        videoURLs: [String] = [],
        mainStars: Int = 0,
        namedStars: [String] = [],
        galleryImageData: [Data?] = [],
        wikiLink: String = ""
    ) {
        self.id = id
        self.name = name
        self.constellationDescription = constellationDescription
        self.viewCount = viewCount
        self.isFavorite = isFavorite
        self.constellation_order = constellation_order
        self.imageData = imageData
        self.randomInfosData = (try? JSONEncoder().encode(randomInfos)) ?? Data()
        self.aboutDescription = aboutDescription
        self.videoURLsData = (try? JSONEncoder().encode(videoURLs)) ?? Data()
        self.mainStars = mainStars
        self.namedStarsData = (try? JSONEncoder().encode(namedStars)) ?? Data()
        self.galleryImageData = galleryImageData
        self.wikiLink = wikiLink
    }
}

extension ConstellationModel {
    func update(from other: ConstellationModel) {
        name = other.name
        constellationDescription = other.constellationDescription
        viewCount = other.viewCount
        isFavorite = other.isFavorite
        constellation_order = other.constellation_order
        imageData = other.imageData
        randomInfos = other.randomInfos
        aboutDescription = other.aboutDescription
        videoURLs = other.videoURLs
        mainStars = other.mainStars
        namedStars = other.namedStars
        galleryImageData = other.galleryImageData
        wikiLink = other.wikiLink
    }
}

