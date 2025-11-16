//
//  Chapter03View.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 12/11/25.
//

import SwiftUI

struct Chapter03View: View {
    var onComplete: () -> Void
    @State private var showCompleteButton = true
    @State private var appeared = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showConfetti = false
    @Environment(\.presentationMode) var presentationMode

    private let storyKey = "chapter03_story"
    private let funFactsKey = "chapter03_funfacts"

    var body: some View {
        ZStack {
            // Parallax background
            GeometryReader { geometry in
                Image("BlackBG2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height + 100)
                    .offset(y: scrollOffset * 0.3)
                    .clipped()
            }
            .ignoresSafeArea()

            // Gradient overlay
            LinearGradient(
                colors: [Color.indigo.opacity(0.4), Color.purple.opacity(0.3), Color.black.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating cosmic particles
            ZStack {
                ForEach(0..<35, id: \.self) { i in
                    Circle()
                        .fill(RadialGradient(colors: [.white, .cyan.opacity(0.6), .clear], center: .center, startRadius: 0, endRadius: 6))
                        .frame(width: CGFloat.random(in: 3...12))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .opacity(Double.random(in: 0.4...0.9))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: appeared
                        )
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Back Button
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
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

                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Chapter 03")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.cyan.opacity(0.2))
                                        .shadow(color: .cyan.opacity(0.6), radius: 10)
                                )
                            Spacer()
                            Image(systemName: "infinity.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: .cyan.opacity(0.8), radius: 10)
                                .rotationEffect(.degrees(appeared ? 0 : 180))
                                .animation(.spring(response: 1.5, dampingFraction: 0.6).delay(0.5), value: appeared)
                        }

                        Text(LanguageManager.current.string("Life and Death in the Universe"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .cyan, .blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 10)
                            .shadow(color: .purple.opacity(0.5), radius: 20)

                        Rectangle()
                            .fill(LinearGradient(colors: [.cyan, .blue, .purple, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 3)
                            .frame(maxWidth: 150)
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                    // === STORY (Trước) ===
                    let storyText = LanguageManager.current.string(storyKey)
                    let storyParagraphs = storyText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                    ForEach(storyParagraphs.indices, id: \.self) { index in
                        let paragraph = storyParagraphs[index]
                        Text(paragraph)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                            .lineSpacing(10)
                            .opacity(appeared ? 1 : 0)
                            .offset(x: appeared ? 0 : -30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15 + 0.4), value: appeared)
                    }
                    .padding(.horizontal, 24)

                    // === FUN FACTS (Sau Story) ===
                    let funFactsText = LanguageManager.current.string(funFactsKey)
                    let funFactLines = funFactsText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                    if !funFactLines.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Cosmic Secrets")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 24)

                            ForEach(funFactLines.indices, id: \.self) { index in
                                let funFact = funFactLines[index]
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(RadialGradient(colors: [.cyan, .blue, .purple], center: .center, startRadius: 0, endRadius: 15))
                                            .frame(width: 24, height: 24)
                                            .shadow(color: .cyan.opacity(0.8), radius: 8)
                                        Image(systemName: "atom")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 4)

                                    Text(funFact)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineSpacing(8)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(LinearGradient(colors: [Color.cyan.opacity(0.15), Color.blue.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .shadow(color: .cyan.opacity(0.3), radius: 10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(LinearGradient(colors: [.cyan.opacity(0.5), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                                )
                                        )
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(x: appeared ? 0 : -30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15 + 0.6), value: appeared)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }

                    // Complete Button
                    if showCompleteButton {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                            impactFeedback.impactOccurred()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showConfetti = true
                                onComplete()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showCompleteButton = false
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                Text(LanguageManager.current.string("I've Finished Reading"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "infinity")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(20)
                            .shadow(color: .cyan.opacity(0.5), radius: 15, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.5), .cyan.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: appeared)
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }

            // Confetti
            if showConfetti {
                CosmicConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation { appeared = true }
        }
    }
}

// === Confetti View ===
struct CosmicConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<60, id: \.self) { i in
                let shapes = ["circle.fill", "star.fill", "sparkles", "infinity", "atom"]
                Image(systemName: shapes.randomElement()!)
                    .font(.system(size: CGFloat.random(in: 8...20)))
                    .foregroundColor([.cyan, .blue, .purple, .white, .indigo].randomElement()!)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...720) : 0))
                    .animation(
                        Animation.easeIn(duration: Double.random(in: 2...5))
                            .delay(Double.random(in: 0...0.6)),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    Chapter03View(onComplete: {})
}
