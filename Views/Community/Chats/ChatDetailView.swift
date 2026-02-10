//
//  ChatDetailView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import SwiftUI
import EmojiKit

struct ChatDetailView: View {
    let chat: ChatDisplayModel
    @StateObject private var viewModel = ChatsViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var messageText = ""
    @State private var isShowingSettings = false
    @State private var replyingTo: MessageModel?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingEmojiPicker = false
    @State private var showingProfileUserId: UUID?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                customHeader
                
                messagesList
                replyPreviewIfNeeded
                modernMessageInputBar
            }
        }
        .background(backgroundImage)
        .fullScreenCover(isPresented: Binding(
            get: { showingProfileUserId != nil },
            set: { if !$0 { showingProfileUserId = nil } }
        )) {
            if let userId = showingProfileUserId {
                ProfileViewForFriend(userId: userId)
                    .environmentObject(authViewModel)
            }
        }
        .searchable(text: $searchText, isPresented: $isSearching, placement: .navigationBarDrawer, prompt: "Tìm kiếm tin nhắn...")
        .navigationBarHidden(true)
        .onAppear {
            let context = SwiftDataService.shared.container.mainContext
            viewModel.setCurrentUser(authViewModel.currentUser!.id, context: context)
            viewModel.loadMessages(chatId: chat.chat.id)
        }
        .sheet(isPresented: $isShowingSettings) {
            ChatSettingsView(chat: chat.chat, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerSheet { emoji in
                viewModel.sendMessage(
                    chatId: chat.chat.id,
                    content: emoji.char,
                    type: .emoji
                ) { _ in }
                showingEmojiPicker = false
            }
        }
    }
    
    private var backgroundImage: some View {
        Group {
            if let bgName = chat.chat.backgroundName,
               let image = UIImage(named: bgName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .overlay(Color.black.opacity(0.3))
        .ignoresSafeArea()
    }
    
    // MARK: - Custom Header
    private var customHeader: some View {
        HStack(spacing: 12) {
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
            
            // Avatar + Name
            AsyncImage(url: URL(string: chat.otherUser.avatar ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chat.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Online")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Search button
            Button {
                withAnimation {
                    isSearching.toggle()
                    if !isSearching { searchText = "" }
                }
            } label: {
                Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
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
            
            // Settings button
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.4)
                .blur(radius: 20)
        )
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredMessages) { message in
                    ModernMessageBubble(
                        otherUserAvatar: chat.otherUser.avatar,
                        message: message,
                        isFromCurrentUser: isFromCurrentUser(message),
                        replyingTo: repliedMessage(for: message),
                        onReply: { message },
                        onDelete: deleteMessage,
                        onAvatarTap: {
                            showingProfileUserId = message.senderId
                        }
                    )
                    .environmentObject(authViewModel)
                    .onTapGesture {
                        replyingTo = message
                    }
                    .contextMenu {
                        Button("Reply") {
                            replyingTo = message
                        }
                        if isFromCurrentUser(message) {
                            Button("Delete message", role: .destructive) {
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
    private var replyPreviewIfNeeded: some View {
        Group {
            if let replyingTo = replyingTo {
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4)
                        .cornerRadius(2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Đang trả lời \(isFromCurrentUser(replyingTo) ? "bạn" : chat.displayName)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text(replyingTo.content)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button {
                        self.replyingTo = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Input Bar
    private var modernMessageInputBar: some View {
        HStack(spacing: 12) {
            // Emoji button
            Button {
                showingEmojiPicker.toggle()
            } label: {
                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
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
            
            // Text field
            HStack(spacing: 8) {
                TextField("Enter message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1...6)
                    .tint(.blue)
            }
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
            
            // Send button
            Button {
                let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                viewModel.sendMessage(
                    chatId: chat.chat.id,
                    content: trimmed,
                    type: .text
                ) { _ in }
                
                messageText = ""
                replyingTo = nil
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                    LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .shadow(
                                color: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                    Color.clear : Color.blue.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(16)
        .background(
            Color.black.opacity(0.6)
                .blur(radius: 20)
        )
    }
    
    // MARK: - Helper Functions
    private var filteredMessages: [MessageModel] {
        if searchText.isEmpty {
            return viewModel.messages
        } else {
            return viewModel.messages.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func isFromCurrentUser(_ message: MessageModel) -> Bool {
        message.senderId == authViewModel.currentUser?.id
    }
    
    private func repliedMessage(for message: MessageModel) -> MessageModel? {
        guard let replyId = message.replyToMessageId else { return nil }
        return viewModel.messages.first { $0.id == replyId }
    }
    
    private func deleteMessage(_ message: MessageModel) {
        guard isFromCurrentUser(message) else { return }
        
        Task {
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let stmt = try connection.prepareStatement(text: "DELETE FROM messages WHERE id = $1")
                defer { stmt.close() }
                try stmt.execute(parameterValues: [message.id.uuidString])
                
                await MainActor.run {
                    viewModel.loadMessages(chatId: chat.chat.id)
                }
            } catch {
                print("Lỗi xóa tin nhắn: \(error)")
            }
        }
    }
}

// MARK: - Message Bubble
struct ModernMessageBubble: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    let otherUserAvatar: String?
    let message: MessageModel
    let isFromCurrentUser: Bool
    let replyingTo: MessageModel?
    let onReply: () -> MessageModel
    let onDelete: (MessageModel) -> Void
    let onAvatarTap: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !isFromCurrentUser {
                // Avatar người khác
                Button {
                    onAvatarTap()
                } label: {
                    AsyncImage(url: URL(string: otherUserAvatar ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 16))
                            )
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
                // Reply
                if let replyingTo = replyingTo {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 3)
                        Text(replyingTo.content)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                
                // Message content
                Text(message.content)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFromCurrentUser ? .white : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                isFromCurrentUser ?
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        isFromCurrentUser ? Color.clear : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: isFromCurrentUser ? Color.blue.opacity(0.3) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if isFromCurrentUser {
                // Avatar của mình
                Button {
                    onAvatarTap()
                } label: {
                    AsyncImage(url: URL(string: authViewModel.currentUser?.avatar ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 16))
                            )
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, isFromCurrentUser ? 8 : 0)
        .id(message.id)
    }
}

// MARK: - Emoji Picker
struct EmojiPickerSheet: View {
    let onSelect: (Emoji) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                EmojiGrid(
                    sectionTitle: { section in
                        HStack {}
                        .padding(.horizontal)
                        .padding(.top, 8)
                    },
                    gridItem: { params in
                        Button {
                            onSelect(params.emoji)
                        } label: {
                            Text(params.emoji.char)
                                .font(.system(size: 32))
                                .frame(width: 44, height: 44)
                        }
                    }
                )
                .padding()
            }
            .navigationTitle("Select Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Chat Settings
struct ChatSettingsView: View {
    let chat: ChatModel
    let viewModel: ChatsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var nickname = ""
    
    private let backgrounds = [
        "cosmos_background",
        "cosmos_background1",
        "cosmos_background2"
    ]
    
    @State private var selectedBackground: String
    
    init(chat: ChatModel, viewModel: ChatsViewModel) {
        self.chat = chat
        self.viewModel = viewModel
        self._selectedBackground = State(initialValue: chat.backgroundName ?? "cosmos_background")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Customize") {
                    TextField("Nickname", text: $nickname)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 20) {
                        ForEach(backgrounds, id: \.self) { bgName in
                            Button {
                                selectedBackground = bgName
                            } label: {
                                ZStack {
                                    Image(bgName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 180)
                                        .clipped()
                                        .cornerRadius(12)
                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedBackground == bgName ? Color.blue : Color.clear, lineWidth: 4)
                                        )
                                        .shadow(radius: selectedBackground == bgName ? 8 : 0)
                                    
                                    if selectedBackground == bgName {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.blue)
                                            .background(Color.white.clipShape(Circle()))
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    if chat.isBlocked {
                        Button("Unblock") {}
                        .foregroundColor(.green)
                    } else {
                        Button("Block this person", role: .destructive) {
                            viewModel.blockUser(chatId: chat.id) { _ in }
                            dismiss()
                        }
                    }
                    
                    Button("Delete conversation", role: .destructive) {
                        viewModel.deleteChat(chatId: chat.id) { _ in }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Chat settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateChatSettings(
                            chatId: chat.id,
                            nickname: nickname.isEmpty ? nil : nickname,
                            backgroundName: selectedBackground,
                            quickEmoji: nil
                        ) { _ in
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let currentUserId = authViewModel.currentUser?.id {
                    let tempUser = UserModel(id: UUID(), email: "", username: "temp", password: "")
                    nickname = chat.getDisplayName(for: currentUserId, otherUser: tempUser)
                }
            }
        }
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(chat: ChatDisplayModel(
            id: UUID(),
            chat: ChatModel(participant1Id: UUID(), participant2Id: UUID()),
            otherUser: UserModel(id: UUID(), email: "", username: "Người khác", password: "", avatar: nil),
            currentUserId: UUID()
        ))
        .environmentObject(AuthViewModel())
    }
}
