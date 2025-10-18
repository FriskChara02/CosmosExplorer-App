//
//  NebulaViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class NebulaViewModel: ObservableObject {
    @Published var nebulas: [NebulaModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredNebulas: [NebulaModel] {
        let base = searchText.isEmpty
            ? nebulas
            : nebulas.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.nebula_order < $1.nebula_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(nebula: NebulaModel) {
        guard !nebula.name.isEmpty else {
            print("⚠️ Skipping view count for invalid nebula")
            return
        }
        
        if let index = nebulas.firstIndex(where: { $0.id == nebula.id }) {
            nebulas[index].viewCount += 1
            swiftDataService.updateNebula(nebulas[index])
            print("🔄 Updated view count for \(nebula.name): \(nebulas[index].viewCount)")
        }
    }
    
    func toggleFavorite(nebula: NebulaModel) {
        if let index = nebulas.firstIndex(where: { $0.id == nebula.id }) {
            nebulas[index].isFavorite.toggle()
            swiftDataService.updateNebula(nebulas[index])
            print("❤️ Toggled favorite for \(nebula.name): \(nebulas[index].isFavorite)")
        }
    }
    
    func addNebula(_ nebula: NebulaModel) {
        if !nebulas.contains(where: { $0.id == nebula.id }) {
            nebulas.append(nebula)
            swiftDataService.saveNebula(nebula)
            nebulas.sort { $0.nebula_order < $1.nebula_order }
            print("✅ Added new nebula: \(nebula.name)")
        } else {
            print("⚠️ Nebula \(nebula.name) already exists, skipping add")
        }
    }
    
    func loadNebulas() async {
        nebulas = swiftDataService.fetchNebulas()
        if nebulas.isEmpty {
            print("🌌 Creating sample nebulas as both SwiftData and PostgreSQL are empty")
            await createSampleNebulas()
        }
        nebulas.sort { $0.nebula_order < $1.nebula_order }
        print("✅ Loaded nebulas: \(nebulas.map { $0.name })")
    }
    
    func deleteNebula(_ nebula: NebulaModel) {
        guard nebula.nebula_order > 2 else {
            print("⚠️ Cannot delete hard-coded nebula: \(nebula.name)")
            return
        }
        
        if let index = nebulas.firstIndex(where: { $0.id == nebula.id }) {
            let nebulaToDelete = nebulas.remove(at: index)
            swiftDataService.deleteNebula(nebulaToDelete)
            print("🗑️ Deleted nebula: \(nebula.name)")
        }
    }
    
    func updateNebula(_ nebula: NebulaModel) {
        if let index = nebulas.firstIndex(where: { $0.id == nebula.id }) {
            nebulas[index].update(from: nebula)
            swiftDataService.updateNebula(nebulas[index])
            print("🔄 Updated nebula: \(nebula.name)")
        }
    }
    
    private func createSampleNebulas() async {
        let sampleNebulas = [
            NebulaModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Eagle"),
                nebulaDescription: LanguageManager.current.string("EagleDescription"),
                viewCount: 0,
                nebula_order: 0,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Eagle About Description"),
                videoURLs: [],
                radius: "~10 light-years",
                distanceFromSun: "~7,000 light-years",
                age: "~5.5 million years",
                wikiLink: "https://en.wikipedia.org/wiki/Eagle_Nebula"
            ),
            NebulaModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("Butterfly"),
                nebulaDescription: LanguageManager.current.string("ButterflyDescription"),
                viewCount: 0,
                nebula_order: 1,
                randomInfos: [],
                videoURLs: [],
                radius: "~2 light-years",
                distanceFromSun: "~2,100 light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/NGC_6302"
            ),
            NebulaModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Helix"),
                nebulaDescription: LanguageManager.current.string("HelixDescription"),
                viewCount: 0,
                nebula_order: 2,
                randomInfos: [],
                videoURLs: [],
                radius: "~2.87 light-years",
                distanceFromSun: "~650 light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/Helix_Nebula"
            )
        ]
        
        for nebula in sampleNebulas {
            if !nebulas.contains(where: { $0.id == nebula.id }) {
                swiftDataService.saveNebula(nebula)
                if let context = modelContext {
                    context.insert(nebula)
                    do {
                        try context.save()
                        print("💾 Saved sample nebula: \(nebula.name)")
                    } catch {
                        print("❌ Error saving sample nebula \(nebula.name): \(error)")
                    }
                }
                nebulas.append(nebula)
            }
        }
    }
}
