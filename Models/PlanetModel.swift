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

    init(id: UUID = UUID(), name: String, planetDescription: String, viewCount: Int = 0, isFavorite: Bool = false, planet_order: Int = 0) {
        self.id = id
        self.name = name
        self.planetDescription = planetDescription
        self.viewCount = viewCount
        self.isFavorite = isFavorite
        self.planet_order = planet_order
    }
}
