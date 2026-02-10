//
//  GroupsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 20/11/25.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GroupsViewModel()
    @State private var isShowingCreateGroup = false
    
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
                    
                    if viewModel.groups.isEmpty {
                        emptyStateView
                    } else {
                        groupsList
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingCreateGroup) {
                CreateGroupView()
                    .environmentObject(viewModel)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    let context = SwiftDataService.shared.container.mainContext
                    viewModel.setCurrentUser(userId, context: context)
                }
            }
        }
    }
    
    // MARK: - Header
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
                Text("Nhóm")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(viewModel.groups.count) nhóm")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button {
                isShowingCreateGroup = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Groups List
    private var groupsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.groups) { groupItem in
                    NavigationLink(destination: GroupChatView(group: groupItem.group)) {
                        ModernGroupRow(groupItem: groupItem)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                            colors: [Color.orange.opacity(0.2), Color.pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("No groups yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create a group to chat with many friends!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Button {
                isShowingCreateGroup = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create a new group")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Group Row
struct ModernGroupRow: View {
    let groupItem: GroupDisplayModel
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                if let avatar = groupItem.avatar, let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
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
                            .overlay(
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 24))
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
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
                                .font(.system(size: 24))
                        )
                        .frame(width: 60, height: 60)
                }
                
                // Admin badge
                if groupItem.isAdmin {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                        .padding(4)
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(groupItem.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(groupItem.memberCount)")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text(groupItem.lastMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let time = groupItem.lastTime {
                Text(time, format: .dateTime.hour().minute())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
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
}

// MARK: - Create Group View
struct CreateGroupView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var groupsVM = GroupsViewModel()
    @StateObject private var friendsVM = FriendsViewModel()
    
    @State private var groupName = ""
    @State private var selectedFriends: Set<UUID> = []
    @State private var isCreating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Group Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Enter group name...", text: $groupName)
                                .textInputAutocapitalization(.words)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Members Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add member")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(selectedFriends.count) selected")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            if friendsVM.friends.isEmpty {
                                Text("You don't have any friends yet.")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(friendsVM.friends) { friend in
                                        memberSelectionRow(friend: friend)
                                    }
                                }
                            }
                        }
                        
                        // Create Button
                        Button {
                            createGroup()
                        } label: {
                            HStack(spacing: 8) {
                                if isCreating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                Text(isCreating ? "Creating..." : "Create group")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        groupName.trimmingCharacters(in: .whitespaces).isEmpty || selectedFriends.isEmpty || isCreating ?
                                            LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .shadow(
                                        color: groupName.trimmingCharacters(in: .whitespaces).isEmpty || selectedFriends.isEmpty || isCreating ?
                                            Color.clear : Color.orange.opacity(0.4),
                                        radius: 12,
                                        x: 0,
                                        y: 6
                                    )
                            )
                        }
                        .disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty || selectedFriends.isEmpty || isCreating)
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Create a new group")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("Thông báo", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("thành công") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    let context = SwiftDataService.shared.container.mainContext
                    friendsVM.setCurrentUser(userId, context: context)
                    groupsVM.setCurrentUser(userId, context: context)
                }
            }
        }
    }
    
    private func memberSelectionRow(friend: FriendDisplayModel) -> some View {
        Button {
            if selectedFriends.contains(friend.userId) {
                selectedFriends.remove(friend.userId)
            } else {
                selectedFriends.insert(friend.userId)
            }
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: friend.avatar ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Elo \(friend.rank)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(
                            selectedFriends.contains(friend.userId) ?
                                LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if selectedFriends.contains(friend.userId) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                selectedFriends.contains(friend.userId) ?
                                    LinearGradient(colors: [Color.orange.opacity(0.5), Color.pink.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func createGroup() {
        guard authViewModel.currentUser?.id != nil else { return }
        
        isCreating = true
        groupsVM.createGroup(
            title: groupName.trimmingCharacters(in: .whitespaces),
            memberIds: Array(selectedFriends)
        ) { success, groupId in
            DispatchQueue.main.async {
                isCreating = false
                if success {
                    alertMessage = "Group created successfully!"
                } else {
                    alertMessage = "Group creation failed, please try again"
                }
                showAlert = true
            }
        }
    }
}

// MARK: - Preview
struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.dark)
    }
}
