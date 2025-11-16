//
//  Chapter01View.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 12/11/25.
//

import SwiftUI

struct Chapter01View: View {
    var onComplete: () -> Void
    @State private var showCompleteButton = true
    @State private var appeared = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showConfetti = false
    @Environment(\.presentationMode) var presentationMode

    private let storyKey = "chapter01_story"
    private let funFactsKey = "chapter01_funfacts"

    var body: some View {
        ZStack {
            // MARK: - Parallax background
            GeometryReader { geometry in
                Image("BlackBG2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height + 100)
                    .offset(y: scrollOffset * 0.3)
                    .clipped()
            }
            .ignoresSafeArea()

            // MARK: - Gradient overlay
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.4),
                    Color.pink.opacity(0.3),
                    Color.black.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - Floating hearts
            ZStack {
                ForEach(0..<15, id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat.random(in: 10...25)))
                        .foregroundColor(.pink.opacity(Double.random(in: 0.2...0.5)))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: appeared
                        )
                }
            }

            // MARK: - Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // ---- Back button -------------------------------------------------
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(LanguageManager.current.string("Chapters"))
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .shadow(color: .black.opacity(0.3), radius: 5)
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)

                    // ---- Header -------------------------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Chapter 01")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.pink.opacity(0.2))
                                        .shadow(color: .pink.opacity(0.6), radius: 10)
                                )
                            Spacer()
                        }

                        Text(LanguageManager.current.string("Love in the Cosmos"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .pink, .purple],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .shadow(color: .pink.opacity(0.5), radius: 10)
                            .shadow(color: .purple.opacity(0.5), radius: 20)

                        Rectangle()
                            .fill(LinearGradient(colors: [.pink, .purple, .clear],
                                                startPoint: .leading,
                                                endPoint: .trailing))
                            .frame(height: 3)
                            .frame(maxWidth: 150)
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                    // ---- STORY PARAGRAPHS (First) -------------------------------
                    let storyText = LanguageManager.current.string(storyKey)
                    let storyParagraphs = storyText
                        .components(separatedBy: "\n\n")
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                    ForEach(storyParagraphs.indices, id: \.self) { idx in
                        Text(storyParagraphs[idx])
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .lineSpacing(10)
                            .opacity(appeared ? 1 : 0)
                            .offset(x: appeared ? 0 : -30)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(idx) * 0.15 + 0.4),
                                value: appeared
                            )
                    }
                    .padding(.horizontal, 24)

                    // ---- FUN FACTS (After story) --------------------------------
                    let funFactsText = LanguageManager.current.string(funFactsKey)
                    let funFactLines = funFactsText
                        .components(separatedBy: "\n\n")
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                    if !funFactLines.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Love Facts")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.pink)
                                .padding(.horizontal, 24)

                            ForEach(funFactLines.indices, id: \.self) { idx in
                                let fact = funFactLines[idx]
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                        .shadow(color: .yellow.opacity(0.8), radius: 5)
                                        .padding(.top, 4)

                                    Text(fact)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineSpacing(8)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.yellow.opacity(0.15),
                                                                 Color.orange.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .shadow(color: .yellow.opacity(0.3), radius: 10)
                                        )
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(x: appeared ? 0 : -30)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(idx) * 0.15 + 0.6),
                                    value: appeared
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }

                    // ---- Complete button --------------------------------------------
                    if showCompleteButton {
                        Button {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showConfetti = true
                                onComplete()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showCompleteButton = false
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                Text(LanguageManager.current.string("I've Finished Reading"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [.pink, .purple],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(20)
                            .shadow(color: .pink.opacity(0.5), radius: 15, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: appeared)
                    }
                }   // end VStack
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY)
                    }
                )
            }   // end ScrollView
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { scrollOffset = $0 }

            // MARK: - Confetti
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }   // end ZStack
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// MARK: - PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Confetti
struct ConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: CGFloat.random(in: 5...15),
                           height: CGFloat.random(in: 5...15))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .animation(
                        Animation.easeIn(duration: Double.random(in: 2...4))
                            .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

extension Color {
    static var random: Color {
        [.pink, .purple, .yellow, .cyan, .orange, .red, .mint, .indigo]
            .randomElement() ?? .pink
    }
}

#Preview {
    Chapter01View(onComplete: {})
}
