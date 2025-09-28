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
            VStack(spacing: 20) {
                Text(languageManager.string("Settings"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Picker(languageManager.string("Language"), selection: $selectedLanguage) {
                    Text(languageManager.string("English")).tag("en")
                    Text(languageManager.string("Vietnamese")).tag("vi")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 30)
                .onChange(of: selectedLanguage) { oldValue, newValue in
                    if newValue != languageManager.currentLanguage {
                        showConfirmationAlert = true
                    }
                }
                
                Spacer()
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
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(languageManager.string("Are you sure you want to change the language?"), isPresented: $showConfirmationAlert) {
                Button(languageManager.string("Cancel"), role: .cancel) {
                    selectedLanguage = languageManager.currentLanguage
                }
                Button(languageManager.string("Yes")) {
                    languageManager.currentLanguage = selectedLanguage
                    showRestartAlert = true
                }
            }
            .alert(languageManager.string("Language Changed"), isPresented: $showRestartAlert) {
                Button(languageManager.string("OK")) {
                    dismiss()
                }
            } message: {
                Text(languageManager.string("The language has been changed to \(selectedLanguage == "en" ? "English" : "Vietnamese")."))
            }
        }
    }
}

#Preview {
    SettingsView()
}
