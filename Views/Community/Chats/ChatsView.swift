//
//  ChatsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import SwiftUI

struct ChatsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatsVM = ChatsViewModel()
    @StateObject private var groupsVM = GroupsViewModel()
    
    @State private var selectedTab: ChatFilterTab = .all
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    modernTabFilter
                    
                    // Content
                    if unifiedItems.isEmpty && !chatsVM.isLoading && !groupsVM.isLoading {
                        emptyStateView
                    } else {
                        chatsList
                    }
                }
            }
            .navigationBarHidden(true)
            .tint(.white)
            .onAppear {
                guard let userId = authViewModel.currentUser?.id else { return }
                let context = SwiftDataService.shared.container.mainContext
                
                chatsVM.setCurrentUser(userId, context: context)
                groupsVM.setCurrentUser(userId, context: context)
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("FriendAcceptedReloadChats"), object: nil, queue: .main) { _ in
                    chatsVM.loadChats(userId: userId)
                    groupsVM.loadGroups(userId: userId)
                }
            }
        }
    }
    
    // MARK: - Custom Header
    private var headerView: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Tin nhắn")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(unifiedItems.count) cuộc trò chuyện")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            NavigationLink(destination: CreateGroupView().navigationBarBackButtonHidden(true)) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Tab Filter
    private var modernTabFilter: some View {
        HStack(spacing: 0) {
            ForEach(ChatFilterTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func tabButton(for tab: ChatFilterTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: iconForTab(tab))
                    .font(.system(size: 14, weight: .semibold))
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTab == tab ?
                          LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
            )
        }
    }
    
    private func iconForTab(_ tab: ChatFilterTab) -> String {
        switch tab {
        case .all: return "bubble.left.and.bubble.right.fill"
        case .chats: return "message.fill"
        case .groups: return "person.3.fill"
        }
    }
    
    // MARK: - Chats List
    private var chatsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(unifiedItems) { item in
                    NavigationLink(destination: item.destination) {
                        ModernChatRow(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        if !item.isGroup {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Xóa cuộc trò chuyện", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                
                Image(systemName: "message.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("Chưa có tin nhắn nào")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Bắt đầu trò chuyện với bạn bè\nhoặc tham gia nhóm!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: CreateGroupView().navigationBarBackButtonHidden(true)) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Tạo nhóm mới")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var unifiedItems: [UnifiedChatItem] {
        let allItems = allUnifiedItems
        
        switch selectedTab {
        case .all:
            return allItems.sorted { ($0.lastTime ?? Date.distantPast) > ($1.lastTime ?? Date.distantPast) }
        case .chats:
            return allItems.filter { !$0.isGroup }
                .sorted { ($0.lastTime ?? Date.distantPast) > ($1.lastTime ?? Date.distantPast) }
        case .groups:
            return allItems.filter { $0.isGroup }
                .sorted { ($0.lastTime ?? Date.distantPast) > ($1.lastTime ?? Date.distantPast) }
        }
    }
    
    private var allUnifiedItems: [UnifiedChatItem] {
        var items: [UnifiedChatItem] = []
        
        for chatItem in chatsVM.chats {
            items.append(UnifiedChatItem(
                id: chatItem.chat.id,
                title: chatItem.displayName,
                avatarURL: URL(string: chatItem.avatar ?? ""),
                lastMessage: chatItem.lastMessage,
                lastTime: chatItem.lastTime,
                isBlocked: chatItem.isBlocked,
                isGroup: false,
                destination: AnyView(ChatDetailView(chat: chatItem))
            ))
        }
        
        for groupItem in groupsVM.groups {
            items.append(UnifiedChatItem(
                id: groupItem.group.id,
                title: groupItem.title,
                avatarURL: groupItem.avatar.flatMap { URL(string: $0) },
                lastMessage: groupItem.lastMessage,
                lastTime: groupItem.lastTime,
                isBlocked: false,
                isGroup: true,
                destination: AnyView(GroupChatView(group: groupItem.group))
            ))
        }
        
        return items
    }
    
    // MARK: - Delete
    private func deleteItem(_ item: UnifiedChatItem) {
        if !item.isGroup {
            if let chat = chatsVM.chats.first(where: { $0.chat.id == item.id }) {
                chatsVM.deleteChat(chatId: chat.chat.id) { _ in }
            }
        }
    }
}

// MARK: - Chat Row
struct ModernChatRow: View {
    let item: UnifiedChatItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with gradient border
            ZStack(alignment: .bottomTrailing) {
                if let url = item.avatarURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: item.isGroup ?
                                        [Color.orange.opacity(0.3), Color.pink.opacity(0.3)] :
                                        [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: item.isGroup ? "person.3.fill" : "person.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 24))
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: item.isGroup ?
                                        [Color.orange, Color.pink] :
                                        [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: item.isGroup ?
                                    [Color.orange.opacity(0.3), Color.pink.opacity(0.3)] :
                                    [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: item.isGroup ? "person.3.fill" : "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 24))
                        )
                        .frame(width: 60, height: 60)
                }
                
                // Online/Group
                if !item.isGroup {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                } else {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                        .padding(4)
                        .background(Circle().fill(Color.black))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if item.isBlocked {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                Text(item.lastMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                if let time = item.lastTime {
                    Text(time, format: .dateTime.hour().minute())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                // Unread indicator
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .opacity(0)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Supporting Types
enum ChatFilterTab: String, CaseIterable {
    case all = "Tất cả"
    case chats = "Chats"
    case groups = "Nhóm"
}

struct UnifiedChatItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let avatarURL: URL?
    let lastMessage: String
    let lastTime: Date?
    let isBlocked: Bool
    let isGroup: Bool
    let destination: AnyView
    
    static func == (lhs: UnifiedChatItem, rhs: UnifiedChatItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.dark)
    }
}
