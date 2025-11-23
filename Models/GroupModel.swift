//
//  GroupModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData

// MARK: Group Model
@Model
final class GroupModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var avatar: String?
    var createdAt: Date
    var updatedAt: Date
    var createdBy: UUID
    var lastMessageContent: String?
    var lastMessageTime: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        avatar: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        createdBy: UUID,
        lastMessageContent: String? = nil,
        lastMessageTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.avatar = avatar
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.lastMessageContent = lastMessageContent
        self.lastMessageTime = lastMessageTime
    }
}

// MARK: - Group Member
@Model
final class GroupMemberModel {
    @Attribute(.unique) var id: UUID
    var groupId: UUID
    var userId: UUID
    var role: String // "admin", "member"
    var joinedAt: Date
    
    init(id: UUID = UUID(), groupId: UUID, userId: UUID, role: String = "member", joinedAt: Date = Date()) {
        self.id = id
        self.groupId = groupId
        self.userId = userId
        self.role = role
        self.joinedAt = joinedAt
    }
}

// MARK: - Group Message
@Model
final class GroupMessageModel {
    @Attribute(.unique) var id: UUID
    var groupId: UUID
    var senderId: UUID
    var content: String
    var messageType: String
    var reactions: String?
    var createdAt: Date
    var replyToMessageId: UUID?
    
    init(
        id: UUID = UUID(),
        groupId: UUID,
        senderId: UUID,
        content: String,
        messageType: MessageType = .text,
        reactions: String? = nil,
        createdAt: Date = Date(),
        replyToMessageId: UUID? = nil
    ) {
        self.id = id
        self.groupId = groupId
        self.senderId = senderId
        self.content = content
        self.messageType = messageType.rawValue
        self.reactions = reactions
        self.createdAt = createdAt
        self.replyToMessageId = replyToMessageId
    }
}

// MARK: - Group Word Filter
@Model
final class GroupWordFilterModel {
    @Attribute(.unique) var id: UUID
    var groupId: UUID
    var bannedWord: String
    var replacement: String?
    var createdAt: Date
    
    init(id: UUID = UUID(), groupId: UUID, bannedWord: String, replacement: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.groupId = groupId
        self.bannedWord = bannedWord
        self.replacement = replacement
        self.createdAt = createdAt
    }
}

struct GroupDisplayModel: Identifiable {
    let id: UUID
    let group: GroupModel
    let memberCount: Int
    let isAdmin: Bool
    
    var title: String { group.title }
    var avatar: String? { group.avatar }
    var lastMessage: String { group.lastMessageContent ?? "Chưa có tin nhắn" }
    var lastTime: Date? { group.lastMessageTime }
}

struct GroupMemberDisplayModel: Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let avatar: String?
    let status: String?
    let bio: String?
    let rank: Int
    let score: Int
    let role: String // "admin" | "member"
    
    var isAdmin: Bool { role == "admin" }
}
