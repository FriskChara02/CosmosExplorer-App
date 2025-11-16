//
//  SettingsView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager.current
    
    @State private var selectedLanguage: String
    @State private var showConfirmationAlert = false
    @State private var showRestartAlert = false
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.current.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    HStack {
                        Text(languageManager.string("Settings"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("❀")
                            .font(.title)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, 16)
                    
                    // MARK: - User Profile Section
                    HStack {
                        // Avatar placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            )
                            .padding(.leading, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tên User") // TODO: Replace with real user name
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("email@example.com") // TODO: Replace with real email
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.trailing, 16)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    // → ProfileView (nếu nhấn)
                    
                    // MARK: - Linked Services
                    HStack {
                        Image(systemName: "rectangle.on.rectangle")
                            .foregroundColor(.white.opacity(0.8))
                        Text(languageManager.string("Linked Services"))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    // → LinkedServicesView (Google, Facebook, Apple)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 16)
                    
                    // MARK: - Social Section
                    sectionHeader(title: "Social", symbol: "✧")
                    
                    settingRow(icon: "person.2", title: "Friends", destination: "FriendsView")
                    settingRow(icon: "rectangle.3.group", title: "Groups", destination: "GroupsView")
                    settingRow(icon: "message", title: "Chatting", destination: "ChattingView")
                    settingRow(icon: "shield.lefthalf.filled", title: "Admin Panel", destination: "AdminPanelView")
                    
                    // MARK: - Customize Section
                    sectionHeader(title: "Customize", symbol: "✦")
                    
                    settingRow(icon: "paintpalette", title: "Theme", destination: "ThemeView")
                    settingRow(icon: "list.bullet.rectangle", title: "Category", destination: "ManageCategoriesView")
                    settingRow(icon: "bell", title: "Notification & Reminder", destination: "NotificationSettingsView")
                    
                    // Language Picker (giữ nguyên logic cũ nhưng đẹp hơn)
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(languageManager.string("Select Language"))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Picker("", selection: $selectedLanguage) {
                            Text("English").tag("en")
                            Text("Tiếng Việt").tag("vi")
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .frame(width: 120)
                        .onChange(of: selectedLanguage) { oldValue, newValue in
                            if newValue != languageManager.currentLanguage {
                                showConfirmationAlert = true
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    
                    // MARK: - Help and Policies
                    sectionHeader(title: "Help and Policies", symbol: "⋆˙⟡")
                    
                    settingRow(icon: "questionmark.circle", title: "Help", destination: "HelpView")
                    settingRow(icon: "lock.shield", title: "Privacy Policy", destination: "PrivacyPolicyView")
                    settingRow(icon: "doc.text", title: "Cosmos Explorer Terms of Service", destination: "TermsOfServiceView")
                    
                    // MARK: - About
                    sectionHeader(title: "About", symbol: "ᝰ.ᐟ")
                    
                    settingRow(icon: "envelope", title: "Send Feedback", destination: "SendFeedbackView")
                    settingRow(icon: "star", title: "Rate Us", destination: "RateUsView")
                    settingRow(icon: "square.and.arrow.up", title: "Share App", destination: "ShareAppView")
                    settingRow(icon: "questionmark.folder", title: "FAQ", destination: "FAQView")
                    
                    // Version
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text("0.0.7")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("cosmos_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Back")
                }
            }
            .navigationBarBackButtonHidden(true)
            
            // MARK: - Language Change Confirmation
            .alert(languageManager.string("Are you sure you want to change the language?"), isPresented: $showConfirmationAlert) {
                Button(languageManager.string("Cancel"), role: .cancel) {
                    selectedLanguage = languageManager.currentLanguage
                }
                Button(languageManager.string("Yes")) {
                    languageManager.currentLanguage = selectedLanguage
                    showRestartAlert = true
                }
            }
            
            // MARK: - Language Changed Alert
            .alert(languageManager.string("Language Changed"), isPresented: $showRestartAlert) {
                Button(languageManager.string("OK")) {
                    dismiss()
                }
            } message: {
                Text(languageManager.string("The language has been changed to \(selectedLanguage == "en" ? "English" : "Vietnamese")."))
            }
        }
    }
    
    // MARK: - Helper: Section Header
    private func sectionHeader(title: String, symbol: String) -> some View {
        HStack {
            Text("\(title) \(symbol)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 16)
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Helper: Setting Row (with arrow)
    private func settingRow(icon: String, title: String, destination: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)
            
            Text(languageManager.string(title))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // → \(destination) (sẽ navigation sau)
    }
}

#Preview {
    SettingsView()
}
