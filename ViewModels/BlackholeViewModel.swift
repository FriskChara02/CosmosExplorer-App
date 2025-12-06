//
//  BlackholeViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 18/10/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class BlackholeViewModel: ObservableObject {
    @Published var blackholes: [BlackholeModel] = []
    @Published var searchText: String = ""
    private var modelContext: ModelContext?
    private let swiftDataService = SwiftDataService()
    
    var filteredBlackholes: [BlackholeModel] {
        let base = searchText.isEmpty
            ? blackholes
            : blackholes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        return base.sorted {
            $0.isFavorite == $1.isFavorite
                ? $0.blackhole_order < $1.blackhole_order
                : $0.isFavorite && !$1.isFavorite
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func incrementViewCount(blackhole: BlackholeModel) {
        guard !blackhole.name.isEmpty else {
            print("⚠️ Skipping view count for invalid blackhole")
            return
        }
        
        if let index = blackholes.firstIndex(where: { $0.id == blackhole.id }) {
            blackholes[index].viewCount += 1
            swiftDataService.updateBlackhole(blackholes[index])
            print("🔄 Updated view count for \(blackhole.name): \(blackholes[index].viewCount)")
        }
    }
    
    func toggleFavorite(blackhole: BlackholeModel) {
        if let index = blackholes.firstIndex(where: { $0.id == blackhole.id }) {
            blackholes[index].isFavorite.toggle()
            swiftDataService.updateBlackhole(blackholes[index])
            print("❤️ Toggled favorite for \(blackhole.name): \(blackholes[index].isFavorite)")
        }
    }
    
    func addBlackhole(_ blackhole: BlackholeModel) {
        if !blackholes.contains(where: { $0.id == blackhole.id }) {
            blackholes.append(blackhole)
            swiftDataService.saveBlackhole(blackhole)
            blackholes.sort { $0.blackhole_order < $1.blackhole_order }
            print("✅ Added new blackhole: \(blackhole.name)")
        } else {
            print("⚠️ Blackhole \(blackhole.name) already exists, skipping add")
        }
    }
    
    func loadBlackholes() async {
        blackholes = swiftDataService.fetchBlackholes()
        if blackholes.isEmpty {
            print("🌌 Creating sample blackholes as both SwiftData and PostgreSQL are empty")
            await createSampleBlackholes()
        }
        blackholes.sort { $0.blackhole_order < $1.blackhole_order }
        print("✅ Loaded blackholes: \(blackholes.map { $0.name })")
    }
    
    func deleteBlackhole(_ blackhole: BlackholeModel) {
        guard blackhole.blackhole_order > 2 else {
            print("⚠️ Cannot delete hard-coded blackhole: \(blackhole.name)")
            return
        }
        
        if let index = blackholes.firstIndex(where: { $0.id == blackhole.id }) {
            let blackholeToDelete = blackholes.remove(at: index)
            swiftDataService.deleteBlackhole(blackholeToDelete)
            print("🗑️ Deleted blackhole: \(blackhole.name)")
        }
    }
    
    func updateBlackhole(_ blackhole: BlackholeModel) {
        if let index = blackholes.firstIndex(where: { $0.id == blackhole.id }) {
            blackholes[index].update(from: blackhole)
            swiftDataService.updateBlackhole(blackholes[index])
            print("🔄 Updated blackhole: \(blackhole.name)")
        }
    }
    
    private func createSampleBlackholes() async {
        let sampleBlackholes = [
            BlackholeModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
                name: LanguageManager.current.string("Sagittarius A"),
                blackholeDescription: LanguageManager.current.string("SagittariusADescription"),
                viewCount: 0,
                blackhole_order: 0,
                randomInfos: [],
                aboutDescription: LanguageManager.current.string("Sagittarius A About Description"),
                videoURLs: [],
                radius: "~24 million km",
                distanceFromSun: "~26,000 light-years",
                age: "~Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/Sagittarius_A*"
            ),
            BlackholeModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                name: LanguageManager.current.string("TON 618"),
                blackholeDescription: LanguageManager.current.string("TON618Description"),
                viewCount: 0,
                blackhole_order: 1,
                randomInfos: [],
                videoURLs: [],
                radius: "~1,300 AU",
                distanceFromSun: "~10.4 billion light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/TON_618"
            ),
            BlackholeModel(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                name: LanguageManager.current.string("M87"),
                blackholeDescription: LanguageManager.current.string("M87Description"),
                viewCount: 0,
                blackhole_order: 2,
                randomInfos: [],
                videoURLs: [],
                radius: "~38 billion km",
                distanceFromSun: "~53 million light-years",
                age: "Unknown",
                wikiLink: "https://en.wikipedia.org/wiki/Messier_87"
            )
        ]
        
        for blackhole in sampleBlackholes {
            if !blackholes.contains(where: { $0.id == blackhole.id }) {
                swiftDataService.saveBlackhole(blackhole)
                if let context = modelContext {
                    context.insert(blackhole)
                    do {
                        try context.save()
                        print("💾 Saved sample blackhole: \(blackhole.name)")
                    } catch {
                        print("❌ Error saving sample blackhole \(blackhole.name): \(error)")
                    }
                }
                blackholes.append(blackhole)
            }
        }
    }
    
    @MainActor
    class BlackholeCommentViewModel: ObservableObject {
        @Published var comments: [BlackholeComment] = []
        @Published var isLoading = false
        
        private var currentUserId: UUID?
        private var modelContext: ModelContext?
        
        func setup(userId: UUID, context: ModelContext) {
            self.currentUserId = userId
            self.modelContext = context
        }
        
        func loadComments(for blackholeId: UUID) {
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
                    FROM blackhole_comments 
                    WHERE blackhole_id = $1 
                    ORDER BY created_at ASC
                """)

                let cursor = try stmt.execute(parameterValues: [blackholeId.uuidString])

                var list: [BlackholeComment] = []
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
                    
                    let comment = BlackholeComment(
                        id: id,
                        blackholeId: blackholeId,
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
        
        func sendComment(blackholeId: UUID, content: String) {
            guard let userId = currentUserId else { return }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let commentId = UUID()
                let now = ISO8601DateFormatter().string(from: Date())
                
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO blackhole_comments (id, blackhole_id, sender_id, content, created_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { stmt.close() }
                
                try stmt.execute(parameterValues: [
                    commentId.uuidString,
                    blackholeId.uuidString,
                    userId.uuidString,
                    trimmed,
                    now
                ])
                
                let newComment = BlackholeComment(
                    id: commentId,
                    blackholeId: blackholeId,
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
