//
//  ZodiacHomeView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import SwiftUI

struct ZodiacHomeView: View {
    @StateObject private var viewModel = ZodiacViewModel()
    @State private var isRotating = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // BACKGROUND
                Color.clear
                    .background(
                        Image("cosmos_background1")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.purple.opacity(0.3)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                
                Group {
                    Text("12")
                        .font(.custom("Audiowide", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.8), radius: 10)
                        .shadow(color: .blue.opacity(0.6), radius: 20)
                        .scaleEffect(isRotating ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isRotating)
                        .offset(x: 0, y: -335)
                    
                    Text("Z").offset(x: -190, y: -250)
                    Text("O").offset(x: -190, y: -220)
                    Text("D").offset(x: -190, y: -190)
                    Text("I").offset(x: -190, y: -160)
                    Text("A").offset(x: -190, y: -130)
                    Text("C").offset(x: -190, y: -100)
                }
                .font(.custom("Audiowide", size: 10))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .purple.opacity(0.8), radius: 10)
                .shadow(color: .blue.opacity(0.6), radius: 20)
                .scaleEffect(isRotating ? 1.0 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isRotating)

                // MAIN CONTENT
                VStack(spacing: 22) {
                    // Custom Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text(LanguageManager.current.string("back"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        .padding(.leading, 0)
                        Spacer()
                    }
                    .padding(.top, 10)

                    // Title
                    Text(LanguageManager.current.string("zodiac_title"))
                        .font(.custom("Audiowide", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.8), radius: 10)
                        .shadow(color: .blue.opacity(0.6), radius: 20)
                        .padding(.top, 10)
                        .scaleEffect(isRotating ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isRotating)

                    Image("Zodiac_background01")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())

                    // MENU BUTTONS
                    VStack(spacing: 16) {
                        ZodiacButton(
                            title: LanguageManager.current.string("zodiac_legend"),
                            icon: "book.pages.fill",
                            gradient: [Color.indigo.opacity(0.8), Color.purple.opacity(0.7)],
                            destination: ZodiacLegendView()
                        )

                        ZodiacButton(
                            title: LanguageManager.current.string("zodiac_daily"),
                            icon: "calendar.circle.fill",
                            gradient: [Color.teal.opacity(0.8), Color.cyan.opacity(0.7)],
                            destination: ZodiacDailyView()
                        )

                        ZodiacButton(
                            title: LanguageManager.current.string("zodiac_love"),
                            icon: "heart.circle.fill",
                            gradient: [Color.pink.opacity(0.8), Color.red.opacity(0.7)],
                            destination: ZodiacLoveView()
                        )

                        ZodiacButton(
                            title: LanguageManager.current.string("zodiac_rank"),
                            icon: "crown.fill",
                            gradient: [Color.yellow.opacity(0.8), Color.orange.opacity(0.7)],
                            destination: ZodiacRankView()
                        )

                        ZodiacButton(
                            title: LanguageManager.current.string("zodiac_secret"),
                            icon: "book.circle.fill",
                            gradient: [Color.blue.opacity(0.8), Color.blue.opacity(0.7)],
                            destination: ZodiacSecretView()
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear { isRotating = true }
        }
    }
}

// BUTTON
struct ZodiacButton<Destination: View>: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let destination: Destination
    @State private var isPressed = false

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: gradient.first?.opacity(0.6) ?? .clear,
                    radius: isPressed ? 5 : 12, x: 0, y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ZodiacHomeView()
}
