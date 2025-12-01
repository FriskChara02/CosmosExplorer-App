//
//  GroupChatView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import SwiftUI

struct GroupChatView: View {
    let group: GroupModel
    @StateObject private var viewModel = GroupsViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var messageText = ""
    @State private var replyingTo: GroupMessageModel?
    @State private var showingMembers = false
    @State private var showingEmojiPicker = false
    @State private var showingProfileUserId: UUID?
    
    var isAdmin: Bool {
        viewModel.groups.first { $0.group.id == group.id }?.isAdmin ?? false
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                customHeader
                messagesList
                replyPreview
                modernInputBar
            }
        }
        .background(backgroundView)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: Binding(
            get: { showingProfileUserId != nil },
            set: { if !$0 { showingProfileUserId = nil } }
        )) {
            if let userId = showingProfileUserId {
                ProfileViewForFriend(userId: userId)
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            let context = SwiftDataService.shared.container.mainContext
            viewModel.setCurrentUser(authViewModel.currentUser!.id, context: context)
            viewModel.loadGroupMessages(groupId: group.id)
            viewModel.loadGroupMembers(groupId: group.id)
            viewModel.loadWordFilters(groupId: group.id)
        }
        .sheet(isPresented: $showingMembers) {
            GroupSettingsAndMembersView(group: group, viewModel: viewModel)
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerSheet { emoji in
                viewModel.sendGroupMessage(groupId: group.id, content: emoji.char, type: .emoji) { _ in }
                showingEmojiPicker = false
            }
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        ZStack {
            if let bgName = group.avatar, !bgName.isEmpty,
               let image = UIImage(named: bgName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            Color.black.opacity(0.3)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Custom Header
    private var customHeader: some View {
        HStack(spacing: 12) {
            backButton
            groupAvatar
            groupInfo
            Spacer()
            membersButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.4)
                .blur(radius: 20)
        )
    }
    
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var groupAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 18))
                )
                .frame(width: 40, height: 40)
            
            if isAdmin {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .padding(3)
                    .background(Circle().fill(Color.black))
            }
        }
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    private var groupInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(group.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Text("\(viewModel.groupMembers.count) thành viên")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var membersButton: some View {
        Button {
            showingMembers = true
        } label: {
            Image(systemName: "person.2.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.groupMessages) { message in
                    ModernGroupMessageBubble(
                        message: message,
                        senderName: senderName(for: message.senderId),
                        senderAvatar: senderAvatar(for: message.senderId),
                        isAdmin: isSenderAdmin(message.senderId),
                        isFromCurrentUser: message.senderId == authViewModel.currentUser?.id,
                        replyingTo: viewModel.groupMessages.first { $0.id == message.replyToMessageId },
                        onReply: { replyingTo = message },
                        onAvatarTap: { userId in
                            showingProfileUserId = userId
                        }
                    )
                    .contextMenu {
                        Button("Trả lời") {
                            replyingTo = message
                        }
                        if message.senderId == authViewModel.currentUser?.id {
                            Button("Xóa tin nhắn", role: .destructive) {
                                deleteMessage(message)
                            }
                        }
                        Button("Copy") {
                            UIPasteboard.general.string = message.content
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Reply Preview
    @ViewBuilder
    private var replyPreview: some View {
        if let replyingTo = replyingTo {
            ReplyPreviewBar(
                senderName: senderName(for: replyingTo.senderId),
                content: replyingTo.content,
                onDismiss: { self.replyingTo = nil }
            )
        }
    }
    
    // MARK: - Input Bar
    private var modernInputBar: some View {
        HStack(spacing: 12) {
            emojiButton
            messageTextField
            sendButton
        }
        .padding(16)
        .background(
            Color.black.opacity(0.6)
                .blur(radius: 20)
        )
    }
    
    private var emojiButton: some View {
        Button {
            showingEmojiPicker.toggle()
        } label: {
            Image(systemName: "face.smiling.fill")
                .font(.system(size: 22))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var messageTextField: some View {
        TextField("Tin nhắn nhóm...", text: $messageText, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .lineLimit(1...6)
            .tint(.orange)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
    
    private var sendButton: some View {
        Button {
            sendMessage()
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(sendButtonBackground)
        }
        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    private var sendButtonBackground: some View {
        Circle()
            .fill(
                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                    LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .shadow(
                color: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                    Color.clear : Color.orange.opacity(0.4),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    // MARK: - Helper Functions
    private func senderName(for userId: UUID) -> String {
        viewModel.groupMembers.first { $0.userId == userId }?.username ?? "Unknown"
    }
    
    private func senderAvatar(for userId: UUID) -> String? {
        viewModel.groupMembers.first { $0.userId == userId }?.avatar
    }
    
    private func isSenderAdmin(_ userId: UUID) -> Bool {
        viewModel.groupMembers.first { $0.userId == userId }?.isAdmin ?? false
    }
    
    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        viewModel.sendGroupMessage(
            groupId: group.id,
            content: trimmed,
            type: .text
        ) { _ in }
        
        messageText = ""
        replyingTo = nil
    }
    
    private func deleteMessage(_ message: GroupMessageModel) {
        guard message.senderId == authViewModel.currentUser?.id else { return }
        
        Task {
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let stmt = try connection.prepareStatement(text: "DELETE FROM group_messages WHERE id = $1")
                defer { stmt.close() }
                try stmt.execute(parameterValues: [message.id.uuidString])
                
                await MainActor.run {
                    viewModel.loadGroupMessages(groupId: group.id)
                }
            } catch {
                print("Lỗi xóa tin nhắn nhóm: \(error)")
            }
        }
    }
}

// MARK: - Reply Preview Bar Component
struct ReplyPreviewBar: View {
    let senderName: String
    let content: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            replyIndicator
            replyContent
            Spacer()
            dismissButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(replyBackground)
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var replyIndicator: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.orange, Color.pink],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4)
            .cornerRadius(2)
    }
    
    private var replyContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Đang trả lời \(senderName)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            Text(content)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
    }
    
    private var dismissButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var replyBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Group Message Bubble
struct ModernGroupMessageBubble: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    let message: GroupMessageModel
    let senderName: String
    let senderAvatar: String?
    let isAdmin: Bool
    let isFromCurrentUser: Bool
    let replyingTo: GroupMessageModel?
    let onReply: () -> Void
    let onAvatarTap: (UUID) -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !isFromCurrentUser {
                senderAvatarView
            }
            
            messageContentView
            
            if isFromCurrentUser {
                AsyncImage(url: URL(string: authViewModel.currentUser?.avatar ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                        )
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
                .onTapGesture { onAvatarTap(message.senderId) }
            }
        }
        .onTapGesture { onReply() }
    }
    
    private var senderAvatarView: some View {
        AsyncImage(url: URL(string: senderAvatar ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 14))
                )
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    private var messageContentView: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            if !isFromCurrentUser {
                senderInfoView
            }
            
            if let replyingTo = replyingTo {
                replyPreviewView(for: replyingTo)
            }
            
            messageTextView
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isFromCurrentUser ? .trailing : .leading)
    }
    
    private var senderInfoView: some View {
        HStack(spacing: 6) {
            Text(senderName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            
            if isAdmin {
                adminBadge
            }
        }
    }
    
    private var adminBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 9))
            Text("Admin")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
        )
    }
    
    private func replyPreviewView(for reply: GroupMessageModel) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 3)
            Text(reply.content)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var messageTextView: some View {
        Text(message.content)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(messageBubbleBackground)
    }
    
    private var messageBubbleBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(bubbleGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isFromCurrentUser ? Color.clear : Color.white.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isFromCurrentUser ? Color.orange.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    private var bubbleGradient: LinearGradient {
        isFromCurrentUser ?
            LinearGradient(
                colors: [Color.orange, Color.pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                colors: [Color.white.opacity(0.15), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
}

// MARK: - Group Settings and Members
struct GroupSettingsAndMembersView: View {
    let group: GroupModel
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var newGroupName = ""
    @State private var selectedBackground: String = ""
    @State private var showingAddMember = false
    @State private var showingAddFilter = false
    
    private let backgrounds = ["cosmos_background", "cosmos_background1", "cosmos_background2"]
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 20) {
                        groupInfoSection
                        membersSection
                        wordFilterSection
                        dangerZoneSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Cài đặt nhóm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cài đặt nhóm")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        saveSettings()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                newGroupName = group.title
                selectedBackground = group.avatar ?? "BlackBG"
            }
            .sheet(isPresented: $showingAddMember) {
                AddMemberToGroupView(groupId: group.id, viewModel: viewModel)
                    .environmentObject(authViewModel)
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color.black.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var groupInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thông tin nhóm")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            TextField("Tên nhóm", text: $newGroupName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(16)
                .background(textFieldBackground)
            
            backgroundSelectionView
        }
        .padding(20)
        .background(sectionBackground)
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var backgroundSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(backgrounds, id: \.self) { bg in
                    backgroundThumbnail(bg)
                }
            }
        }
    }
    
    private func backgroundThumbnail(_ bg: String) -> some View {
        Button {
            selectedBackground = bg
        } label: {
            Image(bg)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 140)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedBackground == bg ? Color.orange : Color.clear, lineWidth: 4)
                )
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            membersSectionHeader
            membersList
            addMemberButton
        }
        .padding(20)
        .background(sectionBackground)
    }
    
    private var membersSectionHeader: some View {
        HStack {
            Text("Thành viên")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(viewModel.groupMembers.count)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
    
    private var membersList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.groupMembers) { member in
                ModernMemberRow(member: member, groupId: group.id, viewModel: viewModel)
            }
        }
    }
    
    private var addMemberButton: some View {
        Button {
            showingAddMember.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Thêm thành viên")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(addMemberButtonBackground)
        }
    }
    
    private var addMemberButtonBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(
                LinearGradient(
                    colors: [Color.orange, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var wordFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bộ lọc từ")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                Button("Thêm từ") {
                    showingAddFilter = true
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.orange)
            }
            
            ForEach(viewModel.wordFilters) { filter in
                HStack {
                    Text(filter.bannedWord)
                        .foregroundColor(.white)
                    if let rep = filter.replacement {
                        Text("→ \(rep)")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        viewModel.removeWordFilter(filterId: filter.id) { _ in }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(sectionBackground)
        .sheet(isPresented: $showingAddFilter) {
            AddWordFilterView(groupId: group.id, viewModel: viewModel)
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(spacing: 12) {
            leaveGroupButton
            
            if viewModel.isCurrentUserAdmin(of: group.id) {
                deleteGroupButton
            }
        }
        .padding(20)
        .background(dangerZoneBackground)
    }
    
    private var leaveGroupButton: some View {
        Button {
            confirmLeaveGroup()
        } label: {
            Text("Rời nhóm")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(leaveButtonBackground)
        }
    }
    
    private var leaveButtonBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.red.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
            )
    }
    
    private var deleteGroupButton: some View {
        Button {
            confirmDeleteGroup()
        } label: {
            Text("Xóa nhóm hoàn toàn")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(deleteButtonBackground)
        }
    }
    
    private var deleteButtonBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.red.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.red, lineWidth: 1)
            )
    }
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    private var dangerZoneBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
    }
    
    private func saveSettings() {
        let trimmed = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let titleChanged = trimmed != group.title && !trimmed.isEmpty
        let avatarChanged = selectedBackground != (group.avatar ?? "")
        
        guard titleChanged || avatarChanged else {
            dismiss()
            return
        }
        
        if titleChanged {
            viewModel.updateGroupTitle(groupId: group.id, newTitle: trimmed) { _ in }
        }
        
        if avatarChanged {
            viewModel.updateGroupAvatar(groupId: group.id, avatarName: selectedBackground) { _ in }
        }
        
        dismiss()
    }
    
    private func confirmLeaveGroup() {
        let alert = UIAlertController(
            title: "Rời nhóm",
            message: "Bạn có chắc chắn muốn rời khỏi nhóm \"\(group.title)\" không?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Rời nhóm", style: .destructive) { _ in
            viewModel.leaveGroup(groupId: group.id) { success in
                if success {
                    dismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        })
        presentAlert(alert)
    }
    
    private func confirmDeleteGroup() {
        let alert = UIAlertController(
            title: "Xóa nhóm",
            message: "Hành động này sẽ xóa toàn bộ tin nhắn và dữ liệu nhóm. Không thể khôi phục!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa vĩnh viễn", style: .destructive) { _ in
            viewModel.deleteGroup(groupId: group.id) { success in
                if success {
                    dismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        })
        presentAlert(alert)
    }
    
    private func presentAlert(_ alert: UIAlertController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

// MARK: - Member Row
struct ModernMemberRow: View {
    let member: GroupMemberDisplayModel
    let groupId: UUID
    @ObservedObject var viewModel: GroupsViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            memberAvatar
            memberInfo
            Spacer()
            
            if viewModel.isCurrentUserAdmin(of: groupId) && !member.isAdmin {
                removeButton
            }
        }
        .padding(12)
        .background(rowBackground)
    }
    
    private var memberAvatar: some View {
        AsyncImage(url: URL(string: member.avatar ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
        )
    }
    
    private var memberInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(member.username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                if member.isAdmin {
                    adminBadge
                }
            }
        }
    }
    
    private var adminBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 9))
            Text("Admin")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
        )
    }
    
    private var removeButton: some View {
        Button {
            confirmRemoveMember(member)
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.red.opacity(0.15))
                )
        }
    }
    
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    private func confirmRemoveMember(_ member: GroupMemberDisplayModel) {
        let alert = UIAlertController(
            title: "Xóa thành viên",
            message: "Bạn có chắc chắn muốn xóa \(member.username) khỏi nhóm không?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
            viewModel.kickMember(groupId: groupId, userId: member.userId) { _ in }
        })
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

// MARK: - Add Member View
struct AddMemberToGroupView: View {
    let groupId: UUID
    @ObservedObject var viewModel: GroupsViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var friendsVM = FriendsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(friendsVM.friends) { friend in
                            FriendSelectionRow(
                                friend: friend,
                                isInGroup: viewModel.groupMembers.contains(where: { $0.userId == friend.userId }),
                                onAdd: {
                                    viewModel.addMembers(to: groupId, newMemberIds: [friend.userId]) { _ in }
                                }
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Thêm thành viên")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    let context = SwiftDataService.shared.container.mainContext
                    friendsVM.setCurrentUser(userId, context: context)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color.black.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Friend Selection Row
struct FriendSelectionRow: View {
    let friend: FriendDisplayModel
    let isInGroup: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            friendAvatar
            friendInfo
            Spacer()
            actionView
        }
        .padding(14)
        .background(rowBackground)
    }
    
    private var friendAvatar: some View {
        AsyncImage(url: URL(string: friend.avatar ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle().fill(.gray.opacity(0.3))
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
        )
    }
    
    private var friendInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(friend.username)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text("Rank \(friend.rank)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
        if isInGroup {
            Text("Đã trong nhóm")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        } else {
            Button(action: onAdd) {
                Text("Thêm")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(addButtonBackground)
            }
        }
    }
    
    private var addButtonBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [Color.orange, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Add Word Filter View (Admin only)
struct AddWordFilterView: View {
    let groupId: UUID
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var bannedWord = ""
    @State private var replacement = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Từ cần cấm") {
                    TextField("Nhập từ cấm (không phân biệt hoa thường)", text: $bannedWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Thay thế bằng (tùy chọn)") {
                    TextField("Để trống sẽ thay bằng ***", text: $replacement)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Hoặc lưu ở đây nè admin :333") {
                        let word = bannedWord.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !word.isEmpty else { return }
                        
                        let rep = replacement.trimmingCharacters(in: .whitespacesAndNewlines)
                        let finalRep = rep.isEmpty ? nil : rep
                        
                        viewModel.addWordFilter(
                            groupId: groupId,
                            bannedWord: word,
                            replacement: finalRep
                        ) { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(bannedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Thêm từ cấm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") { dismiss() }
                        .foregroundColor(.orange)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        let word = bannedWord.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !word.isEmpty else { return }
                        
                        viewModel.addWordFilter(
                            groupId: groupId,
                            bannedWord: word,
                            replacement: replacement.isEmpty ? nil : replacement
                        ) { _ in dismiss() }
                    }
                    .bold()
                    .foregroundColor(.orange)
                    .disabled(bannedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
