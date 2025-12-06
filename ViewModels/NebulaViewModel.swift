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
    
    @MainActor
    class NebulaCommentViewModel: ObservableObject {
        @Published var comments: [NebulaComment] = []
        @Published var isLoading = false
        
        private var currentUserId: UUID?
        private var modelContext: ModelContext?
        
        func setup(userId: UUID, context: ModelContext) {
            self.currentUserId = userId
            self.modelContext = context
        }
        
        func loadComments(for nebulaId: UUID) {
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
                    FROM nebula_comments 
                    WHERE nebula_id = $1 
                    ORDER BY created_at ASC
                """)

                let cursor = try stmt.execute(parameterValues: [nebulaId.uuidString])

                var list: [NebulaComment] = []
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
                    
                    let comment = NebulaComment(
                        id: id,
                        nebulaId: nebulaId,
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
        
        func sendComment(nebulaId: UUID, content: String) {
            guard let userId = currentUserId else { return }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let commentId = UUID()
                let now = ISO8601DateFormatter().string(from: Date())
                
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO nebula_comments (id, nebula_id, sender_id, content, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { stmt.close() }
                
                try stmt.execute(parameterValues: [
                    commentId.uuidString,
                    nebulaId.uuidString,
                    userId.uuidString,
                    trimmed,
                    now
                ])
                
                let newComment = NebulaComment(
                    id: commentId,
                    nebulaId: nebulaId,
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
