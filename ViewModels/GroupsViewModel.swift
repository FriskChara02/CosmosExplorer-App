//
//  GroupsViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import Foundation
import SwiftData
import PostgresClientKit
import Combine

class GroupsViewModel: ObservableObject {
    @Published var groups: [GroupDisplayModel] = []
    @Published var groupMessages: [GroupMessageModel] = []
    @Published var groupMembers: [GroupMemberDisplayModel] = []
    @Published var wordFilters: [GroupWordFilterModel] = []
    @Published var currentGroup: GroupModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var modelContext: ModelContext?
    private var currentUserId: UUID?
    
    func setCurrentUser(_ userId: UUID, context: ModelContext) {
        self.currentUserId = userId
        self.modelContext = context
        loadGroups(userId: userId)
    }
    
    func loadGroups(userId: UUID) {
        isLoading = true
        guard let connection = try? DatabaseConfig.createConnection() else {
            errorMessage = "Không thể kết nối database"
            isLoading = false
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT g.id, g.title, g.avatar, g.created_by, g.last_message_content,
                       g.last_message_time, g.created_at, g.updated_at,
                       (SELECT COUNT(*) FROM group_members WHERE group_id = g.id) as member_count,
                       gm.role
                FROM groups g
                INNER JOIN group_members gm ON g.id = gm.group_id
                WHERE gm.user_id = $1
                ORDER BY g.last_message_time DESC NULLS LAST
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [userId.uuidString])
            defer { cursor.close() }
            
            var groupsList: [GroupDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let groupId = UUID(uuidString: try row.columns[0].string()),
                   let title = try? row.columns[1].string(),
                   let createdBy = UUID(uuidString: try row.columns[3].string()) {
                    
                    let avatar = try? row.columns[2].string()
                    let lastMsg = try? row.columns[4].string()
                    let lastTimeStr = try? row.columns[5].string()
                    let lastTime = lastTimeStr.flatMap { ISO8601DateFormatter().date(from: $0) }
                    let createdStr = try row.columns[6].string()
                    let updatedStr = try row.columns[7].string()
                    let memberCount = (try? row.columns[8].int()) ?? 0
                    let role = (try? row.columns[9].string()) ?? "member"
                    
                    let created = ISO8601DateFormatter().date(from: createdStr) ?? Date()
                    let updated = ISO8601DateFormatter().date(from: updatedStr) ?? Date()
                    
                    let group = GroupModel(
                        id: groupId,
                        title: title,
                        avatar: avatar,
                        createdAt: created,
                        updatedAt: updated,
                        createdBy: createdBy,
                        lastMessageContent: lastMsg,
                        lastMessageTime: lastTime
                    )
                    
                    let displayGroup = GroupDisplayModel(
                        id: groupId,
                        group: group,
                        memberCount: memberCount,
                        isAdmin: role == "admin"
                    )
                    groupsList.append(displayGroup)
                }
            }
            
            DispatchQueue.main.async {
                self.groups = groupsList
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Lỗi load groups: \(error)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Create Group
    func createGroup(title: String, memberIds: [UUID], completion: @escaping (Bool, UUID?) -> Void) {
        guard let adminId = currentUserId else {
            completion(false, nil)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false, nil)
            return
        }
        defer { connection.close() }
        
        do {
            let groupId = UUID()
            let now = ISO8601DateFormatter().string(from: Date())
            
            let groupStmt = try connection.prepareStatement(text: """
                INSERT INTO groups (id, title, created_by, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5)
            """)
            defer { groupStmt.close() }
            try groupStmt.execute(parameterValues: [
                groupId.uuidString,
                title,
                adminId.uuidString,
                now,
                now
            ])
            
            let adminMemberId = UUID()
            let adminStmt = try connection.prepareStatement(text: """
                INSERT INTO group_members (id, group_id, user_id, role, joined_at)
                VALUES ($1, $2, $3, $4, $5)
            """)
            defer { adminStmt.close() }
            try adminStmt.execute(parameterValues: [
                adminMemberId.uuidString,
                groupId.uuidString,
                adminId.uuidString,
                "admin",
                now
            ])
            
            for memberId in memberIds {
                let memberUUID = UUID()
                let memberStmt = try connection.prepareStatement(text: """
                    INSERT INTO group_members (id, group_id, user_id, role, joined_at)
                    VALUES ($1, $2, $3, $4, $5)
                """)
                defer { memberStmt.close() }
                try memberStmt.execute(parameterValues: [
                    memberUUID.uuidString,
                    groupId.uuidString,
                    memberId.uuidString,
                    "member",
                    now
                ])
            }
            
            DispatchQueue.main.async {
                self.loadGroups(userId: adminId)
                completion(true, groupId)
            }
        } catch {
            print("❌ Error creating group: \(error)")
            completion(false, nil)
        }
    }
    
    // MARK: - Load Group Messages
    func loadGroupMessages(groupId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, group_id, sender_id, content, message_type, reactions,
                       created_at, reply_to_message_id
                FROM group_messages
                WHERE group_id = $1
                ORDER BY created_at ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [groupId.uuidString])
            defer { cursor.close() }
            
            var messagesList: [GroupMessageModel] = []
            while let row = try cursor.next()?.get() {
                if let msgId = UUID(uuidString: try row.columns[0].string()),
                   let grpId = UUID(uuidString: try row.columns[1].string()),
                   let senderId = UUID(uuidString: try row.columns[2].string()),
                   let content = try? row.columns[3].string() {
                    
                    let msgType = (try? row.columns[4].string()) ?? "text"
                    let reactions = try? row.columns[5].string()
                    let createdStr = try row.columns[6].string()
                    let created = ISO8601DateFormatter().date(from: createdStr) ?? Date()
                    let replyToStr = try? row.columns[7].string()
                    let replyTo = replyToStr.flatMap { UUID(uuidString: $0) }
                    
                    let message = GroupMessageModel(
                        id: msgId,
                        groupId: grpId,
                        senderId: senderId,
                        content: content,
                        messageType: MessageType(rawValue: msgType) ?? .text,
                        reactions: reactions,
                        createdAt: created,
                        replyToMessageId: replyTo
                    )
                    messagesList.append(message)
                }
            }
            
            DispatchQueue.main.async {
                self.groupMessages = messagesList
            }
        } catch {
            print("❌ Error loading group messages: \(error)")
        }
    }
    
    // MARK: - Send Group Message
    func sendGroupMessage(groupId: UUID, content: String, type: MessageType = .text, completion: @escaping (Bool) -> Void) {
        guard let senderId = currentUserId else {
            completion(false)
            return
        }
        
        let filteredContent = applyWordFilters(content: content, groupId: groupId)
        
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
                INSERT INTO group_messages (id, group_id, sender_id, content, message_type, created_at)
                VALUES ($1, $2, $3, $4, $5, $6)
            """)
            defer { msgStmt.close() }
            try msgStmt.execute(parameterValues: [
                messageId.uuidString,
                groupId.uuidString,
                senderId.uuidString,
                filteredContent,
                type.rawValue,
                nowStr
            ])
            
            let updateStmt = try connection.prepareStatement(text: """
                UPDATE groups
                SET last_message_content = $1, last_message_time = $2, updated_at = $3
                WHERE id = $4
            """)
            defer { updateStmt.close() }
            try updateStmt.execute(parameterValues: [filteredContent, nowStr, nowStr, groupId.uuidString])
            
            DispatchQueue.main.async {
                self.loadGroupMessages(groupId: groupId)
                if let userId = self.currentUserId {
                    self.loadGroups(userId: userId)
                }
                completion(true)
            }
        } catch {
            print("❌ Error sending group message: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Apply Word Filters
    private func applyWordFilters(content: String, groupId: UUID) -> String {
        loadWordFilters(groupId: groupId)
        var filteredContent = content
        
        for filter in wordFilters {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: filter.bannedWord))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(filteredContent.startIndex..., in: filteredContent)
                filteredContent = regex.stringByReplacingMatches(
                    in: filteredContent,
                    options: [],
                    range: range,
                    withTemplate: filter.replacement ?? "***"
                )
            }
        }
        
        return filteredContent
    }
    
    // MARK: - Load Word Filters
    func loadWordFilters(groupId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, group_id, banned_word, replacement, created_at
                FROM group_word_filters
                WHERE group_id = $1
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [groupId.uuidString])
            defer { cursor.close() }
            
            var filtersList: [GroupWordFilterModel] = []
            while let row = try cursor.next()?.get() {
                if let filterId = UUID(uuidString: try row.columns[0].string()),
                   let grpId = UUID(uuidString: try row.columns[1].string()),
                   let word = try? row.columns[2].string() {
                    
                    let replacement = try? row.columns[3].string()
                    let createdStr = try row.columns[4].string()
                    let created = ISO8601DateFormatter().date(from: createdStr) ?? Date()
                    
                    let filter = GroupWordFilterModel(
                        id: filterId,
                        groupId: grpId,
                        bannedWord: word,
                        replacement: replacement,
                        createdAt: created
                    )
                    filtersList.append(filter)
                }
            }
            
            DispatchQueue.main.async {
                self.wordFilters = filtersList
            }
        } catch {
            print("❌ Error loading word filters: \(error)")
        }
    }
    
    // MARK: - Add Word Filter (Admin only)
    func addWordFilter(groupId: UUID, bannedWord: String, replacement: String?, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: userId) else {
            print("❌ User is not admin")
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let filterId = UUID()
            let statement = try connection.prepareStatement(text: """
                INSERT INTO group_word_filters (id, group_id, banned_word, replacement, created_at)
                VALUES ($1, $2, $3, $4, $5)
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [
                filterId.uuidString,
                groupId.uuidString,
                bannedWord,
                replacement ?? "***",
                ISO8601DateFormatter().string(from: Date())
            ])
            
            DispatchQueue.main.async {
                self.loadWordFilters(groupId: groupId)
                completion(true)
            }
        } catch {
            print("❌ Error adding word filter: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Remove Word Filter
    func removeWordFilter(filterId: UUID, completion: @escaping (Bool) -> Void) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM group_word_filters WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [filterId.uuidString])
            
            DispatchQueue.main.async {
                completion(true)
            }
        } catch {
            print("❌ Error removing word filter: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Load Group Members
    func loadGroupMembers(groupId: UUID) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT u.id, u.username, u.avatar, u.status, u.bio, u.rank, u.score, gm.role
                FROM users u
                INNER JOIN group_members gm ON u.id = gm.user_id
                WHERE gm.group_id = $1
                ORDER BY gm.role DESC, u.username ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [groupId.uuidString])
            defer { cursor.close() }
            
            var membersList: [GroupMemberDisplayModel] = []
            while let row = try cursor.next()?.get() {
                if let userId = UUID(uuidString: try row.columns[0].string()),
                   let username = try? row.columns[1].string() {
                    
                    let avatar = try? row.columns[2].string()
                    let status = try? row.columns[3].string()
                    let bio = try? row.columns[4].string()
                    let rank = (try? row.columns[5].int()) ?? 2000
                    let score = (try? row.columns[6].int()) ?? 0
                    let role = (try? row.columns[7].string()) ?? "member"
                    
                    let member = GroupMemberDisplayModel(
                        id: userId,
                        userId: userId,
                        username: username,
                        avatar: avatar,
                        status: status,
                        bio: bio,
                        rank: rank,
                        score: score,
                        role: role
                    )
                    membersList.append(member)
                }
            }
            
            DispatchQueue.main.async {
                self.groupMembers = membersList
            }
        } catch {
            print("❌ Error loading group members: \(error)")
        }
    }
    
    // MARK: - Kick Member (Admin only)
    func kickMember(groupId: UUID, userId: UUID, completion: @escaping (Bool) -> Void) {
        guard let adminId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: adminId) else {
            print("❌ User is not admin")
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
                DELETE FROM group_members
                WHERE group_id = $1 AND user_id = $2 AND role != 'admin'
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [groupId.uuidString, userId.uuidString])
            
            DispatchQueue.main.async {
                self.loadGroupMembers(groupId: groupId)
                completion(true)
            }
        } catch {
            print("❌ Error kicking member: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Update Group Title (Admin only)
    func updateGroupTitle(groupId: UUID, newTitle: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: userId) else {
            print("❌ User is not admin")
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
                UPDATE groups
                SET title = $1, updated_at = $2
                WHERE id = $3
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [
                newTitle,
                ISO8601DateFormatter().string(from: Date()),
                groupId.uuidString
            ])
            
            DispatchQueue.main.async {
                if let userId = self.currentUserId {
                    self.loadGroups(userId: userId)
                }
                completion(true)
            }
        } catch {
            print("❌ Error updating group title: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Check if User is Admin
    func isUserAdmin(groupId: UUID, userId: UUID) -> Bool {
        guard let connection = try? DatabaseConfig.createConnection() else { return false }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT role FROM group_members WHERE group_id = $1 AND user_id = $2
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [groupId.uuidString, userId.uuidString])
            defer { cursor.close() }
            
            if let row = try cursor.next()?.get(),
               let role = try? row.columns[0].string() {
                return role == "admin"
            }
        } catch {
            print("❌ Error checking admin status: \(error)")
        }
        return false
    }
    
    func isCurrentUserAdmin(of groupId: UUID) -> Bool {
        groups.first(where: { $0.group.id == groupId })?.isAdmin ?? false
    }
    
    // MARK: - Thêm thành viên mới vào nhóm (Admin only)
    func addMembers(to groupId: UUID, newMemberIds: [UUID], completion: @escaping (Bool) -> Void) {
        guard let adminId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: adminId) else {
            print("User không phải admin, không thể thêm thành viên")
            completion(false)
            return
        }
        
        guard !newMemberIds.isEmpty else {
            completion(true)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            let now = ISO8601DateFormatter().string(from: Date())
            
            var placeholders = [String]()
            var parameters: [any PostgresValueConvertible] = []

            for (index, userId) in newMemberIds.enumerated() {
                let memberId = UUID()
                let offset = index * 5
                placeholders.append("($\(offset + 1), $\(offset + 2), $\(offset + 3), $\(offset + 4), $\(offset + 5))")
                
                parameters.append(memberId.uuidString)
                parameters.append(groupId.uuidString)
                parameters.append(userId.uuidString)
                parameters.append("member")
                parameters.append(now)
            }
            
            let sql = """
                INSERT INTO group_members (id, group_id, user_id, role, joined_at)
                VALUES \(placeholders.joined(separator: ", "))
                """
            
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }
            
            try statement.execute(parameterValues: parameters)
            
            DispatchQueue.main.async {
                self.loadGroupMembers(groupId: groupId)
                completion(true)
            }
            
        } catch {
            print("Lỗi thêm thành viên vào nhóm: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Update Group Avatar (Admin only)
    func updateGroupAvatar(groupId: UUID, avatarName: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: userId) else {
            print("User không phải admin, không thể đổi avatar nhóm")
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
                UPDATE groups
                SET avatar = $1, updated_at = $2
                WHERE id = $3
                """)
            defer { statement.close() }
            
            let now = ISO8601DateFormatter().string(from: Date())
            try statement.execute(parameterValues: [
                avatarName,
                now,
                groupId.uuidString
            ])
            
            DispatchQueue.main.async {
                self.loadGroups(userId: userId)
                completion(true)
            }
        } catch {
            print("Lỗi cập nhật avatar nhóm: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Leave Group (Rời nhóm - ai cũng được)
    func leaveGroup(groupId: UUID, completion: @escaping (Bool) -> Void) {
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
                DELETE FROM group_members 
                WHERE group_id = $1 AND user_id = $2
            """)
            defer { statement.close() }
            try statement.execute(parameterValues: [groupId.uuidString, userId.uuidString])
            
            DispatchQueue.main.async {
                self.loadGroups(userId: userId)
                completion(true)
            }
        } catch {
            print("Error leaving group: \(error)")
            completion(false)
        }
    }

    // MARK: - Delete Group (Chỉ admin/creator mới được xóa hoàn toàn nhóm)
    func deleteGroup(groupId: UUID, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUserId else {
            completion(false)
            return
        }
        
        guard isUserAdmin(groupId: groupId, userId: userId) else {
            print("User không phải admin, không thể xóa nhóm")
            completion(false)
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            completion(false)
            return
        }
        defer { connection.close() }
        
        do {
            // Bắt đầu transaction để xóa an toàn
            let stmt = try connection.prepareStatement(text: "BEGIN")
            defer { stmt.close() }
            try stmt.execute()
            
            // Xóa tin nhắn nhóm trước
            let msgStmt = try connection.prepareStatement(text: "DELETE FROM group_messages WHERE group_id = $1")
            defer { msgStmt.close() }
            try msgStmt.execute(parameterValues: [groupId.uuidString])
            
            // Xóa bộ lọc từ
            let filterStmt = try connection.prepareStatement(text: "DELETE FROM group_word_filters WHERE group_id = $1")
            defer { filterStmt.close() }
            try filterStmt.execute(parameterValues: [groupId.uuidString])
            
            // Xóa thành viên
            let memberStmt = try connection.prepareStatement(text: "DELETE FROM group_members WHERE group_id = $1")
            defer { memberStmt.close() }
            try memberStmt.execute(parameterValues: [groupId.uuidString])
            
            // Cuối cùng xóa nhóm
            let groupStmt = try connection.prepareStatement(text: "DELETE FROM groups WHERE id = $1")
            defer { groupStmt.close() }
            try groupStmt.execute(parameterValues: [groupId.uuidString])
            
            let commitStmt = try connection.prepareStatement(text: "COMMIT")
            defer { commitStmt.close() }
            try commitStmt.execute()
            
            DispatchQueue.main.async {
                self.loadGroups(userId: userId)
                completion(true)
            }
        } catch {
            do {
                let rollbackStmt = try connection.prepareStatement(text: "ROLLBACK")
                defer { rollbackStmt.close() }
                try rollbackStmt.execute()
            } catch {
                print("Rollback failed: \(error)")
            }
            print("Error deleting group: \(error)")
            completion(false)
        }
    }
}
