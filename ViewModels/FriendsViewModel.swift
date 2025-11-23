//
//  FriendsViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData
import PostgresClientKit
import Combine

class FriendsViewModel: ObservableObject {
    @Published var friends: [FriendDisplayModel] = []
    @Published var friendRequests: [FriendDisplayModel] = []
    @Published var sentRequests: [FriendDisplayModel] = []
    @Published var suggestedUsers: [FriendDisplayModel] = []
    @Published var searchResults: [FriendDisplayModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var modelContext: ModelContext?
    private var currentUserId: UUID?
    
    func setCurrentUser(_ userId: UUID, context: ModelContext) {
        self.currentUserId = userId
        self.modelContext = context
        loadAllData()
    }
    
    func loadAllData() {
        guard let userId = currentUserId else { return }
        loadFriends(userId: userId)
        loadFriendRequests(userId: userId)
        loadSentRequests(userId: userId)
        loadSuggestedUsers(userId: userId)
    }
    
    // MARK: - Load Friends
    func loadFriends(userId: UUID) {
        isLoading = true
        guard let connection = try? DatabaseConfig.createConnection() else {
            errorMessage = "Không thể kết nối database"
            isLoading = false
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT u.id, u.username, u.avatar, u.status, u.bio, u.rank, u.score
                FROM users u
                INNER JOIN friendships f ON (f.user_id1 = $1 AND f.user_id2 = u.id)
                                         OR (f.user_id2 = $1 AND f.user_id1 = u.id)
                ORDER BY u.username ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var friendsList: [FriendDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let friendId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    
                    let user = UserModel(
                        id: friendId,
                        email: "",
                        username: username,
                        password: "",
                        avatar: avatar,
                        bio: bio,
                        rank: rank,
                        score: score,
                        status: status
                    )
                    friendsList.append(FriendDisplayModel(user: user))
                }
            }
            
            DispatchQueue.main.async {
                self.friends = friendsList
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Lỗi load bạn bè: \(error)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Load Friend Requests
    func loadFriendRequests(userId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT u.id, u.username, u.avatar, u.status, u.bio, u.rank, u.score
                FROM users u
                INNER JOIN friend_requests fr ON fr.sender_id = u.id
                WHERE fr.receiver_id = $1 AND fr.status = 'pending'
                ORDER BY fr.created_at DESC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var requestsList: [FriendDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let senderId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    
                    let user = UserModel(
                        id: senderId,
                        email: "",
                        username: username,
                        password: "",
                        avatar: avatar,
                        bio: bio,
                        rank: rank,
                        score: score,
                        status: status
                    )
                    requestsList.append(FriendDisplayModel(user: user))
                }
            }
            
            DispatchQueue.main.async {
                self.friendRequests = requestsList
            }
        } catch {
            print("❌ Error loading friend requests: \(error)")
        }
    }
    
    // MARK: - Load Sent Requests
    func loadSentRequests(userId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT u.id, u.username, u.avatar, u.status, u.bio, u.rank, u.score
                FROM users u
                INNER JOIN friend_requests fr ON fr.receiver_id = u.id
                WHERE fr.sender_id = $1 AND fr.status = 'pending'
                ORDER BY fr.created_at DESC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var sentList: [FriendDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let receiverId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    
                    let user = UserModel(
                        id: receiverId,
                        email: "",
                        username: username,
                        password: "",
                        avatar: avatar,
                        bio: bio,
                        rank: rank,
                        score: score,
                        status: status
                    )
                    sentList.append(FriendDisplayModel(user: user))
                }
            }
            
            DispatchQueue.main.async {
                self.sentRequests = sentList
            }
        } catch {
            print("❌ Error loading sent requests: \(error)")
        }
    }
    
    // MARK: - Load Suggested Users
    func loadSuggestedUsers(userId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, username, avatar, status, bio, rank, score
                FROM users
                WHERE id != $1
                AND id NOT IN (
                    SELECT user_id2 FROM friendships WHERE user_id1 = $1
                    UNION
                    SELECT user_id1 FROM friendships WHERE user_id2 = $1
                )
                AND id NOT IN (
                    SELECT receiver_id FROM friend_requests WHERE sender_id = $1
                    UNION
                    SELECT sender_id FROM friend_requests WHERE receiver_id = $1
                )
                ORDER BY RANDOM()
                LIMIT 10
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var suggestedList: [FriendDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let suggestedId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    
                    let user = UserModel(
                        id: suggestedId,
                        email: "",
                        username: username,
                        password: "",
                        avatar: avatar,
                        bio: bio,
                        rank: rank,
                        score: score,
                        status: status
                    )
                    suggestedList.append(FriendDisplayModel(user: user))
                }
            }
            
            DispatchQueue.main.async {
                self.suggestedUsers = suggestedList
            }
        } catch {
            print("❌ Error loading suggested users: \(error)")
        }
    }
    
    // MARK: - Send Friend Request
    func sendFriendRequest(to receiverId: UUID, completion: @escaping (Bool) -> Void) {
        guard let senderId = currentUserId else {
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let requestId = UUID()
            let statement = try connection.prepareStatement(text: """
                INSERT INTO friend_requests (id, sender_id, receiver_id, status, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6)
            """)
            defer { statement.close() }
            
            let now = ISO8601DateFormatter().string(from: Date())
            try statement.execute(parameterValues: [
                requestId.uuidString,
                senderId.uuidString,
                receiverId.uuidString,
                "pending",
                now,
                now
            ])
            
            DispatchQueue.main.async {
                self.loadSentRequests(userId: senderId)
                self.loadSuggestedUsers(userId: senderId)
                completion(true)
            }
        } catch {
            print("❌ Error sending friend request: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Accept Friend Request
    func acceptFriendRequest(from senderId: UUID, completion: @escaping (Bool) -> Void) {
        guard let receiverId = currentUserId else {
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let updateStmt = try connection.prepareStatement(text: """
                UPDATE friend_requests
                SET status = 'accepted', updated_at = $1
                WHERE sender_id = $2 AND receiver_id = $3
            """)
            defer { updateStmt.close() }
            try updateStmt.execute(parameterValues: [
                ISO8601DateFormatter().string(from: Date()),
                senderId.uuidString,
                receiverId.uuidString
            ])
            
            let friendshipId = UUID()
            let insertStmt = try connection.prepareStatement(text: """
                INSERT INTO friendships (id, user_id1, user_id2, created_at)
                VALUES ($1, $2, $3, $4)
            """)
            defer { insertStmt.close() }
            try insertStmt.execute(parameterValues: [
                friendshipId.uuidString,
                receiverId.uuidString,
                senderId.uuidString,
                ISO8601DateFormatter().string(from: Date())
            ])
            
            let chatId = UUID()
            let now = ISO8601DateFormatter().string(from: Date())
            let createChatStmt = try connection.prepareStatement(text: """
                INSERT INTO chats (id, participant1_id, participant2_id, created_at, updated_at, quick_reaction_emoji)
                VALUES ($1, $2, $3, $4, $5, $6)
            """)
            try createChatStmt.execute(parameterValues: [
                chatId.uuidString,
                receiverId.uuidString,
                senderId.uuidString,
                now, now, "Thumbs Up"
            ])
            
            DispatchQueue.main.async {
                self.loadFriends(userId: receiverId)
                self.loadFriendRequests(userId: receiverId)
                
                NotificationCenter.default.post(name: NSNotification.Name("FriendAcceptedReloadChats"), object: nil)
                
                completion(true)
            }
        } catch {
            print("❌ Error accepting friend request: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Reject Friend Request
    func rejectFriendRequest(from senderId: UUID, completion: @escaping (Bool) -> Void) {
        guard let receiverId = currentUserId else {
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE friend_requests
                SET status = 'rejected', updated_at = $1
                WHERE sender_id = $2 AND receiver_id = $3
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [
                ISO8601DateFormatter().string(from: Date()),
                senderId.uuidString,
                receiverId.uuidString
            ])
            
            DispatchQueue.main.async {
                self.loadFriendRequests(userId: receiverId)
                completion(true)
            }
        } catch {
            print("❌ Error rejecting friend request: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Search Users
    func searchUsers(query: String, userId: UUID) {
        guard !query.isEmpty else {
            DispatchQueue.main.async {
                self.searchResults = []
            }
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, username, avatar, status, bio, rank, score
                FROM users
                WHERE id != $1 AND username ILIKE $2
                ORDER BY username ASC
                LIMIT 20
            """)
            defer { statement.close() }
            
            let searchPattern = "%\(query)%"
            let cursor = try statement.execute(parameterValues: [userId.uuidString, searchPattern])
            defer { cursor.close() }
            
            var results: [FriendDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let foundId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    
                    let user = UserModel(
                        id: foundId,
                        email: "",
                        username: username,
                        password: "",
                        avatar: avatar,
                        bio: bio,
                        rank: rank,
                        score: score,
                        status: status
                    )
                    results.append(FriendDisplayModel(user: user))
                }
            }
            
            DispatchQueue.main.async {
                self.searchResults = results
            }
        } catch {
            print("❌ Error searching users: \(error)")
        }
    }
}
