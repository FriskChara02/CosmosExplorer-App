//
//  HelixView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI
import WebKit
import UIKit

struct HelixView: View {
    let nebula: NebulaModel
    @ObservedObject var viewModel: NebulaViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = LanguageManager.current.string("Overview")
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]

    private let infoItems: [String] = [
        LanguageManager.current.string("Helix Random Info 1"),
        LanguageManager.current.string("Helix Random Info 2"),
        LanguageManager.current.string("Helix Random Info 3"),
        LanguageManager.current.string("Helix Random Info 4"),
        LanguageManager.current.string("Helix Random Info 5")
    ]

    init(nebula: NebulaModel, viewModel: NebulaViewModel) {
        self.nebula = nebula
        self._isFavorite = State(initialValue: nebula.isFavorite)
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(LanguageManager.current.string(selectedTab)) Nebula")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == LanguageManager.current.string("Wiki") {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Helix_Nebula"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                viewModel.toggleFavorite(nebula: nebula)
                            }
                        }
                    }) {
                        Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                TabBarHelixView(selectedTab: $selectedTab)

                // Nội dung tab
                VStack {
                    if selectedTab == LanguageManager.current.string("Overview") {
                        OverviewHelixView(
                            nebula: nebula,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == LanguageManager.current.string("Information") {
                        InformationHelixView(
                            nebula: nebula,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == LanguageManager.current.string("Galleries") {
                        GalleriesHelixView(animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Comment") {
                        CommentHelixView()
                    } else if selectedTab == LanguageManager.current.string("Wiki") {
                        VStack {
                            Text(LanguageManager.current.string("Wikipedia: Helix Nebula"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Helix_Nebula")!)
                                .frame(maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                        }
                    } else {
                        Text(LanguageManager.current.string("Content for tab coming soon").replacingOccurrences(of: "{tab}", with: selectedTab))
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: selectedTab)
                .animation(.easeInOut(duration: 1.0), value: glowIntensity)
                .animation(.easeInOut(duration: 1.0), value: randomInfo)

                Spacer()
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .background(Image("Helix_background").resizable().scaledToFill().ignoresSafeArea().overlay(Color.black.opacity(0.3)))
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(nebula: nebula)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func updateRandomInfo() {
        randomInfo = infoItems.randomElement() ?? ""
    }
}

struct TabBarHelixView: View {
    @Binding var selectedTab: String

    let tabsLine1 = [
        (LanguageManager.current.string("Overview"), "photo"),
        (LanguageManager.current.string("Information"), "info.circle"),
        (LanguageManager.current.string("Galleries"), "photo.stack")
    ]
    let tabsLine2 = [
        (LanguageManager.current.string("Comment"), "bubble.left"),
        (LanguageManager.current.string("Wiki"), "book")
    ]

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(tabsLine1, id: \.0) { tab, icon in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.caption)
                                .foregroundColor(selectedTab == tab ? .white : .white)
                            Text(tab)
                                .font(.caption)
                                .fontWeight(selectedTab == tab ? .bold : .regular)
                                .foregroundColor(selectedTab == tab ? .white : .white)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                        .clipShape(Capsule())
                    }
                }
            }
            HStack(spacing: 8) {
                ForEach(tabsLine2, id: \.0) { tab, icon in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.caption)
                                .foregroundColor(selectedTab == tab ? .white : .white)
                            Text(tab)
                                .font(.caption)
                                .fontWeight(selectedTab == tab ? .bold : .regular)
                                .foregroundColor(selectedTab == tab ? .white : .white)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

struct OverviewHelixView: View {
    let nebula: NebulaModel
    @Binding var glowIntensity: Float
    @Binding var randomInfo: String
    let animation: Namespace.ID
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center

    var body: some View {
        ZStack {
            if let data = nebula.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .scaleEffect(scale, anchor: anchorPoint)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = max(0.5, min(value, 10.0))
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    anchorPoint = .center
                                }
                            }
                            .simultaneously(with: TapGesture(count: 2).onEnded {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    anchorPoint = .center
                                }
                            })
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                let imageSize = CGSize(width: 300, height: 300)
                                let normalizedX = location.x / imageSize.width
                                let normalizedY = location.y / imageSize.height
                                anchorPoint = UnitPoint(x: normalizedX, y: normalizedY)
                            }
                    )
                    .padding()
                    .matchedGeometryEffect(id: "helix-\(nebula.id)", in: animation)
            } else {
                Image("Helix")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding()
            }

            VStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -220)
                Text(LanguageManager.current.string("Pinch to Zoom"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -215)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Text(nebula.name)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .offset(x: 0, y: -100)
        Text(randomInfo)
            .font(.body)
            .foregroundColor(.white.opacity(0.8))
            .padding()
            .transition(.opacity)
            .offset(x: 0, y: -130)
    }
}

struct InformationHelixView: View {
    let nebula: NebulaModel
    @Binding var glowIntensity: Float
    @Binding var isFavorite: Bool
    @Binding var selectedTab: String
    let animation: Namespace.ID
    let viewModel: NebulaViewModel
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let data = nebula.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .scaleEffect(scale, anchor: anchorPoint)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(0.5, min(value, 10.0))
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        anchorPoint = .center
                                    }
                                }
                                .simultaneously(with: TapGesture(count: 2).onEnded {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        anchorPoint = .center
                                    }
                                })
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    let imageSize = CGSize(width: geometry.size.width, height: 150)
                                    let normalizedX = location.x / imageSize.width
                                    let normalizedY = location.y / imageSize.height
                                    anchorPoint = UnitPoint(x: normalizedX, y: normalizedY)
                                }
                        )
                        .matchedGeometryEffect(id: "helix-\(nebula.id)", in: animation)
                } else {
                    Image("Helix_background")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text(LanguageManager.current.string("About"))
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                if selectedTab == LanguageManager.current.string("Wiki") {
                                    UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Helix_Nebula"
                                } else {
                                    withAnimation(.spring()) {
                                        isFavorite.toggle()
                                        viewModel.toggleFavorite(nebula: nebula)
                                    }
                                }
                            }) {
                                Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)

                        Text(nebula.aboutDescription.isEmpty ? LanguageManager.current.string("Helix About Description") : nebula.aboutDescription)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .transition(.opacity)

                        Divider()
                            .background(.white)

                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text(LanguageManager.current.string("Video"))
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            NavigationLink(destination: VideoListHelixView(videoURLs: nebula.videoURLs)) {
                                Text(LanguageManager.current.string("See more           "))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                            }
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(nebula.videoURLs.isEmpty ? [
                                "https://www.youtube.com/embed/I8z2OLO80O4",
                                "https://www.youtube.com/embed/-toJ-cgHFm4"
                            ] : nebula.videoURLs, id: \.self) { url in
                                if let validURL = URL(string: url) {
                                    WebView(url: validURL)
                                        .frame(height: 120)
                                        .aspectRatio(16/9, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .zIndex(1)
                                } else {
                                    Text("Invalid URL")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Divider()
                            .background(.white)

                        VStack(spacing: 12) {
                            infoCard(icon: "circle.fill", color: .orange, title: LanguageManager.current.string("Radius"), value: nebula.radius.isEmpty ? LanguageManager.current.string("Unknown") : nebula.radius)
                            infoCard(icon: "sun.max.fill", color: .red, title: LanguageManager.current.string("Distance from Sun"), value: nebula.distanceFromSun.isEmpty ? LanguageManager.current.string("Unknown") : nebula.distanceFromSun)
                            infoCard(icon: "hourglass", color: .teal, title: LanguageManager.current.string("Age"), value: nebula.age.isEmpty ? LanguageManager.current.string("Unknown") : nebula.age)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isFavorite)
    }

    @ViewBuilder
    private func infoCard(icon: String, color: Color, title: String, value: String) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.15),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                            .blur(radius: 3)
                    )
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.vertical, 2)
        .gesture(
            TapGesture()
                .onEnded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    }
                }
        )
    }
}

struct VideoListHelixView: View {
    let videoURLs: [String]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(videoURLs.isEmpty ? [
                    "https://www.youtube.com/embed/I8z2OLO80O4",
                    "https://www.youtube.com/embed/-toJ-cgHFm4",
                    "https://www.youtube.com/embed/HFy8MR3dgpQ",
                    "https://www.youtube.com/embed/qMZ1E3V_GJM"
                ] : videoURLs, id: \.self) { url in
                    if let validURL = URL(string: url) {
                        WebView(url: validURL)
                            .frame(height: 120)
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Text("Invalid URL")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
        .background(Image("Helix_background").resizable().scaledToFill().ignoresSafeArea())
        .navigationTitle(LanguageManager.current.string("Videos"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleriesHelixView: View {
    let animation: Namespace.ID
    let images = ["Helix_background", "Helix01", "Helix02", "Helix03", "Helix04", "Helix05"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.white.opacity(0.4), Color.cyan.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(images, id: \.self) { image in
                        ZStack(alignment: .bottom) {
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .blue.opacity(0.6), radius: 10, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [.orange, .cyan, .clear]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 2)
                                )
                                .matchedGeometryEffect(id: "gallery-\(image)", in: animation)
                            Text(image)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                )
                        }
                    }
                }
                .padding()
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

struct CommentHelixView: View {
    var body: some View {
        Text(LanguageManager.current.string("Comment Under Development"))
            .font(.title2)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    HelixView(
        nebula: NebulaModel(name: "Helix", nebulaDescription: "The Helix Nebula.", nebula_order: 2),
        viewModel: NebulaViewModel()
    )
}
