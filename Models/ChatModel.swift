//
//  ChatModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData

// MARK: - Message Type
enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case emoji = "emoji"
}

// MARK: - Chat Model
@Model
final class ChatModel {
    @Attribute(.unique) var id: UUID
    var participant1Id: UUID
    var participant2Id: UUID
    var createdAt: Date
    var updatedAt: Date
    var lastMessageContent: String?
    var lastMessageTime: Date?
    var isBlocked: Bool = false
    var blockedBy: UUID?
    var customNickname1: String?
    var customNickname2: String?
    var themeColor: String?
    var quickReactionEmoji: String?
    var backgroundName: String?
    
    init(
        id: UUID = UUID(),
        participant1Id: UUID,
        participant2Id: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastMessageContent: String? = nil,
        lastMessageTime: Date? = nil,
        isBlocked: Bool = false,
        blockedBy: UUID? = nil,
        customNickname1: String? = nil,
        customNickname2: String? = nil,
        themeColor: String? = nil,
        quickReactionEmoji: String? = nil,
        backgroundName: String? = nil
    ) {
        self.id = id
        self.participant1Id = participant1Id
        self.participant2Id = participant2Id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessageContent = lastMessageContent
        self.lastMessageTime = lastMessageTime
        self.isBlocked = isBlocked
        self.blockedBy = blockedBy
        self.customNickname1 = customNickname1
        self.customNickname2 = customNickname2
        self.themeColor = themeColor
        self.quickReactionEmoji = quickReactionEmoji
        self.backgroundName = backgroundName
    }
    
    func getOtherUserId(currentUserId: UUID) -> UUID {
        return participant1Id == currentUserId ? participant2Id : participant1Id
    }
    
    func getDisplayName(for userId: UUID, otherUser: UserModel) -> String {
        if participant1Id == userId {
            return customNickname2 ?? otherUser.username ?? "Unknown"
        } else {
            return customNickname1 ?? otherUser.username ?? "Unknown"
        }
    }
}

// MARK: - Message Model
@Model
final class MessageModel {
    @Attribute(.unique) var id: UUID
    var chatId: UUID
    var senderId: UUID
    var content: String
    var messageType: String
    var reactions: String?
    var createdAt: Date
    var isRead: Bool = false
    var replyToMessageId: UUID?
    
    init(
        id: UUID = UUID(),
        chatId: UUID,
        senderId: UUID,
        content: String,
        messageType: MessageType = .text,
        reactions: String? = nil,
        createdAt: Date = Date(),
        isRead: Bool = false,
        replyToMessageId: UUID? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.content = content
        self.messageType = messageType.rawValue
        self.reactions = reactions
        self.createdAt = createdAt
        self.isRead = isRead
        self.replyToMessageId = replyToMessageId
    }
}

struct ChatDisplayModel: Identifiable {
    let id: UUID
    let chat: ChatModel
    let otherUser: UserModel
    let currentUserId: UUID
    
    var displayName: String {
        chat.getDisplayName(for: currentUserId, otherUser: otherUser)
    }
    
    var avatar: String? {
        otherUser.avatar
    }
    
    var lastMessage: String {
        chat.lastMessageContent ?? "Bắt đầu trò chuyện nào!"
    }
    
    var lastTime: Date? {
        chat.lastMessageTime
    }
    
    var isBlocked: Bool {
        chat.isBlocked
    }
}

