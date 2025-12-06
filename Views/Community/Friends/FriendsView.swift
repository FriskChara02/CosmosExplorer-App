//
//  FriendsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FriendsViewModel()
    @StateObject private var chatsVM = ChatsViewModel()
    @State private var searchText = ""
    @State private var selectedTab = 0
    
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
                    
                    modernSegmentedControl
                    
                    // Content
                    if selectedTab == 0 {
                        friendsList
                    } else if selectedTab == 1 {
                        requestsList
                    } else {
                        suggestedList
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Tìm kiếm bạn bè...")
            .navigationBarHidden(true)
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    let context = SwiftDataService.shared.container.mainContext
                    viewModel.setCurrentUser(userId, context: context)
                    chatsVM.setCurrentUser(userId, context: context)
                }
            }
            .onChange(of: searchText) { _, newValue in
                if let userId = authViewModel.currentUser?.id {
                    viewModel.searchUsers(query: newValue, userId: userId)
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
                Text("Bạn bè")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(viewModel.friends.count) người bạn")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Segmented Control
    private var modernSegmentedControl: some View {
        HStack(spacing: 0) {
            segmentButton(title: "Bạn bè", icon: "person.2.fill", index: 0)
            segmentButton(title: "Lời mời", icon: "envelope.badge.fill", index: 1)
            segmentButton(title: "Gợi ý", icon: "sparkles", index: 2)
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
    
    private func segmentButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedTab == index ?
                          LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing))
            )
        }
    }
    
    // MARK: - Friends List
    private var friendsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.friends) { friend in
                    NavigationLink(destination: ProfileViewForFriend(userId: friend.userId)) {
                        modernFriendRow(friend: friend)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button {
                            openPrivateChat(with: friend.userId)
                        } label: {
                            Label("Nhắn tin", systemImage: "message.fill")
                        }
                        
                        Button(role: .destructive) {
                            deleteFriend(friend.userId)
                        } label: {
                            Label("Xóa bạn", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Friend Row
    private func modernFriendRow(friend: FriendDisplayModel) -> some View {
        HStack(spacing: 14) {
            // Avatar - online
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: friend.avatar ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
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
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                
                // Online status
                Circle()
                    .fill(Color.green)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(friend.username)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.green)
                    
                    Text(friend.status ?? "Đang hoạt động")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Message button
            Button {
                openPrivateChat(with: friend.userId)
            } label: {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .buttonStyle(PlainButtonStyle())
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
    
    // MARK: - Requests List
    private var requestsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.friendRequests) { user in
                    modernRequestRow(user: user)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private func modernRequestRow(user: FriendDisplayModel) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Muốn kết bạn với bạn")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button {
                    viewModel.acceptFriendRequest(from: user.userId) { _ in }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text("Chấp nhận")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                
                Button {
                    viewModel.rejectFriendRequest(from: user.userId) { _ in }
                } label: {
                    Text("Từ chối")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.5))
                        )
                }
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
    
    // MARK: - Suggested List
    private var suggestedList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.suggestedUsers) { user in
                    modernSuggestedRow(user: user)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private func modernSuggestedRow(user: FriendDisplayModel) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.username)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(user.bio ?? "Chưa có tiểu sử")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                viewModel.sendFriendRequest(to: user.userId) { _ in }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Kết bạn")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Helper Functions
    private func openPrivateChat(with userId: UUID) {
        chatsVM.getOrCreateChat(withUserId: userId) { chat in
            guard let chat = chat else { return }
            if let friend = viewModel.friends.first(where: { $0.userId == userId }) {
                let otherUser = UserModel(
                    id: friend.userId,
                    email: "",
                    username: friend.username,
                    password: "",
                    avatar: friend.avatar
                )
                let chatDisplay = ChatDisplayModel(
                    id: userId,
                    chat: chat,
                    otherUser: otherUser,
                    currentUserId: authViewModel.currentUser!.id
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    let chatWithNav = NavigationView {
                        ChatDetailView(chat: chatDisplay)
                            .environmentObject(authViewModel)
                            .navigationBarTitleDisplayMode(.inline)
                    }

                    let chatVC = UIHostingController(rootView: chatWithNav)
                    chatVC.modalPresentationStyle = .fullScreen
                    rootVC.present(chatVC, animated: true)
                }
            }
        }
    }
    
    private func deleteFriend(_ friendId: UUID) {
        guard let currentUserId = authViewModel.currentUser?.id else { return }
        
        Task {
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let stmt = try connection.prepareStatement(text: """
                    DELETE FROM friendships
                    WHERE (user_id1 = $1 AND user_id2 = $2)
                       OR (user_id1 = $2 AND user_id2 = $1)
                    """)
                defer { stmt.close() }
                try stmt.execute(parameterValues: [
                    currentUserId.uuidString,
                    friendId.uuidString
                ])
                
                let chatStmt = try connection.prepareStatement(text: """
                    DELETE FROM chats
                    WHERE (participant1_id = $1 AND participant2_id = $2)
                       OR (participant1_id = $2 AND participant2_id = $1)
                    """)
                defer { chatStmt.close() }
                try chatStmt.execute(parameterValues: [
                    currentUserId.uuidString,
                    friendId.uuidString
                ])
                
                await MainActor.run {
                    viewModel.loadFriends(userId: currentUserId)
                    NotificationCenter.default.post(name: NSNotification.Name("FriendAcceptedReloadChats"), object: nil)
                }
            } catch {
                print("Lỗi xóa bạn: \(error)")
            }
        }
    }
}

// MARK: - ProfileViewForFriend & ProfileViewContent
struct ProfileViewForFriend: View {
    let userId: UUID
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var friendUser: UserModel?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.85),
                    Color(red: 0.05, green: 0.05, blue: 0.15).opacity(0.9),
                    Color.black.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Đang tải hồ sơ...")
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.6))
            }
            else if let user = friendUser {
                ProfileViewContent(user: user, isOwnProfile: false)
            }
            else {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text(errorMessage ?? "Không tìm thấy người dùng")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .background(Image("cosmos_background1").resizable().scaledToFill().ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadFriendProfile()
        }
    }
    
    private func loadFriendProfile() {
        isLoading = true
        
        authViewModel.fetchUserFromServer(id: userId.uuidString) { fetchedUser in
            DispatchQueue.main.async {
                self.isLoading = false
                if let fetchedUser = fetchedUser {
                    self.friendUser = fetchedUser
                } else {
                    self.errorMessage = "Người dùng không tồn tại hoặc đã bị xóa"
                }
            }
        }
    }
}

struct ProfileViewContent: View {
    let user: UserModel
    let isOwnProfile: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.15)))
                    }
                    
                    Spacer()
                    
                    Text(isOwnProfile ? LanguageManager.current.string("Profile") : "Hồ sơ")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Spacer()
                    
                    if isOwnProfile {
                        NavigationLink {
                            if let context = user.modelContext {
                                EditProfileView(user: user) { }
                                    onDelete: { }
                                    .modelContext(context)
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.15)))
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                avatarSection
                
                VStack(spacing: 12) {
                    Text(user.username ?? "Người dùng bí ẩn")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    rankBadge
                }
                
                bioSection
                
                infoCardsSection
                
                Spacer(minLength: 50)
            }
            .padding(.vertical, 10)
        }
    }
    
    private var avatarSection: some View {
        ZStack {
            Circle()
                .fill(rankColor(for: user.rank).opacity(0.3))
                .frame(width: 140, height: 140)
                .blur(radius: 20)
            
            if let avatar = user.avatar, let url = URL(string: avatar) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        placeholderAvatar
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(colors: [rankColor(for: user.rank), rankColor(for: user.rank).opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4))
            } else {
                placeholderAvatar
            }
        }
    }
    
    private var placeholderAvatar: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 120, height: 120)
            .foregroundStyle(LinearGradient(colors: [.gray.opacity(0.8), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom))
            .overlay(Circle().stroke(LinearGradient(colors: [.white, .white.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4))
    }
    
    private var rankBadge: some View {
        HStack(spacing: 8) {
            Circle().fill(rankColor(for: user.rank)).frame(width: 10, height: 10)
            Text(user.getRankColor())
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(rankColor(for: user.rank))
            Text("•").foregroundColor(.white.opacity(0.3))
            Text("Elo \(user.rank)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            Text("•").foregroundColor(.white.opacity(0.3))
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(user.score)").foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Capsule().fill(Color.white.opacity(0.08)).overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)))
    }
    
    private var bioSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Tiểu sử")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text(user.bio?.isEmpty == false ? user.bio! : "Chưa có tiểu sử")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1)))
        .padding(.horizontal, 20)
    }
    
    private var infoCardsSection: some View {
        VStack(spacing: 12) {
            ModernInfoCard(icon: "envelope.fill", title: "Email", value: user.email, accentColor: .blue)
            if let desc = user.userDescription, !desc.isEmpty {
                ModernInfoCard(icon: "quote.bubble.fill", title: "Mô tả", value: desc, accentColor: .cyan)
            }
            if let dob = user.dateOfBirth {
                ModernInfoCard(icon: "calendar", title: "Ngày sinh", value: DateHelper.formatDate(dob), accentColor: .orange)
            }
            if let loc = user.location, !loc.isEmpty {
                ModernInfoCard(icon: "location.fill", title: "Vị trí", value: loc, accentColor: .green)
            }
            if let gender = user.gender, !gender.isEmpty {
                ModernInfoCard(icon: "person.fill", title: "Giới tính", value: gender.capitalized, accentColor: .purple)
            }
            if let hobbies = user.hobbies, !hobbies.isEmpty {
                ModernInfoCard(icon: "star.fill", title: "Sở thích", value: hobbies, accentColor: .yellow)
            }
            
            HStack(spacing: 12) {
                ModernStatusCard(icon: "circle.fill", title: "Trạng thái", value: (user.status ?? "offline").capitalized, status: user.status ?? "offline")
                ModernRoleCard(icon: "shield.fill", title: "Vai trò", value: (user.role ?? "user").capitalized, role: user.role ?? "user")
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1..<1000: return .green
        case 1000..<1200: return .blue
        case 1200..<1400: return .purple
        case 1400..<1600: return .yellow
        case 1600..<999999: return .red
        default: return .white
        }
    }
}

struct ProfileViewForFriend_Previews: PreviewProvider {
    static var previews: some View {
        ProfileViewForFriend(userId: UUID())
            .environmentObject(AuthViewModel())
    }
}
