//
//  StarViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class StarViewModel: ObservableObject {
    @Published var stars: [StarModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredStars: [StarModel] {
        let base = searchText.isEmpty
            ? stars
            : stars.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.star_order < $1.star_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(star: StarModel) {
        guard !star.name.isEmpty else {
            print("⚠️ Skipping view count for invalid star")
            return
        }
        
        if let index = stars.firstIndex(where: { $0.id == star.id }) {
            stars[index].viewCount += 1
            swiftDataService.updateStar(stars[index])
            print("🔄 Updated view count for \(star.name): \(stars[index].viewCount)")
        }
    }
    
    func toggleFavorite(star: StarModel) {
        if let index = stars.firstIndex(where: { $0.id == star.id }) {
            stars[index].isFavorite.toggle()
            swiftDataService.updateStar(stars[index])
            print("❤️ Toggled favorite for \(star.name): \(stars[index].isFavorite)")
        }
    }
    
    func addStar(_ star: StarModel) {
        if !stars.contains(where: { $0.id == star.id }) {
            stars.append(star)
            swiftDataService.saveStar(star)
            stars.sort { $0.star_order < $1.star_order }
            print("✅ Added new star: \(star.name)")
        } else {
            print("⚠️ Star \(star.name) already exists, skipping add")
        }
    }
    
    func loadStars() async {
        stars = swiftDataService.fetchStars()
        if stars.isEmpty {
            print("🌟 Creating sample stars as both SwiftData and PostgreSQL are empty")
            await createSampleStars()
        }
        stars.sort { $0.star_order < $1.star_order }
        print("✅ Loaded stars: \(stars.map { $0.name })")
    }
    
    func deleteStar(_ star: StarModel) {
        guard star.star_order > 2 else {
            print("⚠️ Cannot delete hard-coded star: \(star.name)")
            return
        }
        
        if let index = stars.firstIndex(where: { $0.id == star.id }) {
            let starToDelete = stars.remove(at: index)
            swiftDataService.deleteStar(starToDelete)
            print("🗑️ Deleted star: \(star.name)")
        }
    }
    
    func updateStar(_ star: StarModel) {
        if let index = stars.firstIndex(where: { $0.id == star.id }) {
            stars[index].update(from: star)
            swiftDataService.updateStar(stars[index])
            print("🔄 Updated star: \(star.name)")
        }
    }
    
    private func createSampleStars() async {
        let sampleStars = [
            StarModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Sirius"),
                starDescription: LanguageManager.current.string("SiriusDescription"),
                viewCount: 0,
                star_order: 0,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Sirius About Description"),
                videoURLs: [],
                radius: "~1.711 solar radii",
                distanceFromSun: "~8.6 light-years",
                age: "~242 million years",
                wikiLink: "https://en.wikipedia.org/wiki/Sirius"
            ),
            StarModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("Canopus"),
                starDescription: LanguageManager.current.string("CanopusDescription"),
                viewCount: 0,
                star_order: 1,
                randomInfos: [],
                videoURLs: [],
                radius: "~71 solar radii",
                distanceFromSun: "~310 light-years",
                age: "~10-20 million years",
                wikiLink: "https://en.wikipedia.org/wiki/Canopus"
            ),
            StarModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Alpha Centauri"),
                starDescription: LanguageManager.current.string("AlphaCentauriDescription"),
                viewCount: 0,
                star_order: 2,
                randomInfos: [],
                videoURLs: [],
                radius: "~1.223 solar radii (A)",
                distanceFromSun: "~4.37 light-years",
                age: "~4.85 billion years",
                wikiLink: "https://en.wikipedia.org/wiki/Alpha_Centauri"
            )
        ]
        
        for star in sampleStars {
            if !stars.contains(where: { $0.id == star.id }) {
                swiftDataService.saveStar(star)
                if let context = modelContext {
                    context.insert(star)
                    do {
                        try context.save()
                        print("💾 Saved sample star: \(star.name)")
                    } catch {
                        print("❌ Error saving sample star \(star.name): \(error)")
                    }
                }
                stars.append(star)
            }
        }
    }
}
