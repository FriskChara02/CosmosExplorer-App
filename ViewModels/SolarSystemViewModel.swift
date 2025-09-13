//
//  SolarSystemViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/8/25.
//

import Foundation
import SwiftData
import PostgresClientKit

class SolarSystemViewModel: ObservableObject {
    @Published var planets: [PlanetModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?

    var filteredPlanets: [PlanetModel] {
        let base = searchText.isEmpty
            ? planets
            : planets.filter { $0.name.lowercased().contains(searchText.lowercased()) }

        return base.sorted {
            if $0.isFavorite == $1.isFavorite {
                return true
            }
            return $0.isFavorite && !$1.isFavorite
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func toggleFavorite(planet: PlanetModel) {
        planet.isFavorite.toggle()

        // Update in PostgreSQL
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE planets SET is_favorite = $1 WHERE id = $2
            """)
            try statement.execute(parameterValues: [planet.isFavorite, planet.id.uuidString])
        } catch {
            print("Error updating planet: \(error)")
        }
    }

    func incrementViewCount(planet: PlanetModel) {
        planet.viewCount += 1

        // Update in PostgreSQL
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE planets SET view_count = $1 WHERE id = $2
            """)
            try statement.execute(parameterValues: [planet.viewCount, planet.id.uuidString])
        } catch {
            print("Error updating view count: \(error)")
        }
    }

    func loadPlanets() {
        // Sample data
        let samplePlanets = [
            PlanetModel(name: "Sun", planetDescription: "The star at the center of the Solar System.", viewCount: 0, planet_order: 0),
            PlanetModel(name: "Mercury", planetDescription: "The smallest planet in our Solar System.", viewCount: 0, planet_order: 1),
            PlanetModel(name: "Venus", planetDescription: "The hottest planet in our Solar System.", viewCount: 0, planet_order: 2),
            PlanetModel(name: "Earth", planetDescription: "The only planet known to support life.", viewCount: 0, planet_order: 3),
            PlanetModel(name: "Mars", planetDescription: "Known as the Red Planet due to its dusty, iron-rich surface.", viewCount: 0, planet_order: 4),
            PlanetModel(name: "Jupiter", planetDescription: "The largest planet in our Solar System.", viewCount: 0, planet_order: 5),
            PlanetModel(name: "Saturn", planetDescription: "Famous for its stunning system of rings.", viewCount: 0, planet_order: 6),
            PlanetModel(name: "Uranus", planetDescription: "A gas giant that rotates on its side.", viewCount: 0, planet_order: 7),
            PlanetModel(name: "Neptune", planetDescription: "The farthest planet from the Sun and known for its deep blue color.", viewCount: 0, planet_order: 8)
        ]

        // Fetch from PostgreSQL
        guard let connection = try? DatabaseConfig.createConnection() else {
            self.planets = samplePlanets
            return
        }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, name, description, view_count, is_favorite, planet_order 
                FROM planets
                ORDER BY planet_order ASC
            """)
            let cursor = try statement.execute()
            var fetchedPlanets: [PlanetModel] = []

            for row in cursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].string()) ?? UUID()
                let name = try columns[1].string()
                let description = try columns[2].string()
                let viewCount = try columns[3].int()
                let isFavorite = try columns[4].bool()
                let planetOrder = try columns[5].int()

                let planet = PlanetModel(id: id, name: name, planetDescription: description, viewCount: viewCount, isFavorite: isFavorite, planet_order: planetOrder)
                fetchedPlanets.append(planet)
            }

            if fetchedPlanets.isEmpty {
                // If no data, save sample data to PostgreSQL and SwiftData
                for planet in samplePlanets {
                    let statement = try connection.prepareStatement(text: """
                        INSERT INTO planets (id, name, description, view_count, is_favorite, planet_order)
                        VALUES ($1, $2, $3, $4, $5, $6)
                    """)
                    try statement.execute(parameterValues: [
                        planet.id.uuidString, planet.name, planet.planetDescription, planet.viewCount, planet.isFavorite, planet.planet_order
                    ])
                    if let context = modelContext {
                        context.insert(planet)
                    }
                }
                self.planets = samplePlanets
            } else {
                self.planets = fetchedPlanets
                if let context = modelContext {
                    for planet in fetchedPlanets {
                        context.insert(planet)
                    }
                }
            }
        } catch {
            print("Error loading planets: \(error)")
            self.planets = samplePlanets
        }
    }
}
