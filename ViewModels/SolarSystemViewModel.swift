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
            planets.sort { $0.planet_order < $1.planet_order }
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
    
    // MARK: - deletePlanet

    func deletePlanet(_ planet: PlanetModel) {
        guard planet.planet_order > 8 else {  // Không xóa hard-code
            print("⚠️ Cannot delete hard-coded planet: \(planet.name)")
            return
        }
        
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            let planetToDelete = planets.remove(at: index)
            swiftDataService.deletePlanet(planetToDelete)
            print("🗑️ Deleted planet: \(planet.name)")
        }
    }

    func updatePlanet(_ planet: PlanetModel) {
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            planets[index] = planet  // Update in-memory
            swiftDataService.updatePlanet(planet)
            print("🔄 Updated planet: \(planet.name)")
        }
    }
    
    // MARK: - Sample Planets
    private func createSamplePlanets() async {
        let samplePlanets = [
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Sun"),
                planetDescription: LanguageManager.current.string("SunDescription"),
                viewCount: 0,
                planet_order: 0,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("Mercury"),
                planetDescription: LanguageManager.current.string("MercuryDescription"),
                viewCount: 0,
                planet_order: 1,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Venus"),
                planetDescription: LanguageManager.current.string("VenusDescription"),
                viewCount: 0,
                planet_order: 2,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
                name: LanguageManager.current.string("Earth"),
                planetDescription: LanguageManager.current.string("EarthDescription"),
                viewCount: 0,
                planet_order: 3,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000009") ?? UUID(),
                name: LanguageManager.current.string("Moon"),
                planetDescription: LanguageManager.current.string("MoonDescription"),
                viewCount: 0,
                planet_order: 4,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
                name: LanguageManager.current.string("Mars"),
                planetDescription: LanguageManager.current.string("MarsDescription"),
                viewCount: 0,
                planet_order: 5,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
                name: LanguageManager.current.string("Jupiter"),
                planetDescription: LanguageManager.current.string("JupiterDescription"),
                viewCount: 0,
                planet_order: 6,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID(),
                name: LanguageManager.current.string("Saturn"),
                planetDescription: LanguageManager.current.string("SaturnDescription"),
                viewCount: 0,
                planet_order: 7,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000007") ?? UUID(),
                name: LanguageManager.current.string("Uranus"),
                planetDescription: LanguageManager.current.string("UranusDescription"),
                viewCount: 0,
                planet_order: 8,
                randomInfos: [],
                videoURLs: []
            ),
            PlanetModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000008") ?? UUID(),
                name: LanguageManager.current.string("Neptune"),
                planetDescription: LanguageManager.current.string("NeptuneDescription"),
                viewCount: 0,
                planet_order: 9,
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
    
    @MainActor
    class PlanetCommentViewModel: ObservableObject {
        @Published var comments: [PlanetComment] = []
        @Published var isLoading = false
        
        private var currentUserId: UUID?
        private var modelContext: ModelContext?
        
        func setup(userId: UUID, context: ModelContext) {
            self.currentUserId = userId
            self.modelContext = context
        }
        
        func loadComments(for planetId: UUID) {
            isLoading = true
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("Không tạo được connection")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            do {
                let stmt = try connection.prepareStatement(text: """
                    SELECT id, sender_id, content, created_at 
                    FROM planets_comments 
                    WHERE planets_id = $1 
                    ORDER BY created_at ASC
                """)

                let cursor = try stmt.execute(parameterValues: [planetId.uuidString])

                var list: [PlanetComment] = []
                for row in cursor {
                    let columns = try row.get().columns
                    let idStr = try columns[0].string()
                    let senderStr = try columns[1].string()
                    let content = try columns[2].string()
                    let createdStr = try columns[3].string()
                                        
                    guard let id = UUID(uuidString: idStr) else {
                        print("❌ Parse UUID id failed: \(idStr)")
                        continue
                    }
                    
                    guard let senderId = UUID(uuidString: senderStr) else {
                        print("❌ Parse UUID senderId failed: \(senderStr)")
                        continue
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    guard let createdAt = dateFormatter.date(from: createdStr) else {
                        print("❌ Parse date failed: \(createdStr)")
                        continue
                    }
                    
                    let comment = PlanetComment(
                        id: id,
                        planetId: planetId,
                        senderId: senderId,
                        content: content,
                        createdAt: createdAt
                    )
                    list.append(comment)
                }
                
                cursor.close()
                stmt.close()
                connection.close()
                
                
                DispatchQueue.main.async {
                    self.comments = list
                    self.isLoading = false
                }
                
            } catch {
                print("LỖI LOAD COMMENT: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        
        func sendComment(planetId: UUID, content: String) {
            guard let userId = currentUserId else { return }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let commentId = UUID()
                let now = ISO8601DateFormatter().string(from: Date())
                
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO planets_comments (id, planets_id, sender_id, content, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { stmt.close() }
                
                try stmt.execute(parameterValues: [
                    commentId.uuidString,
                    planetId.uuidString,
                    userId.uuidString,
                    trimmed,
                    now
                ])
                
                let newComment = PlanetComment(
                    id: commentId,
                    planetId: planetId,
                    senderId: userId,
                    content: trimmed
                )
                comments.append(newComment)
            } catch {
                print("Lỗi gửi comment: \(error)")
            }
        }
    }
}
