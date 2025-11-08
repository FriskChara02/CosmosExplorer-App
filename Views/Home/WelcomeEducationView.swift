//
//  WelcomeEducationView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 30/10/25.
//

import SwiftUI

struct WelcomeEducationView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var progress: CGFloat = 0
    @State private var showHomeView = false
    @State private var quoteIndex = Int.random(in: 0..<10)

    private let circleRotationDuration: Double = 8
    private let totalDuration: Double = 2.0

    private let quotes = [
        LanguageManager.current.string("Keep going! You've worked hard today!"),
        LanguageManager.current.string("The universe is full of mysteries."),
        LanguageManager.current.string("Space opens up endless possibilities."),
        LanguageManager.current.string("The universe is full of wonders."),
        LanguageManager.current.string("Look up at the sky, dream of the stars."),
        LanguageManager.current.string("The universe is an open book."),
        LanguageManager.current.string("Every star tells a story."),
        LanguageManager.current.string("Space is the grand beginning."),
        LanguageManager.current.string("The universe holds countless secrets."),
        LanguageManager.current.string("Hope you enjoy the universe.")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Titleview()
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                Quoteview(quote: quotes[quoteIndex])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                Spacer()

                RotatingDottedCircleview(duration: circleRotationDuration, clockwise: false)

                Spacer()

                ProgressArrowview(progress: progress)
                    .padding(.bottom, 50)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
            }
            .padding()
            .background(
                ScrollView(.horizontal, showsIndicators: false) {
                    Backgroundview()
                        .frame(width: UIScreen.main.bounds.width * 2.8)
                }
            )
            .onAppear {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                    if progress < 100 {
                        progress += 1
                    } else {
                        timer.invalidate()
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                    showHomeView = true
                    timer.invalidate()
                }
            }
            .navigationDestination(isPresented: $showHomeView) {
                HomeEducationView()
                    .environmentObject(viewModel)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - Background View
struct Backgroundview: View {
    var body: some View {
        Image("cosmos_background2")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

// MARK: - Title View
struct Titleview: View {
    var body: some View {
        VStack(spacing: 5) {
            Text(LanguageManager.current.string("COSMOS"))
                .font(.custom("Audiowide", size: 36))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .white.opacity(0.4), radius: 10)

            Text(LanguageManager.current.string("Education"))
                .font(.custom("Audiowide", size: 36))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Quote View
struct Quoteview: View {
    let quote: String

    var body: some View {
        Text(quote)
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: 300, alignment: .leading)
    }
}

// MARK: - Rotating Dotted Circle
struct RotatingDottedCircleview: View {
    let duration: Double
    let clockwise: Bool

    var body: some View {
        TimelineView(.animation) { context in
            let fraction = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
            let angleDegrees = clockwise ? fraction * 360 : -fraction * 360
            let angle = Angle(degrees: angleDegrees)

            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 200, height: 200)

                ForEach(0..<4) { index in
                    let offsetAngle = Double(index) * .pi / 2
                    let totalAngle = offsetAngle + angle.radians
                    let xOffset = CGFloat(100 * cos(totalAngle))
                    let yOffset = CGFloat(100 * sin(totalAngle))

                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 2)
                        )
                        .offset(x: xOffset, y: yOffset)
                }
            }
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Progress Arrow View
struct ProgressArrowview: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.7))
                .frame(width: 100, height: 50)

            HStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 28))
                    .foregroundColor(.white)

                Text("\(Int(progress))%")
                    .font(.custom("Audiowide", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
struct WelcomeEducationView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeEducationView()
            .environmentObject(AuthViewModel())
    }
}
