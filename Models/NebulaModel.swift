//
//  NebulaModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import Foundation
import SwiftData

@Model
class NebulaModel: Identifiable {
    var id: UUID
    var name: String
    var nebulaDescription: String
    var viewCount: Int
    var isFavorite: Bool
    var nebula_order: Int
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
        nebulaDescription: String,
        viewCount: Int = 0,
        isFavorite: Bool = false,
        nebula_order: Int = 0,
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
        self.nebulaDescription = nebulaDescription
        self.viewCount = viewCount
        self.isFavorite = isFavorite
        self.nebula_order = nebula_order
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

extension NebulaModel {
    func update(from other: NebulaModel) {
        name = other.name
        nebulaDescription = other.nebulaDescription
        viewCount = other.viewCount
        isFavorite = other.isFavorite
        nebula_order = other.nebula_order
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
