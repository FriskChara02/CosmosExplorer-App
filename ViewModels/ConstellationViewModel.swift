//
//  ConstellationViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/10/25.
//

import Foundation
import SwiftData
import PostgresClientKit
@MainActor
class ConstellationViewModel: ObservableObject {
    @Published var constellations: [ConstellationModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredConstellations: [ConstellationModel] {
        let base = searchText.isEmpty
            ? constellations
            : constellations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.constellation_order < $1.constellation_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(constellation: ConstellationModel) {
        guard !constellation.name.isEmpty else {
            print("⚠️ Skipping view count for invalid constellation")
            return
        }
        
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            constellations[index].viewCount += 1
            swiftDataService.updateConstellation(constellations[index])
            print("🔄 Updated view count for \(constellation.name): \(constellations[index].viewCount)")
        }
    }
    
    func toggleFavorite(constellation: ConstellationModel) {
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            constellations[index].isFavorite.toggle()
            swiftDataService.updateConstellation(constellations[index])
            print("❤️ Toggled favorite for \(constellation.name): \(constellations[index].isFavorite)")
        }
    }
    
    func addConstellation(_ constellation: ConstellationModel) {
        if !constellations.contains(where: { $0.id == constellation.id }) {
            constellations.append(constellation)
            swiftDataService.saveConstellation(constellation)
            constellations.sort { $0.constellation_order < $1.constellation_order }
            print("✅ Added new constellation: \(constellation.name)")
        } else {
            print("⚠️ Constellation \(constellation.name) already exists, skipping add")
        }
    }
    
    func loadConstellations() async {
        constellations = swiftDataService.fetchConstellations()
        if constellations.isEmpty {
            print("🌟 Creating sample constellations as both SwiftData and PostgreSQL are empty")
            await createSampleConstellations()
        }
        constellations.sort { $0.constellation_order < $1.constellation_order }
        print("✅ Loaded constellations: \(constellations.map { $0.name })")
    }
    
    func deleteConstellation(_ constellation: ConstellationModel) {
        guard constellation.constellation_order > 2 else {
            print("⚠️ Cannot delete hard-coded constellation: \(constellation.name)")
            return
        }
        
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            let constellationToDelete = constellations.remove(at: index)
            swiftDataService.deleteConstellation(constellationToDelete)
            print("🗑️ Deleted constellation: \(constellation.name)")
        }
    }
    
    func updateConstellation(_ constellation: ConstellationModel) {
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            constellations[index].update(from: constellation)
            swiftDataService.updateConstellation(constellations[index])
            print("🔄 Updated constellation: \(constellation.name)")
        }
    }
    
    private func createSampleConstellations() async {
        let sampleConstellations = [
            ConstellationModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Aquarius"),
                constellationDescription: LanguageManager.current.string("AquariusDescription"),
                viewCount: 0,
                constellation_order: 0,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Aquarius About Description"),
                videoURLs: [],
                mainStars: 10,
                namedStars: ["Sadalmelik", "Sadalsuud", "Albali", "Skat", "Ancha"],
                wikiLink: "https://en.wikipedia.org/wiki/Aquarius_(constellation)"
            ),
            ConstellationModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("Cancer"),
                constellationDescription: LanguageManager.current.string("CancerDescription"),
                viewCount: 0,
                constellation_order: 1,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Cancer About Description"),
                videoURLs: [],
                mainStars: 5,
                namedStars: ["Tarf", "Acubens", "Asellus Borealis", "Asellus Australis", "Altarf"],
                wikiLink: "https://en.wikipedia.org/wiki/Cancer_(constellation)"
            ),
            ConstellationModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Capricorn"),
                constellationDescription: LanguageManager.current.string("CapricornDescription"),
                viewCount: 0,
                constellation_order: 2,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Capricorn About Description"),
                videoURLs: [],
                mainStars: 8,
                namedStars: ["Deneb Algedi", "Dabih", "Nashira", "Algedi", "Alshat"],
                wikiLink: "https://en.wikipedia.org/wiki/Capricornus"
            )
        ]
        
        for constellation in sampleConstellations {
            if !constellations.contains(where: { $0.id == constellation.id }) {
                swiftDataService.saveConstellation(constellation)
                if let context = modelContext {
                    context.insert(constellation)
                    do {
                        try context.save()
                        print("💾 Saved sample constellation: \(constellation.name)")
                    } catch {
                        print("❌ Error saving sample constellation \(constellation.name): \(error)")
                    }
                }
                constellations.append(constellation)
            }
        }
    }
}

