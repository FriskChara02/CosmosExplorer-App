//
//  GalaxyViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class GalaxyViewModel: ObservableObject {
    @Published var galaxies: [GalaxyModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredGalaxies: [GalaxyModel] {
        let base = searchText.isEmpty
            ? galaxies
            : galaxies.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.galaxy_order < $1.galaxy_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(galaxy: GalaxyModel) {
        guard !galaxy.name.isEmpty else {
            print("⚠️ Skipping view count for invalid galaxy")
            return
        }
        
        if let index = galaxies.firstIndex(where: { $0.id == galaxy.id }) {
            galaxies[index].viewCount += 1
            swiftDataService.updateGalaxy(galaxies[index])
            print("🔄 Updated view count for \(galaxy.name): \(galaxies[index].viewCount)")
        }
    }
    
    func toggleFavorite(galaxy: GalaxyModel) {
        if let index = galaxies.firstIndex(where: { $0.id == galaxy.id }) {
            galaxies[index].isFavorite.toggle()
            swiftDataService.updateGalaxy(galaxies[index])
            print("❤️ Toggled favorite for \(galaxy.name): \(galaxies[index].isFavorite)")
        }
    }
    
    func addGalaxy(_ galaxy: GalaxyModel) {
        if !galaxies.contains(where: { $0.id == galaxy.id }) {
            galaxies.append(galaxy)
            swiftDataService.saveGalaxy(galaxy)
            galaxies.sort { $0.galaxy_order < $1.galaxy_order }
            print("✅ Added new galaxy: \(galaxy.name)")
        } else {
            print("⚠️ Galaxy \(galaxy.name) already exists, skipping add")
        }
    }
    
    func loadGalaxies() async {
        galaxies = swiftDataService.fetchGalaxies()
        if galaxies.isEmpty {
            print("🌌 Creating sample galaxies as both SwiftData and PostgreSQL are empty")
            await createSampleGalaxies()
        }
        galaxies.sort { $0.galaxy_order < $1.galaxy_order }
        print("✅ Loaded galaxies: \(galaxies.map { $0.name })")
    }
    
    func deleteGalaxy(_ galaxy: GalaxyModel) {
        guard galaxy.galaxy_order > 2 else {
            print("⚠️ Cannot delete hard-coded galaxy: \(galaxy.name)")
            return
        }
        
        if let index = galaxies.firstIndex(where: { $0.id == galaxy.id }) {
            let galaxyToDelete = galaxies.remove(at: index)
            swiftDataService.deleteGalaxy(galaxyToDelete)
            print("🗑️ Deleted galaxy: \(galaxy.name)")
        }
    }
    
    func updateGalaxy(_ galaxy: GalaxyModel) {
        if let index = galaxies.firstIndex(where: { $0.id == galaxy.id }) {
            galaxies[index].update(from: galaxy)
            swiftDataService.updateGalaxy(galaxies[index])
            print("🔄 Updated galaxy: \(galaxy.name)")
        }
    }
    
    private func createSampleGalaxies() async {
        let sampleGalaxies = [
            GalaxyModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Andromeda"),
                galaxyDescription: LanguageManager.current.string("AndromedaDescription"),
                viewCount: 0,
                galaxy_order: 0,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Andromeda About Description"),
                videoURLs: [],
                radius: "~110,000 light-years",
                distanceFromSun: "~2.537 million light-years",
                age: "~10 billion years",
                wikiLink: "https://en.wikipedia.org/wiki/Andromeda_Galaxy"
            ),
            GalaxyModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("M32"),
                galaxyDescription: LanguageManager.current.string("M32Description"),
                viewCount: 0,
                galaxy_order: 1,
                randomInfos: [],
                videoURLs: [],
                radius: "~3,250 light-years",
                distanceFromSun: "~2.65 million light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/Messier_32"
            ),
            GalaxyModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Triangulum"),
                galaxyDescription: LanguageManager.current.string("TriangulumDescription"),
                viewCount: 0,
                galaxy_order: 2,
                randomInfos: [],
                videoURLs: [],
                radius: "~30,000 light-years",
                distanceFromSun: "~2.73 million light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/Triangulum_Galaxy"
            )
        ]
        
        for galaxy in sampleGalaxies {
            if !galaxies.contains(where: { $0.id == galaxy.id }) {
                swiftDataService.saveGalaxy(galaxy)
                if let context = modelContext {
                    context.insert(galaxy)
                    do {
                        try context.save()
                        print("💾 Saved sample galaxy: \(galaxy.name)")
                    } catch {
                        print("❌ Error saving sample galaxy \(galaxy.name): \(error)")
                    }
                }
                galaxies.append(galaxy)
            }
        }
    }
}
