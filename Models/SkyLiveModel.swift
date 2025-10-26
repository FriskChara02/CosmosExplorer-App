//
//  SkyLiveModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import CoreLocation

struct PlanetInfo {
    let name: String
    let rise: String
    let transit: String
    let set: String
    let altitude: String
    let currentTime: String?
    let orbitalSpeed: String? // Tốc độ quay quanh Mặt Trời (km/s)
    let dayLength: String? // Thời lượng ngày (cho Mặt Trời)
    let nightLength: String? // Thời lượng đêm (cho Mặt Trời)
    let moonPhase: String?
    let nextMoonPhases: [String]?
    let seasons: [String]? // Mùa (cho Mặt Trời)
    let astronomicalEvents: [AstronomicalEvent]? // Các sự kiện đặc biệt
}
struct AstronomicalEvent {
    let name: String
    let date: String
    let description: String
}

