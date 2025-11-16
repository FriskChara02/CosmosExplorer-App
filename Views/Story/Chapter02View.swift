//
//  Chapter02View.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 12/11/25.
//

import SwiftUI

struct Chapter02View: View {
    var onComplete: () -> Void
    @State private var showCompleteButton = true
    @State private var appeared = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showConfetti = false
    @Environment(\.presentationMode) var presentationMode

    private let storyKey = "chapter02_story"
    private let funFactsKey = "chapter02_funfacts"

    var body: some View {
        ZStack {
            // Animated parallax background
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
                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3), Color.black.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating stars animation
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: CGFloat.random(in: 5...15)))
                        .foregroundColor(.yellow.opacity(Double.random(in: 0.4...0.9)))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .scaleEffect(appeared ? 1 : 0.3)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 1...3))
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

                    // Chapter Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Chapter 02")
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
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                .shadow(color: .yellow.opacity(0.8), radius: 10)
                        }

                        Text(LanguageManager.current.string("Stars and Their Secrets"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .yellow, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                            .shadow(color: .orange.opacity(0.5), radius: 20)

                        Rectangle()
                            .fill(LinearGradient(colors: [.yellow, .orange, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 3)
                            .frame(maxWidth: 150)
                    }
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                    // === STORY PARAGRAPHS (Trước) ===
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
                            Text("Did You Know?")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 24)

                            ForEach(funFactLines.indices, id: \.self) { index in
                                let funFact = funFactLines[index]
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 24, height: 24)
                                            .shadow(color: .yellow.opacity(0.6), radius: 5)
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 12))
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
                                                .fill(LinearGradient(colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .shadow(color: .orange.opacity(0.3), radius: 10)
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
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(20)
                            .shadow(color: .yellow.opacity(0.5), radius: 15, x: 0, y: 10)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
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
                StarConfettiView()
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
struct StarConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                Image(systemName: ["star.fill", "sparkles", "star.circle.fill"].randomElement()!)
                    .font(.system(size: CGFloat.random(in: 10...25)))
                    .foregroundColor([.yellow, .orange, .white, .cyan].randomElement()!)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .rotationEffect(.degrees(animate ? 360 : 0))
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

#Preview {
    Chapter02View(onComplete: {})
}
