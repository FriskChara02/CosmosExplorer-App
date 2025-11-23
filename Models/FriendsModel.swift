//
//  FriendsModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData

// MARK: - Friend Request Status
enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

// MARK: - Friend Request Model
@Model
class FriendRequestModel: Identifiable {
    var id: UUID
    var senderId: UUID
    var receiverId: UUID
    var status: String // pending, accepted, rejected
    var createdAt: Date
    var updatedAt: Date
    
    var statusEnum: FriendRequestStatus {
        get { FriendRequestStatus(rawValue: status) ?? .pending }
        set { status = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        senderId: UUID,
        receiverId: UUID,
        status: String = "pending",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Friendship Model
@Model
class FriendshipModel: Identifiable {
    var id: UUID
    var userId1: UUID
    var userId2: UUID
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        userId1: UUID,
        userId2: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId1 = userId1
        self.userId2 = userId2
        self.createdAt = createdAt
    }
    
    func containsUser(_ userId: UUID) -> Bool {
        return userId1 == userId || userId2 == userId
    }
    
    func getFriendId(currentUserId: UUID) -> UUID? {
        if userId1 == currentUserId {
            return userId2
        } else if userId2 == currentUserId {
            return userId1
        }
        return nil
    }
}

struct FriendDisplayModel: Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let avatar: String?
    let status: String?
    let bio: String?
    let rank: Int
    let score: Int
    
    init(user: UserModel) {
        self.id = user.id
        self.userId = user.id
        self.username = user.username ?? "Unknown"
        self.avatar = user.avatar
        self.status = user.status
        self.bio = user.bio
        self.rank = user.rank
        self.score = user.score
    }
}
