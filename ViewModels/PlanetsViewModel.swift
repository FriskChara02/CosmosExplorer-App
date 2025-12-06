//
//  PlanetsViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 26/10/25.
//

import Foundation
import SwiftUI
import SwiftData
import PostgresClientKit

@MainActor
class PlanetsViewModel: ObservableObject {
    @Published var planets: [PlanetsModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredPlanets: [PlanetsModel] {
        let base = searchText.isEmpty
            ? planets
            : planets.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.planets_order < $1.planets_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(planets: PlanetsModel) {
        guard !planets.name.isEmpty else {
            print("⚠️ Skipping view count for invalid planet")
            return
        }
        
        if let index = self.planets.firstIndex(where: { $0.id == planets.id }) {
            self.planets[index].viewCount += 1
            swiftDataService.updatePlanets(self.planets[index])
            print("🔄 Updated view count for \(planets.name): \(self.planets[index].viewCount)")
        }
    }
    
    func toggleFavorite(planets: PlanetsModel) {
        if let index = self.planets.firstIndex(where: { $0.id == planets.id }) {
            self.planets[index].isFavorite.toggle()
            swiftDataService.updatePlanets(self.planets[index])
            print("❤️ Toggled favorite for \(planets.name): \(self.planets[index].isFavorite)")
        }
    }
    
    func addPlanets(_ planet: PlanetsModel) {
        if !planets.contains(where: { $0.id == planet.id }) {
            planets.append(planet)
            swiftDataService.savePlanets(planet)
            planets.sort { $0.planets_order < $1.planets_order }
            print("✅ Added new planet: \(planet.name)")
        } else {
            print("⚠️ Planet \(planet.name) already exists, skipping add")
        }
    }
    
    func loadPlanets() async {
        planets = swiftDataService.fetchPlanets()
        if planets.isEmpty {
            print("🪐 Creating sample planets as both SwiftData and PostgreSQL are empty")
            await createSamplePlanets()
        }
        planets.sort { $0.planets_order < $1.planets_order }
        print("✅ Loaded planets: \(planets.map { $0.name })")
    }
    
    func deletePlanets(_ planet: PlanetsModel) {
        guard planet.planets_order > 2 else {
            print("⚠️ Cannot delete hard-coded planet: \(planet.name)")
            return
        }
        
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            let planetToDelete = planets.remove(at: index)
            swiftDataService.deletePlanets(planetToDelete)
            print("🗑️ Deleted planet: \(planet.name)")
        }
    }
    
    func updatePlanets(_ planet: PlanetsModel) {
        if let index = planets.firstIndex(where: { $0.id == planet.id }) {
            planets[index].update(from: planet)
            swiftDataService.updatePlanets(planets[index])
            print("🔄 Updated planet: \(planet.name)")
        }
    }
    
    private func createSamplePlanets() async {
        let samplePlanets = [
            // Kepler-452b
            PlanetsModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Kepler-452b"),
                planetsDescription: LanguageManager.current.string("An Earth-like super-Earth."),
                viewCount: 0,
                isFavorite: false,
                planets_order: 0,
                randomInfos: [
                    LanguageManager.current.string("Kepler-452b Random Info 1"),
                    LanguageManager.current.string("Kepler-452b Random Info 2"),
                    LanguageManager.current.string("Kepler-452b Random Info 3"),
                    LanguageManager.current.string("Kepler-452b Random Info 4"),
                    LanguageManager.current.string("Kepler-452b Random Info 5")
                ],
                aboutDescription: LanguageManager.current.string("Kepler-452b About Description"),
                videoURLs: [
                    "https://www.youtube.com/embed/Nf-uqwm6-tY",
                    "https://www.youtube.com/embed/3Qgf0hzC1qs"
                ],
                radius: LanguageManager.current.string("Kepler-452b By The Numbers Radius"),
                distanceFromSun: LanguageManager.current.string("Kepler-452b By The Numbers Distance"),
                age: LanguageManager.current.string("Kepler-452b By The Numbers Age"),
                wikiLink: "https://en.wikipedia.org/wiki/Kepler-452b"
            ),
            
            // Proxima b
            PlanetsModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("Proxima b"),
                planetsDescription: LanguageManager.current.string("The closest known exoplanet to Earth."),
                viewCount: 0,
                isFavorite: false,
                planets_order: 1,
                randomInfos: [
                    LanguageManager.current.string("Proxima b Random Info 1"),
                    LanguageManager.current.string("Proxima b Random Info 2"),
                    LanguageManager.current.string("Proxima b Random Info 3"),
                    LanguageManager.current.string("Proxima b Random Info 4"),
                    LanguageManager.current.string("Proxima b Random Info 5")
                ],
                aboutDescription: LanguageManager.current.string("Proxima b About Description"),
                videoURLs: [],
                radius: LanguageManager.current.string("Proxima b By The Numbers Radius"),
                distanceFromSun: LanguageManager.current.string("Proxima b By The Numbers Distance"),
                age: LanguageManager.current.string("Proxima b By The Numbers Age"),
                wikiLink: "https://en.wikipedia.org/wiki/Proxima_Centauri_b"
            ),
            
            // 55 Cancri e
            PlanetsModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
                name: LanguageManager.current.string("55 Cancri e"),
                planetsDescription: LanguageManager.current.string("A scorching super-Earth with possible diamond layers."),
                viewCount: 0,
                isFavorite: false,
                planets_order: 2,
                randomInfos: [
                    LanguageManager.current.string("55 Cancri e Random Info 1"),
                    LanguageManager.current.string("55 Cancri e Random Info 2"),
                    LanguageManager.current.string("55 Cancri e Random Info 3"),
                    LanguageManager.current.string("55 Cancri e Random Info 4"),
                    LanguageManager.current.string("55 Cancri e Random Info 5")
                ],
                aboutDescription: LanguageManager.current.string("55 Cancri e About Description"),
                videoURLs: [],
                radius: LanguageManager.current.string("55 Cancri e By The Numbers Radius"),
                distanceFromSun: LanguageManager.current.string("55 Cancri e By The Numbers Distance"),
                age: LanguageManager.current.string("55 Cancri e By The Numbers Age"),
                wikiLink: "https://en.wikipedia.org/wiki/55_Cancri_e"
            )
        ]
        
        for planet in samplePlanets {
            if !planets.contains(where: { $0.id == planet.id }) {
                swiftDataService.savePlanets(planet)
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
    class PlanetsCommentViewModel: ObservableObject {
        @Published var comments: [PlanetsComment] = []
        @Published var isLoading = false
        
        private var currentUserId: UUID?
        private var modelContext: ModelContext?
        
        func setup(userId: UUID, context: ModelContext) {
            self.currentUserId = userId
            self.modelContext = context
        }
        
        func loadComments(for planetsId: UUID) {
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
                    FROM planetss_comments 
                    WHERE planetss_id = $1 
                    ORDER BY created_at ASC
                """)

                let cursor = try stmt.execute(parameterValues: [planetsId.uuidString])

                var list: [PlanetsComment] = []
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
                    
                    let comment = PlanetsComment(
                        id: id,
                        planetsId: planetsId,
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
        
        func sendComment(planetsId: UUID, content: String) {
            guard let userId = currentUserId else { return }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let commentId = UUID()
                let now = ISO8601DateFormatter().string(from: Date())
                
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO planetss_comments (id, planetss_id, sender_id, content, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { stmt.close() }
                
                try stmt.execute(parameterValues: [
                    commentId.uuidString,
                    planetsId.uuidString,
                    userId.uuidString,
                    trimmed,
                    now
                ])
                
                let newComment = PlanetsComment(
                    id: commentId,
                    planetsId: planetsId,
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
