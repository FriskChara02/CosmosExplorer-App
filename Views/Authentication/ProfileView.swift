//
//  ProfileView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI
import SwiftData
import Foundation
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var errorMessage: String?
    @State private var currentUser: UserModel?
    @State private var isLoaded = false
    @State private var showLogoutConfirmation = false
    @State private var isEditing = false
    @State private var isLoadingUser = false
    
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
            
            ScrollView {
                VStack(spacing: 25) {
                    // MARK: - Header: Back + Title + Edit
                    headerView
                    
                    // MARK: - Avatar Section
                    avatarSection
                    
                    // MARK: - Username & Rank
                    userInfoSection
                    
                    // MARK: - Bio Section
                    bioSection
                    
                    // MARK: - User Info Cards
                    infoCardsSection
                    
                    // MARK: - Sign Out Button
                    signOutButton
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical, 10)
            }
        }
        .background(Image("cosmos_background1").resizable().scaledToFill().ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadCurrentUser()
            withAnimation { isLoaded = true }
        }
        .overlay {
            if isLoadingUser {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.7))
            }
        }
        .sheet(isPresented: $isEditing) {
            if let user = currentUser {
                EditProfileView(user: user) {
                    loadCurrentUser()
                } onDelete: {
                    viewModel.signOut()
                    dismiss()
                }
            } else {
                ProgressView("Đang tải thông tin...")
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.9))
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.15)))
                    .shadow(color: .white.opacity(0.1), radius: 8)
            }
            
            Spacer()
            
            Text(LanguageManager.current.string("Profile"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Spacer()
            
            Button {
                isEditing = true
            } label: {
                Image(systemName: "pencil")
                    .font(.title2.bold())
                    .foregroundColor(currentUser != nil ? .white : .white.opacity(0.4))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.15)))
                    .shadow(color: .white.opacity(0.1), radius: 8)
            }
            .disabled(currentUser == nil)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : -20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isLoaded)
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        ZStack {
            Circle()
                .fill(getRankUIColor().opacity(0.3))
                .frame(width: 140, height: 140)
                .blur(radius: 20)
            
            if let avatar = currentUser?.avatar, let url = URL(string: avatar) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty, .failure:
                        placeholderAvatar
                    @unknown default:
                        placeholderAvatar
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [getRankUIColor(), getRankUIColor().opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                )
            } else {
                placeholderAvatar
            }
        }
        .scaleEffect(isLoaded ? 1 : 0.8)
        .opacity(isLoaded ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isLoaded)
    }
    
    // MARK: - User Info
    private var userInfoSection: some View {
        VStack(spacing: 12) {
            Text(currentUser?.username ?? "Guest User")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(isLoaded ? 1 : 0)
                .offset(y: isLoaded ? 0 : 10)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isLoaded)
            
            rankBadge
        }
    }
    
    // MARK: - Rank
    private var rankBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(getRankUIColor())
                .frame(width: 10, height: 10)
                .shadow(color: getRankUIColor().opacity(0.5), radius: 4, x: 0, y: 2)
            
            Text(currentUser?.getRankColor() ?? "Trắng")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(getRankUIColor())
            
            Text("•").foregroundColor(.white.opacity(0.3))
            
            Text("Elo \(currentUser?.rank ?? 0)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            
            Text("•").foregroundColor(.white.opacity(0.3))
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                Text("\(currentUser?.score ?? 0)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
        )
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 10)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: isLoaded)
    }
    
    // MARK: - Bio Section
    private var bioSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Tiểu sử")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(currentUser?.bio?.isEmpty == false ? currentUser!.bio! : "Chưa có tiểu sử")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        )
        .padding(.horizontal, 20)
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 15)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isLoaded)
    }
    
    // MARK: - Info Cards Section
    private var infoCardsSection: some View {
        VStack(spacing: 12) {
            ModernInfoCard(icon: "envelope.fill", title: "Email", value: currentUser?.email ?? "N/A", accentColor: .blue)
                .opacity(isLoaded ? 1 : 0)
                .offset(x: isLoaded ? 0 : -20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.45), value: isLoaded)
            
            if let description = currentUser?.userDescription, !description.isEmpty {
                ModernInfoCard(icon: "quote.bubble.fill", title: "Mô tả", value: description, accentColor: .cyan)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.48), value: isLoaded)
            }
            
            if let dateOfBirth = currentUser?.dateOfBirth {
                ModernInfoCard(icon: "calendar", title: "Ngày sinh", value: DateHelper.formatDate(dateOfBirth), accentColor: .orange)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.52), value: isLoaded)
            }
            
            if let location = currentUser?.location, !location.isEmpty {
                ModernInfoCard(icon: "location.fill", title: "Vị trí", value: location, accentColor: .green)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.55), value: isLoaded)
            }
            
            if let gender = currentUser?.gender, !gender.isEmpty {
                ModernInfoCard(icon: "person.fill", title: "Giới tính", value: gender.capitalized, accentColor: .purple)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.58), value: isLoaded)
            }
            
            if let hobbies = currentUser?.hobbies, !hobbies.isEmpty {
                ModernInfoCard(icon: "star.fill", title: "Sở thích", value: hobbies, accentColor: .yellow)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.62), value: isLoaded)
            }
            
            HStack(spacing: 12) {
                ModernStatusCard(icon: "circle.fill", title: "Trạng thái", value: (currentUser?.status ?? "offline").capitalized, status: currentUser?.status ?? "offline")
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: isLoaded)
                
                ModernRoleCard(icon: "shield.fill", title: "Vai trò", value: (currentUser?.role ?? "user").capitalized, role: currentUser?.role ?? "user")
                    .opacity(isLoaded ? 1 : 0)
                    .offset(x: isLoaded ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: isLoaded)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                Text(LanguageManager.current.string("Sign Out"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .opacity(isLoaded ? 1 : 0)
        .offset(y: isLoaded ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.75), value: isLoaded)
        .alert("Đăng xuất", isPresented: $showLogoutConfirmation) {
            Button("Hủy", role: .cancel) { }
            Button("Đăng xuất", role: .destructive) {
                withAnimation { viewModel.signOut() }
            }
        } message: { Text("Bạn có chắc chắn muốn đăng xuất không?") }
    }
    
    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundStyle(LinearGradient(colors: [.gray.opacity(0.8), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                .frame(width: 120, height: 120)
        }
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(colors: [getRankUIColor(), getRankUIColor().opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 4
                )
        )
    }
    
    // MARK: - Load Current User
    private func loadCurrentUser() {
        isLoadingUser = true
        
        viewModel.loadCurrentUserIfNeeded { user in
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoadingUser = false
                withAnimation { self.isLoaded = true }
            }
        }
    }
    
    // MARK: - Rank Color
    private func getRankUIColor() -> Color {
        let rank = currentUser?.rank ?? 2000
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

// MARK: - Edit Profile Sheet
struct EditProfileView: View {
    @Bindable var user: UserModel
    @EnvironmentObject private var viewModel: AuthViewModel
    let onSave: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    // MARK: - Avatar Picker
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var isUploadingAvatar = false
    
    // MARK: - Gender Selection
    @State private var selectedGender = "Khác"
    private let genders = ["Nam", "Nữ", "Khác"]
    
    // MARK: - Text Fields State
    @State private var usernameText: String = ""
    @State private var bioText: String = ""
    @State private var userDescriptionText: String = ""
    @State private var locationText: String = ""
    @State private var hobbiesText: String = ""
    @State private var selectedDateOfBirth = Date()
    
    var body: some View {
        NavigationView {
            Form {
                avatarSection
                basicInfoSection
                descriptionSection
                personalInfoSection
                actionsSection
            }
            .navigationTitle("Chỉnh sửa hồ sơ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        Task { await saveChanges() }
                    }
                    .disabled(isUploadingAvatar)
                }
            }
            .onAppear {
                initializeFields()
            }
            .alert("Xóa tài khoản vĩnh viễn?", isPresented: $showDeleteConfirmation) {
                Button("Hủy", role: .cancel) { }
                Button("Xóa", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Bạn sẽ mất toàn bộ dữ liệu và không thể khôi phục.")
            }
        }
    }
    
    // MARK: - Avatar
    private var avatarSection: some View {
        Section("Ảnh đại diện") {
            avatarDisplay
            avatarPicker
        }
    }
    
    private var avatarDisplay: some View {
        HStack {
            Spacer()
            ZStack {
                avatarImageView
                
                if isUploadingAvatar {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
            .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 3))
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
    
    private var avatarImageView: some View {
        Group {
            if let avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else if let avatarURL = user.avatar, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        defaultAvatarIcon
                    }
                }
            } else {
                defaultAvatarIcon
            }
        }
    }
    
    private var defaultAvatarIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.gray.opacity(0.6))
    }
    
    private var avatarPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Label("Chọn ảnh từ thư viện", systemImage: "photo.on.rectangle")
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                await handlePhotoSelection(newItem)
            }
        }
    }
    
    // MARK: - Basic Info
    private var basicInfoSection: some View {
        Section("Thông tin cơ bản") {
            TextField("Tên người dùng", text: $usernameText)
            TextField("Email", text: $user.email)
                .disabled(true)
                .foregroundColor(.secondary)
            TextField("Tiểu sử (Bio)", text: $bioText, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        Section("Mô tả bản thân") {
            TextEditor(text: $userDescriptionText)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Personal Info
    private var personalInfoSection: some View {
        Section("Thông tin cá nhân") {
            DatePicker("Ngày sinh", selection: $selectedDateOfBirth, displayedComponents: .date)
                .datePickerStyle(.compact)
            
            TextField("Vị trí", text: $locationText)
            
            Picker("Giới tính", selection: $selectedGender) {
                ForEach(genders, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
            
            TextField("Sở thích", text: $hobbiesText)
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        Section {
            Button("Xóa tài khoản", role: .destructive) {
                showDeleteConfirmation = true
            }
        }
    }
    
    // MARK: - Helper Methods
    private func initializeFields() {
        usernameText = user.username ?? ""
        bioText = user.bio ?? ""
        userDescriptionText = user.userDescription ?? ""
        locationText = user.location ?? ""
        hobbiesText = user.hobbies ?? ""
        selectedGender = user.gender ?? "Khác"
        selectedDateOfBirth = user.dateOfBirth ?? Date()
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                avatarImage = Image(uiImage: uiImage)
                await uploadAvatar(data)
            }
        } catch {
            print("Lỗi load ảnh: \(error)")
        }
    }
    
    private func uploadAvatar(_ data: Data) async {
        isUploadingAvatar = true
        let base64String = data.base64EncodedString()
        let realImageURL = "data:image/png;base64,\(base64String)"
        
        await MainActor.run {
            user.avatar = realImageURL
            isUploadingAvatar = false
        }
    }
    
    private func saveChanges() async {
        user.username = usernameText.isEmpty ? nil : usernameText
        user.bio = bioText.isEmpty ? nil : bioText
        user.userDescription = userDescriptionText.isEmpty ? nil : userDescriptionText
        user.location = locationText.isEmpty ? nil : locationText
        user.hobbies = hobbiesText.isEmpty ? nil : hobbiesText
        user.gender = selectedGender == "Khác" ? nil : selectedGender
        user.dateOfBirth = selectedDateOfBirth
        
        SwiftDataService().updateUser(user)
        
        if let context = user.modelContext {
            context.delete(user)
            try? context.save()
        }
        
        await MainActor.run {
            onSave()
            dismiss()
        }
    }
    
    private func deleteAccount() {
        SwiftDataService().deleteUser(user)
        
        Task { @MainActor in
            AuthManager.shared.signOut()
            viewModel.signOut()
            onDelete()
            dismiss()
        }
    }
}


// MARK: - Info Card Component
struct ModernInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            iconCircle
            infoText
            Spacer()
        }
        .padding(16)
        .background(cardBackground)
    }
    
    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(accentColor)
        }
    }
    
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(colors: [accentColor.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
    }
}

// MARK: - Status Card Component
struct ModernStatusCard: View {
    let icon: String
    let title: String
    let value: String
    let status: String
    
    var statusColor: Color {
        switch status.lowercased() {
        case "online": return .green
        case "offline": return .gray
        case "idle": return .yellow
        case "dnd": return .red
        case "invisible": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            statusIcon
            statusTitle
            statusValue
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(cardBackground)
    }
    
    private var statusIcon: some View {
        ZStack {
            Circle().fill(statusColor.opacity(0.2)).frame(width: 40, height: 40)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(statusColor)
        }
    }
    
    private var statusTitle: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.5))
            .textCase(.uppercase)
    }
    
    private var statusValue: some View {
        Text(value)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.06))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(statusColor.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Role Card Component
struct ModernRoleCard: View {
    let icon: String
    let title: String
    let value: String
    let role: String
    
    var roleColor: Color {
        switch role.lowercased() {
        case "super_admin": return .red
        case "admin": return .orange
        case "user": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            roleIcon
            roleTitle
            roleValue
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(cardBackground)
    }
    
    private var roleIcon: some View {
        ZStack {
            Circle().fill(roleColor.opacity(0.2)).frame(width: 40, height: 40)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(roleColor)
        }
    }
    
    private var roleTitle: some View {
        Text(title)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.5))
            .textCase(.uppercase)
    }
    
    private var roleValue: some View {
        Text(value)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.06))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(roleColor.opacity(0.3), lineWidth: 1))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .modelContainer(for: UserModel.self)
    }
}
