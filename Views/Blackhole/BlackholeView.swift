//
//  BlackholeView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 18/10/25.
//

import SwiftUI
import WebKit
import UIKit

struct BlackholeView: View {
    let blackhole: BlackholeModel
    @ObservedObject var viewModel: BlackholeViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = LanguageManager.current.string("Overview")
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]

    init(blackhole: BlackholeModel, viewModel: BlackholeViewModel) {
        self.blackhole = blackhole
        self._isFavorite = State(initialValue: blackhole.isFavorite)
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
                    Text("\(LanguageManager.current.string(selectedTab)) \(LanguageManager.current.string("Blackhole"))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == LanguageManager.current.string("Wiki") {
                            UIPasteboard.general.string = blackhole.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(blackhole.name)" : blackhole.wikiLink
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                viewModel.toggleFavorite(blackhole: blackhole)
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

                TabBarView(selectedTab: $selectedTab)

                // Nội dung tab
                VStack {
                    if selectedTab == LanguageManager.current.string("Overview") {
                        OverviewView(
                            blackhole: blackhole,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == LanguageManager.current.string("Information") {
                        InformationView(
                            blackhole: blackhole,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == LanguageManager.current.string("Galleries") {
                        GalleriesView(blackhole: blackhole, animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Comment") {
                        CommentView()
                    } else if selectedTab == LanguageManager.current.string("Wiki") {
                        VStack {
                            Text("\(LanguageManager.current.string("Wiki")): \(blackhole.name)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: blackhole.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(blackhole.name)" : blackhole.wikiLink)!)
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
            .background(Image("BlackBG").resizable().scaledToFill().ignoresSafeArea())
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(blackhole: blackhole)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func updateRandomInfo() {
        randomInfo = blackhole.randomInfos.randomElement() ?? ""
    }

    struct TabBarView: View {
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
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
                                Text(tab)
                                    .font(.caption)
                                    .fontWeight(selectedTab == tab ? .bold : .regular)
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
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
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
                                Text(tab)
                                    .font(.caption)
                                    .fontWeight(selectedTab == tab ? .bold : .regular)
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
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

    struct OverviewView: View {
        let blackhole: BlackholeModel
        @Binding var glowIntensity: Float
        @Binding var randomInfo: String
        let animation: Namespace.ID
        @State private var scale: CGFloat = 1.0
        @State private var anchorPoint: UnitPoint = .center
        
        var body: some View {
            ZStack {
                if let data = blackhole.imageData, let uiImage = UIImage(data: data) {
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
                        .matchedGeometryEffect(id: "blackhole-\(blackhole.id)", in: animation)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .foregroundColor(.gray)
                        .padding()
                }

                // Icon zoom và text hướng dẫn
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

            // Text với offset
            Text(blackhole.name)
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

    struct InformationView: View {
        let blackhole: BlackholeModel
        @Binding var glowIntensity: Float
        @Binding var isFavorite: Bool
        @Binding var selectedTab: String
        let animation: Namespace.ID
        let viewModel: BlackholeViewModel
        @State private var scale: CGFloat = 1.0
        @State private var anchorPoint: UnitPoint = .center
        
        var body: some View {
            GeometryReader { geometry in
                VStack {
                    if let data = blackhole.imageData, let uiImage = UIImage(data: data) {
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
                            .matchedGeometryEffect(id: "blackhole-\(blackhole.id)", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(.gray)
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
                                        UIPasteboard.general.string = blackhole.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(blackhole.name)" : blackhole.wikiLink
                                    } else {
                                        withAnimation(.spring()) {
                                            isFavorite.toggle()
                                            viewModel.toggleFavorite(blackhole: blackhole)
                                        }
                                    }
                                }) {
                                    Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)

                            Text(blackhole.aboutDescription.isEmpty ? LanguageManager.current.string("No description available") : blackhole.aboutDescription)
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
                                NavigationLink(destination: VideoListView(videoURLs: blackhole.videoURLs, blackholeName: blackhole.name)) {
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
                                ForEach(blackhole.videoURLs.prefix(2), id: \.self) { url in
                                    WebView(url: URL(string: url)!)
                                        .frame(height: 120)
                                        .aspectRatio(16/9, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .zIndex(1)
                                }
                            }
                            .padding(.horizontal)

                            Divider()
                                .background(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                infoRow(icon: "circle.fill", color: .orange, text: "\(LanguageManager.current.string("Radius")): \(blackhole.radius.isEmpty ? LanguageManager.current.string("Unknown") : blackhole.radius)")
                                infoRow(icon: "sun.max.fill", color: .red, text: "\(LanguageManager.current.string("Distance from Sun")): \(blackhole.distanceFromSun.isEmpty ? LanguageManager.current.string("Unknown") : blackhole.distanceFromSun)")
                                infoRow(icon: "hourglass", color: .teal, text: "\(LanguageManager.current.string("Age")): \(blackhole.age.isEmpty ? LanguageManager.current.string("Unknown") : blackhole.age)")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(25)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isFavorite)
        }

        @ViewBuilder
        private func infoRow(icon: String, color: Color, text: String) -> some View {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .shadow(color: color.opacity(0.6), radius: 4, x: 0, y: 2)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.05))
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
            )
        }
    }

    struct VideoListView: View {
        let videoURLs: [String]
        let blackholeName: String
        
        init(videoURLs: [String], blackholeName: String = "") {
            self.videoURLs = videoURLs
            self.blackholeName = blackholeName
        }

        var body: some View {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(videoURLs, id: \.self) { url in
                        WebView(url: URL(string: url)!)
                            .frame(height: 120)
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .background(Image("BlackBG").resizable().scaledToFill().ignoresSafeArea())
            .navigationTitle(LanguageManager.current.string("Videos"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !blackholeName.isEmpty {
                    print("📱 \(LanguageManager.current.string("VideoListView appeared for")) \(blackholeName)")
                }
            }
        }
    }

    struct GalleriesView: View {
        let blackhole: BlackholeModel
        let animation: Namespace.ID
        @State private var scale: CGFloat = 1.0
        @State private var anchorPoint: UnitPoint = .center
        
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        (blackhole.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0) } ?? Color.blue).opacity(0.4),
                        (blackhole.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0).lighter(by: 0.2) } ?? Color.blue).opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(blackhole.galleryImageData.indices, id: \.self) { index in
                            if let data = blackhole.galleryImageData[index], let uiImage = UIImage(data: data) {
                                ZStack(alignment: .bottom) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 180, height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .scaleEffect(scale, anchor: anchorPoint)
                                        .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(LinearGradient(
                                                    gradient: Gradient(colors: [.blue, .purple, .clear]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ), lineWidth: 2)
                                        )
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
                                                    let imageSize = CGSize(width: 180, height: 180)
                                                    let normalizedX = location.x / imageSize.width
                                                    let normalizedY = location.y / imageSize.height
                                                    anchorPoint = UnitPoint(x: normalizedX, y: normalizedY)
                                                }
                                        )
                                        .matchedGeometryEffect(id: "gallery-\(index)", in: animation)
                                    
                                    Text(LanguageManager.current.string("Image").replacingOccurrences(of: "{index}", with: "\(index + 1)"))
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
                    }
                    .padding()
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }

    struct CommentView: View {
        var body: some View {
            Text(LanguageManager.current.string("Comment Under Development"))
                .font(.title2)
                .foregroundColor(.white)
                .padding()
        }
    }
}

#Preview {
    BlackholeView(
        blackhole: BlackholeModel(name: "Test Blackhole", blackholeDescription: "Test", blackhole_order: 0),
        viewModel: BlackholeViewModel()
    )
}
