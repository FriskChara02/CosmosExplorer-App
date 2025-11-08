//
//  ZodiacSecretView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import SwiftUI

struct ZodiacSecretView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.clear
                    .background(
                        Image("cosmos_background1")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.4), Color.purple.opacity(0.1)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView

                        // MENU BUTTONS
                        VStack(spacing: 16) {
                            ZodiacButton(
                                title: LanguageManager.current.string("secret_golden_pairs"),
                                icon: "star.fill",
                                gradient: [Color.yellow.opacity(0.8), Color.orange.opacity(0.7)],
                                destination: GoldenPairsView()
                            )

                            ZodiacButton(
                                title: LanguageManager.current.string("secret_quick_love"),
                                icon: "flame.fill",
                                gradient: [Color.red.opacity(0.8), Color.orange.opacity(0.7)],
                                destination: QuickLoveView()
                            )

                            ZodiacButton(
                                title: LanguageManager.current.string("secret_incompatible"),
                                icon: "xmark.circle.fill",
                                gradient: [Color.gray.opacity(0.8), Color.black.opacity(0.7)],
                                destination: IncompatiblePairsView()
                            )

                            ZodiacButton(
                                title: LanguageManager.current.string("secret_forbidden_colors"),
                                icon: "paintpalette.fill",
                                gradient: [Color.purple.opacity(0.8), Color.indigo.opacity(0.7)],
                                destination: ForbiddenColorsView()
                            )
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 50)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left.circle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)

                Text(LanguageManager.current.string("zodiac_secret_title"))
                    .font(.custom("Audiowide", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)

            Spacer()
        }
        .padding(.horizontal, 8)
        .background(
            Color.purple.opacity(0.2)
                .blur(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.purple.opacity(0.8), lineWidth: 1)
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Golden Pairs View
struct GoldenPairsView: View {
    var body: some View {
        SecretDetailView(
            title: LanguageManager.current.string("secret_golden_pairs"),
            icon: "star.fill",
            content: LanguageManager.current.string("secret_golden_pairs_content")
        )
    }
}

// MARK: - Quick Love View
struct QuickLoveView: View {
    var body: some View {
        SecretDetailView(
            title: LanguageManager.current.string("secret_quick_love"),
            icon: "flame.fill",
            content: LanguageManager.current.string("secret_quick_love_content")
        )
    }
}

// MARK: - Incompatible Pairs View
struct IncompatiblePairsView: View {
    var body: some View {
        SecretDetailView(
            title: LanguageManager.current.string("secret_incompatible"),
            icon: "xmark.circle.fill",
            content: LanguageManager.current.string("secret_incompatible_content")
        )
    }
}

// MARK: - Forbidden Colors View
struct ForbiddenColorsView: View {
    var body: some View {
        SecretDetailView(
            title: LanguageManager.current.string("secret_forbidden_colors"),
            icon: "paintpalette.fill",
            content: LanguageManager.current.string("secret_forbidden_colors_content")
        )
    }
}

// MARK: - Secret Detail View
struct SecretDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let icon: String
    let content: String

    var body: some View {
        ZStack {
            Color.clear
                .background(
                    Image("BlackBG")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.4), Color.purple.opacity(0.1)]),
                        startPoint: .top, endPoint: .bottom
                    )
                )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left.circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)

                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(.white)

                            Text(title)
                                .font(.custom("Audiowide", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)

                        Spacer()
                    }
                    .background(
                        Color.purple.opacity(0.2)
                            .blur(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.purple.opacity(0.8), lineWidth: 1)
                            )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)

                    // Content
                    Text(content)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.95))
                        .lineSpacing(6)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    ZodiacSecretView()
}
