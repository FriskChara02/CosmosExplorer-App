//
//  ChatsViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData
import PostgresClientKit
import Combine

class ChatsViewModel: ObservableObject {
    @Published var chats: [ChatDisplayModel] = []
    @Published var messages: [MessageModel] = []
    @Published var currentChat: ChatModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var modelContext: ModelContext?
    private var currentUserId: UUID?
    
    func setCurrentUser(_ userId: UUID, context: ModelContext) {
        self.currentUserId = userId
        self.modelContext = context
        loadChats(userId: userId)
    }
    
    func loadChats(userId: UUID) {
        isLoading = true
        guard let connection = try? DatabaseConfig.createConnection() else {
            errorMessage = "Không thể kết nối database"
            isLoading = false
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT c.id, c.participant1_id, c.participant2_id, c.last_message_content,
                       c.last_message_time, c.is_blocked, c.custom_nickname1, c.custom_nickname2,
                       c.theme_color, c.quick_reaction_emoji, c.background_name,
                       u.id, u.username, u.avatar
                FROM chats c
                INNER JOIN users u ON (
                    (c.participant1_id = $1 AND u.id = c.participant2_id) OR
                    (c.participant2_id = $1 AND u.id = c.participant1_id)
                )
                WHERE c.participant1_id = $1 OR c.participant2_id = $1
                ORDER BY c.last_message_time DESC NULLS LAST
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var chatsList: [ChatDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let chatId = UUID(uuidString: try row.columns[0].string()),
                   let part1 = UUID(uuidString: try row.columns[1].string()),
                   let part2 = UUID(uuidString: try row.columns[2].string()),
                   let otherId = UUID(uuidString: try row.columns[11].string()),
                   let otherUsername = try? row.columns[12].string() {
                    
                    let lastMessage = try? row.columns[3].string()
                    let lastTimeStr = try? row.columns[4].string()
                    let lastTime = lastTimeStr.flatMap { ISO8601DateFormatter().date(from: $0) }
                    let isBlocked = (try? row.columns[5].bool()) ?? false
                    let nick1 = try? row.columns[6].string()
                    let nick2 = try? row.columns[7].string()
                    let themeColor = try? row.columns[8].string()
                    let quickEmoji = try? row.columns[9].string()
                    let otherAvatar = try? row.columns[13].string()
                    let background = try? row.columns[10].string()
                    
                    let chat = ChatModel(
                        id: chatId,
                        participant1Id: part1,
                        participant2Id: part2,
                        lastMessageContent: lastMessage,
                        lastMessageTime: lastTime,
                        isBlocked: isBlocked,
                        customNickname1: nick1,
                        customNickname2: nick2,
                        themeColor: themeColor,
                        quickReactionEmoji: quickEmoji,
                        backgroundName: background
                    )
                    
                    let otherUser = UserModel(
                        id: otherId,
                        email: "",
                        username: otherUsername,
                        password: "",
                        avatar: otherAvatar
                    )
                    
                    let displayChat = ChatDisplayModel(
                        id: otherId,
                        chat: chat,
                        otherUser: otherUser,
                        currentUserId: userId
                    )
                    chatsList.append(displayChat)
                }
            }
            
            DispatchQueue.main.async {
                self.chats = chatsList
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Lỗi load chats: \(error)"
                self.isLoading = false
            }
        }
    }
    
    func getOrCreateChat(withUserId otherUserId: UUID, completion: @escaping (ChatModel?) -> Void) {
        guard let currentUserId = currentUserId else {
            completion(nil)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(nil)
            return
        }
        defer { connection.close() }
        
        do {
            let checkStmt = try connection.prepareStatement(text: """
                SELECT id, participant1_id, participant2_id, created_at, updated_at,
                       last_message_content, last_message_time, is_blocked, blocked_by,
                       custom_nickname1, custom_nickname2, theme_color, quick_reaction_emoji, background_name
                FROM chats
                WHERE (participant1_id = $1 AND participant2_id = $2)
                   OR (participant1_id = $2 AND participant2_id = $1)
            """)
            defer { checkStmt.close() }
            
            let cursor = try checkStmt.execute(parameterValues: [
                currentUserId.uuidString,
                otherUserId.uuidString
            ])
            defer { cursor.close() }
            
            if let row = try cursor.next()?.get(),
               let chatId = UUID(uuidString: try row.columns[0].string()),
               let part1 = UUID(uuidString: try row.columns[1].string()),
               let part2 = UUID(uuidString: try row.columns[2].string()) {
                
                let createdStr = try row.columns[3].string()
                let updatedStr = try row.columns[4].string()
                let created = ISO8601DateFormatter().date(from: createdStr) ?? Date()
                let updated = ISO8601DateFormatter().date(from: updatedStr) ?? Date()
                let lastMsg = try? row.columns[5].string()
                let lastTimeStr = try? row.columns[6].string()
                let lastTime = lastTimeStr.flatMap { ISO8601DateFormatter().date(from: $0) }
                let isBlocked = (try? row.columns[7].bool()) ?? false
                let blockedByStr = try? row.columns[8].string()
                let blockedBy = blockedByStr.flatMap { UUID(uuidString: $0) }
                let nick1 = try? row.columns[9].string()
                let nick2 = try? row.columns[10].string()
                let theme = try? row.columns[11].string()
                let emoji = try? row.columns[12].string()
                let background = try? row.columns[13].string()
                
                let chat = ChatModel(
                    id: chatId,
                    participant1Id: part1,
                    participant2Id: part2,
                    createdAt: created,
                    updatedAt: updated,
                    lastMessageContent: lastMsg,
                    lastMessageTime: lastTime,
                    isBlocked: isBlocked,
                    blockedBy: blockedBy,
                    customNickname1: nick1,
                    customNickname2: nick2,
                    themeColor: theme,
                    quickReactionEmoji: emoji,
                    backgroundName: background
                )
                completion(chat)
                return
            }
            
            let newChatId = UUID()
            let insertStmt = try connection.prepareStatement(text: """
                INSERT INTO chats (id, participant1_id, participant2_id, created_at, updated_at,
                                 is_blocked, quick_reaction_emoji)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
            """)
            defer { insertStmt.close() }
            
            let now = ISO8601DateFormatter().string(from: Date())
            try insertStmt.execute(parameterValues: [
                newChatId.uuidString,
                currentUserId.uuidString,
                otherUserId.uuidString,
                now,
                now,
                false,
                "👍"
            ])
            
            let newChat = ChatModel(
                id: newChatId,
                participant1Id: currentUserId,
                participant2Id: otherUserId,
                createdAt: Date(),
                updatedAt: Date(),
                backgroundName: nil
            )
            completion(newChat)
            
        } catch {
            print("❌ Error getting/creating chat: \(error)")
            completion(nil)
        }
    }
    
    func loadMessages(chatId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, chat_id, sender_id, content, message_type, reactions,
                       created_at, is_read, reply_to_message_id
                FROM messages
                WHERE chat_id = $1
                ORDER BY created_at ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [chatId.uuidString])
            defer { cursor.close() }
            
            var messagesList: [MessageModel] = []
            while let row = try cursor.next()?.get() {
                if let msgId = UUID(uuidString: try row.columns[0].string()),
                   let chatIdVal = UUID(uuidString: try row.columns[1].string()),
                   let senderId = UUID(uuidString: try row.columns[2].string()),
                   let content = try? row.columns[3].string() {
                    
                    let msgType = (try? row.columns[4].string()) ?? "text"
                    let reactions = try? row.columns[5].string()
                    let createdStr = try row.columns[6].string()
                    let created = ISO8601DateFormatter().date(from: createdStr) ?? Date()
                    let isRead = (try? row.columns[7].bool()) ?? false
                    let replyToStr = try? row.columns[8].string()
                    let replyTo = replyToStr.flatMap { UUID(uuidString: $0) }
                    
                    let message = MessageModel(
                        id: msgId,
                        chatId: chatIdVal,
                        senderId: senderId,
                        content: content,
                        messageType: MessageType(rawValue: msgType) ?? .text,
                        reactions: reactions,
                        createdAt: created,
                        isRead: isRead,
                        replyToMessageId: replyTo
                    )
                    messagesList.append(message)
                }
            }
            
            DispatchQueue.main.async {
                self.messages = messagesList
            }
        } catch {
            print("❌ Error loading messages: \(error)")
        }
    }
    
    func sendMessage(chatId: UUID, content: String, type: MessageType = .text, completion: @escaping (Bool) -> Void) {
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
            let messageId = UUID()
            let now = Date()
            let nowStr = ISO8601DateFormatter().string(from: now)
            
            let msgStmt = try connection.prepareStatement(text: """
                INSERT INTO messages (id, chat_id, sender_id, content, message_type, created_at, is_read)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
            """)
            defer { msgStmt.close() }
            try msgStmt.execute(parameterValues: [
                messageId.uuidString,
                chatId.uuidString,
                senderId.uuidString,
                content,
                type.rawValue,
                nowStr,
                false
            ])
            
            let updateStmt = try connection.prepareStatement(text: """
                UPDATE chats
                SET last_message_content = $1, last_message_time = $2, updated_at = $3
                WHERE id = $4
            """)
            defer { updateStmt.close() }
            try updateStmt.execute(parameterValues: [content, nowStr, nowStr, chatId.uuidString])
            
            DispatchQueue.main.async {
                self.loadMessages(chatId: chatId)
                if let userId = self.currentUserId {
                    self.loadChats(userId: userId)
                }
                completion(true)
            }
        } catch {
            print("❌ Error sending message: \(error)")
            completion(false)
        }
    }
    
    func updateChatSettings(
        chatId: UUID,
        nickname: String? = nil,
        themeColor: String? = nil,
        backgroundName: String? = nil,
        quickEmoji: String? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let getStmt = try connection.prepareStatement(text: """
                SELECT participant1_id, participant2_id FROM chats WHERE id = $1
            """)
            defer { getStmt.close() }
            
            let cursor = try getStmt.execute(parameterValues: [chatId.uuidString])
            defer { cursor.close() }
            
            guard let row = try cursor.next()?.get(),
                  let participant1Id = UUID(uuidString: try row.columns[0].string()),
                  let _ = UUID(uuidString: try row.columns[1].string()) else {
                completion(false)
                return
            }

            let isParticipant1 = (participant1Id == userId)
            let nicknameField = isParticipant1 ? "custom_nickname2" : "custom_nickname1"
            
            var updates: [String] = []
            var values: [PostgresValueConvertible] = []
            var paramIndex = 1
            
            if let nick = nickname {
                updates.append("\(nicknameField) = $\(paramIndex)")
                values.append(nick)
                paramIndex += 1
            }
            
            if let theme = themeColor {
                updates.append("theme_color = $\(paramIndex)")
                values.append(theme)
                paramIndex += 1
            }
            
            if let bg = backgroundName {
                    updates.append("background_name = $\(paramIndex)")
                    values.append(bg)
                    paramIndex += 1
            }
            
            if let emoji = quickEmoji {
                updates.append("quick_reaction_emoji = $\(paramIndex)")
                values.append(emoji)
                paramIndex += 1
            }
            
            guard !updates.isEmpty else {
                completion(true)
                return
            }
            
            let updateQuery = "UPDATE chats SET \(updates.joined(separator: ", ")), updated_at = $\(paramIndex) WHERE id = $\(paramIndex + 1)"
            values.append(ISO8601DateFormatter().string(from: Date()))
            values.append(chatId.uuidString)
            
            let updateStmt = try connection.prepareStatement(text: updateQuery)
            defer { updateStmt.close() }
            try updateStmt.execute(parameterValues: values)
            
            DispatchQueue.main.async {
                self.loadChats(userId: userId)
                completion(true)
            }
        } catch {
            print("❌ Error updating chat settings: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Block User
    func blockUser(chatId: UUID, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
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
                UPDATE chats
                SET is_blocked = true, blocked_by = $1, updated_at = $2
                WHERE id = $3
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [
                userId.uuidString,
                ISO8601DateFormatter().string(from: Date()),
                chatId.uuidString
            ])
            
            DispatchQueue.main.async {
                self.loadChats(userId: userId)
                completion(true)
            }
        } catch {
            print("❌ Error blocking user: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Delete Chat
    func deleteChat(chatId: UUID, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let delMsgStmt = try connection.prepareStatement(text: "DELETE FROM messages WHERE chat_id = $1")
            defer { delMsgStmt.close() }
            try delMsgStmt.execute(parameterValues: [chatId.uuidString])
            
            let delChatStmt = try connection.prepareStatement(text: "DELETE FROM chats WHERE id = $1")
            defer { delChatStmt.close() }
            try delChatStmt.execute(parameterValues: [chatId.uuidString])
            
            DispatchQueue.main.async {
                self.loadChats(userId: userId)
                completion(true)
            }
        } catch {
            print("❌ Error deleting chat: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Search Messages
    func searchMessages(chatId: UUID, query: String) -> [MessageModel] {
        guard !query.isEmpty else { return messages }
        return messages.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }
}
