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

    @MainActor
    class GalaxyCommentViewModel: ObservableObject {
        @Published var comments: [GalaxyComment] = []
        @Published var isLoading = false
        
        private var currentUserId: UUID?
        private var modelContext: ModelContext?
        
        func setup(userId: UUID, context: ModelContext) {
            self.currentUserId = userId
            self.modelContext = context
        }
        
        func loadComments(for galaxyId: UUID) {
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
                    FROM galaxy_comments 
                    WHERE galaxy_id = $1 
                    ORDER BY created_at ASC
                """)

                let cursor = try stmt.execute(parameterValues: [galaxyId.uuidString])

                var list: [GalaxyComment] = []
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
                    
                    let comment = GalaxyComment(
                        id: id,
                        galaxyId: galaxyId,
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
        
        func sendComment(galaxyId: UUID, content: String) {
            guard let userId = currentUserId else { return }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let commentId = UUID()
                let now = ISO8601DateFormatter().string(from: Date())
                
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO galaxy_comments (id, galaxy_id, sender_id, content, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { stmt.close() }
                
                try stmt.execute(parameterValues: [
                    commentId.uuidString,
                    galaxyId.uuidString,
                    userId.uuidString,
                    trimmed,
                    now
                ])
                
                let newComment = GalaxyComment(
                    id: commentId,
                    galaxyId: galaxyId,
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
