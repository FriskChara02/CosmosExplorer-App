//
//  ChapterListView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 12/11/25.
//

import SwiftUI

struct ChapterListView: View {
    @AppStorage("unlockedChapters") private var unlockedChapters: Int = 1
    @State private var selectedChapter: Int?
    @State private var appeared = false
    @Environment(\.presentationMode) var presentationMode

    private let chapters = [
        (number: "01", titleKey: "Love in the Cosmos", image: "Chapter01", isFinal: false),
        (number: "02", titleKey: "Stars and Their Secrets", image: "Chapter02", isFinal: false),
        (number: "03", titleKey: "Life and Death in the Universe", image: "Chapter03", isFinal: false),
        (number: "04", titleKey: "To be continued...", image: "Chapter04", isFinal: true)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                GeometryReader { geometry in
                    Image("BlackBG2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .ignoresSafeArea()

                // Animated stars
                ZStack {
                    ForEach(0..<30, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 2...4))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...2)),
                                value: appeared
                            )
                            .opacity(appeared ? 1 : 0)
                    }
                }

                // Nội dung chính
                ScrollView {
                    VStack(spacing: 30) {
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
                                    Text(LanguageManager.current.string("Back"))
                                        .font(.system(size: 17))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .shadow(color: .black.opacity(0.2), radius: 5)
                                )
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)

                        // Title
                        VStack(spacing: 8) {
                            Text(LanguageManager.current.string("Story Chapters"))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .cyan, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .cyan.opacity(0.5), radius: 10)
                                .shadow(color: .purple.opacity(0.5), radius: 20)
                            
                            Text(LanguageManager.current.string("Explore the mysteries of the universe"))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)

                        // Chapter Cards
                        ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                            chapterCard(for: index, titleKey: chapter.titleKey)
                                .padding(.horizontal, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(x: appeared ? 0 : -50)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15 + 0.4), value: appeared)

                            if index < chapters.count - 1 {
                                arrowConnector()
                                    .opacity(appeared ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.15 + 0.5), value: appeared)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Chapter Card
    @ViewBuilder
    private func chapterCard(for index: Int, titleKey: String) -> some View {
        let chapter = chapters[index]
        let isUnlocked = index + 1 <= unlockedChapters
        let opacity = isUnlocked || !chapter.isFinal ? 1.0 : 0.5
        
        @State var isPressed = false

        NavigationLink(destination: destinationForChapter(index: index)) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)
                    .shadow(color: isUnlocked ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.3), radius: 15, y: 10)
                
                // Chapter image
                if !chapter.image.isEmpty {
                    Image(chapter.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .cornerRadius(25)
                } else {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 220)
                        .cornerRadius(25)
                }
                
                // Gradient overlay
                LinearGradient(
                    colors: [Color.black.opacity(0.7), .clear, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(25)

                // Content
                VStack(spacing: 8) {
                    HStack {
                        Text(LanguageManager.current.string("Chapter \(chapter.number)"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.cyan.opacity(0.2)).shadow(color: .cyan.opacity(0.5), radius: 5))
                        Spacer()
                        if isUnlocked {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.8), radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text(LanguageManager.current.string(titleKey))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 5)
                        .padding(.horizontal)
                    
                    if isUnlocked {
                        Text(LanguageManager.current.string("Tap to explore"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 20)

                // Locked overlay
                if !isUnlocked {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.7))
                            .blur(radius: 1)
                        
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 70, height: 70)
                                    .shadow(color: .yellow.opacity(0.6), radius: 15)
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            Text(LanguageManager.current.string("Complete previous chapters"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .opacity(opacity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .rotation3DEffect(.degrees(isPressed ? 5 : 0), axis: (x: 1, y: 0, z: 0))
        }
        .disabled(!isUnlocked)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isUnlocked {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
        .onTapGesture {
            if isUnlocked {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            } else {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.warning)
            }
        }
    }

    // MARK: - Arrow Connector
    private func arrowConnector() -> some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(LinearGradient(colors: [.cyan, .purple], startPoint: .top, endPoint: .bottom))
                    .frame(width: 6, height: 6)
                    .shadow(color: .cyan.opacity(0.6), radius: 5)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                        value: appeared
                    )
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Navigation Destination
    @ViewBuilder
    private func destinationForChapter(index: Int) -> some View {
        switch index {
        case 0: Chapter01View(onComplete: { unlockedChapters = max(unlockedChapters, 2) })
        case 1: Chapter02View(onComplete: { unlockedChapters = max(unlockedChapters, 3) })
        case 2: Chapter03View(onComplete: { unlockedChapters = max(unlockedChapters, 4) })
        default: EmptyView()
        }
    }
}

// MARK: - Preview
#Preview {
    ChapterListView()
}
