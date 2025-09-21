//
//  SolarSystemViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/8/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class SolarSystemViewModel: ObservableObject {
    @Published var planets: [PlanetModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredPlanets: [PlanetModel] {
        let base = searchText.isEmpty
            ? planets
            : planets.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.planet_order < $1.planet_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    // MARK: - Setup
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Planet Actions
    func incrementViewCount(planet: PlanetModel) {
        guard !planet.name.isEmpty else {
            print("⚠️ Skipping view count for invalid planet")
            return
        }
        
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            planets[index].viewCount += 1
            swiftDataService.updatePlanet(planets[index])
            print("🔄 Updated view count for \(planet.name): \(planets[index].viewCount)")
        }
    }
    
    func toggleFavorite(planet: PlanetModel) {
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            planets[index].isFavorite.toggle()
            swiftDataService.updatePlanet(planets[index])
            print("❤️ Toggled favorite for \(planet.name): \(planets[index].isFavorite)")
        }
    }
    
    func addPlanet(_ planet: PlanetModel) {
        if !planets.contains(where: { $0.id == planet.id }) {
            planets.append(planet)
            swiftDataService.savePlanet(planet)
            print("✅ Added new planet: \(planet.name)")
        } else {
            print("⚠️ Planet \(planet.name) already exists, skipping add")
        }
    }
    
    // MARK: - Load Planets
    func loadPlanets() async {
        planets = swiftDataService.fetchPlanets()
        if planets.isEmpty {
            print("🌟 Creating sample planets as both SwiftData and PostgreSQL are empty")
            await createSamplePlanets()
        }
        planets.sort { $0.planet_order < $1.planet_order }
        print("✅ Loaded planets: \(planets.map { $0.name })")
    }
    
    // MARK: - Sample Planets
    private func createSamplePlanets() async {
        let samplePlanets = [
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: "Sun",
                planetDescription: "The star at the center of the Solar System.",
                viewCount: 0,
                planet_order: 0,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: "Mercury",
                planetDescription: "The smallest planet in our Solar System.",
                viewCount: 0,
                planet_order: 1,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: "Venus",
                planetDescription: "The hottest planet in our Solar System.",
                viewCount: 0,
                planet_order: 2,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
                name: "Earth",
                planetDescription: "The only planet known to support life.",
                viewCount: 0,
                planet_order: 3,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
                name: "Mars",
                planetDescription: "Known as the Red Planet due to its dusty, iron-rich surface.",
                viewCount: 0,
                planet_order: 4,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
                name: "Jupiter",
                planetDescription: "The largest planet in our Solar System.",
                viewCount: 0,
                planet_order: 5,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID(),
                name: "Saturn",
                planetDescription: "Famous for its stunning system of rings.",
                viewCount: 0,
                planet_order: 6,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000007") ?? UUID(),
                name: "Uranus",
                planetDescription: "A gas giant that rotates on its side.",
                viewCount: 0,
                planet_order: 7,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000008") ?? UUID(),
                name: "Neptune",
                planetDescription: "The farthest planet from the Sun and known for its deep blue color.",
                viewCount: 0,
                planet_order: 8,
                randomInfos: [],
                videoURLs: []
            )
        ]
        
        for planet in samplePlanets {
            if !planets.contains(where: { $0.id == planet.id }) {
                swiftDataService.savePlanet(planet)
                if let context = modelContext {
                    context.insert(planet)
                    do {
                        try context.save()
                        print("💾 Saved sample planet: \(planet.name)")
                    } catch {
                        print("❌ Error saving sample planet \(planet.name): \(error)")
                    }
                }
                planets.append(planet)
            }
        }
    }
}
