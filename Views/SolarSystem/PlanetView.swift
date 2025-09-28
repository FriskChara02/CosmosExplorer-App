//
//  PlanetView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 19/9/25.
//

import SwiftUI
import WebKit
import UIKit

struct PlanetView: View {
    let planet: PlanetModel
    @ObservedObject var viewModel: SolarSystemViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = LanguageManager.current.string("Overview")
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]

    init(planet: PlanetModel, viewModel: SolarSystemViewModel) {
        self.planet = planet
        self._isFavorite = State(initialValue: planet.isFavorite)
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
                    Text("\(LanguageManager.current.string(selectedTab)) \(LanguageManager.current.string("Planets"))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == LanguageManager.current.string("Wiki") {
                            UIPasteboard.general.string = planet.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(planet.name)" : planet.wikiLink
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                viewModel.toggleFavorite(planet: planet)
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
                            planet: planet,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == LanguageManager.current.string("Information") {
                        InformationView(
                            planet: planet,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == LanguageManager.current.string("By the Numbers") {
                        ByTheNumbersView(planet: planet)
                    } else if selectedTab == LanguageManager.current.string("Galleries") {
                        GalleriesView(planet: planet, animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Wiki") {
                        VStack {
                            Text("\(LanguageManager.current.string("Wiki")): \(planet.name)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: planet.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(planet.name)" : planet.wikiLink)!)
                                .frame(maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                        }
                    } else if selectedTab == LanguageManager.current.string("Myth") {
                        MythView(planet: planet, animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Internal") {
                        InternalView(planet: planet, animation: animation)
                    } else if selectedTab == LanguageManager.current.string("In Depth") {
                        InDepthView(planet: planet, animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Exploration") {
                        ExplorationView(planet: planet, animation: animation)
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
                viewModel.incrementViewCount(planet: planet)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func updateRandomInfo() {
        randomInfo = planet.randomInfos.randomElement() ?? ""
    }

    struct TabBarView: View {
        @Binding var selectedTab: String

        let tabs = [
            LanguageManager.current.string("Overview"),
            LanguageManager.current.string("Information"),
            LanguageManager.current.string("By the Numbers"),
            LanguageManager.current.string("Galleries"),
            LanguageManager.current.string("Myth"),
            LanguageManager.current.string("Internal"),
            LanguageManager.current.string("In Depth"),
            LanguageManager.current.string("Exploration"),
            LanguageManager.current.string("Comment"),
            LanguageManager.current.string("Wiki")
        ]

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab)
                                .font(.subheadline)
                                .fontWeight(selectedTab == tab ? .bold : .regular)
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
    }

    struct OverviewView: View {
        let planet: PlanetModel
        @Binding var glowIntensity: Float
        @Binding var randomInfo: String
        let animation: Namespace.ID

        var body: some View {
            ZStack {
                if let data = planet.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .yellow.opacity(CGFloat(glowIntensity)), radius: 10)
                        .padding()
                        .matchedGeometryEffect(id: "planet-\(planet.id)", in: animation)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .foregroundColor(.gray)
                        .padding()
                }

                // Icon 360 độ và số 360 độ với offset
                VStack {
                    Image(systemName: "location.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 0, y: -220)
                    Text("✦")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 0, y: -215)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Text với offset
            Text(planet.name)
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
        let planet: PlanetModel
        @Binding var glowIntensity: Float
        @Binding var isFavorite: Bool
        @Binding var selectedTab: String
        let animation: Namespace.ID
        let viewModel: SolarSystemViewModel

        var body: some View {
            GeometryReader { geometry in
                VStack {
                    if let data = planet.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .yellow.opacity(CGFloat(glowIntensity)), radius: 10)
                            .matchedGeometryEffect(id: "planet-\(planet.id)", in: animation)
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
                                        UIPasteboard.general.string = planet.wikiLink.isEmpty ? "https://en.wikipedia.org/wiki/\(planet.name)" : planet.wikiLink
                                    } else {
                                        withAnimation(.spring()) {
                                            isFavorite.toggle()
                                            viewModel.toggleFavorite(planet: planet)
                                        }
                                    }
                                }) {
                                    Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)

                            Text(planet.aboutDescription.isEmpty ? LanguageManager.current.string("No description available") : planet.aboutDescription)
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
                                NavigationLink(destination: VideoListView(videoURLs: planet.videoURLs, planetName: planet.name)) {
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
                                ForEach(planet.videoURLs, id: \.self) { url in
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
    }

    struct WebView: UIViewRepresentable {
        let url: URL
        
        func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true
            configuration.mediaTypesRequiringUserActionForPlayback = []
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.isOpaque = true
            webView.backgroundColor = .black
            webView.scrollView.isScrollEnabled = true
            webView.scrollView.pinchGestureRecognizer?.isEnabled = true
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 3.0
            webView.allowsLinkPreview = true
            webView.isUserInteractionEnabled = true
            
            var embedUrlString = url.absoluteString
            if let videoId = extractYouTubeVideoId(from: embedUrlString) {
                embedUrlString = "https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1&controls=1"
            }
            
            if let embedUrl = URL(string: embedUrlString) {
                let request = URLRequest(url: embedUrl)
                webView.load(request)
            }
            
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            var embedUrlString = url.absoluteString
            if let videoId = extractYouTubeVideoId(from: embedUrlString) {
                embedUrlString = "https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1&controls=1"
            }
            
            if let embedUrl = URL(string: embedUrlString), uiView.url != embedUrl {
                let request = URLRequest(url: embedUrl)
                uiView.load(request)
            }
        }
        
        private func extractYouTubeVideoId(from url: String) -> String? {
            let pattern = "v=([a-zA-Z0-9_-]{11})"
            let regex = try? NSRegularExpression(pattern: pattern)
            let nsString = url as NSString
            let results = regex?.matches(in: url, range: NSRange(location: 0, length: nsString.length))
            return results?.map { nsString.substring(with: $0.range(at: 1)) }.first
        }
    }

    struct VideoListView: View {
        let videoURLs: [String]
        let planetName: String
        
        init(videoURLs: [String], planetName: String = "") {
                self.videoURLs = videoURLs
                self.planetName = planetName
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
                if !planetName.isEmpty {
                    print("📱 \(LanguageManager.current.string("VideoListView appeared for")) \(planetName)")
                }
            }
        }
    }

    struct ByTheNumbersView: View {
        let planet: PlanetModel

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
    infoRow(icon: "star.fill", color: .yellow, text: "\(LanguageManager.current.string("Planet Type")): \(planet.planetType.isEmpty ? LanguageManager.current.string("N/A") : planet.planetType)")
    infoRow(icon: "circle.fill", color: .orange, text: "\(LanguageManager.current.string("Radius")): \(planet.radius.isEmpty ? LanguageManager.current.string("N/A") : planet.radius)")
    infoRow(icon: "sun.max.fill", color: .red, text: "\(LanguageManager.current.string("Distance from Sun")): \(planet.distanceFromSun.isEmpty ? LanguageManager.current.string("N/A") : planet.distanceFromSun)")
    infoRow(icon: "moon.fill", color: .gray, text: "\(LanguageManager.current.string("Moons")): \(planet.moons.isEmpty ? LanguageManager.current.string("N/A") : planet.moons)")
    infoRow(icon: "gauge", color: .green, text: "\(LanguageManager.current.string("Gravity")): \(planet.gravity.isEmpty ? LanguageManager.current.string("N/A") : planet.gravity)")
    infoRow(icon: "arrow.triangle.2.circlepath", color: .blue, text: "\(LanguageManager.current.string("Tilt of Axis")): \(planet.tiltOfAxis.isEmpty ? LanguageManager.current.string("N/A") : planet.tiltOfAxis)")
    infoRow(icon: "calendar", color: .purple, text: "\(LanguageManager.current.string("Length of Year")): \(planet.lengthOfYear.isEmpty ? LanguageManager.current.string("N/A") : planet.lengthOfYear)")
    infoRow(icon: "clock", color: .pink, text: "\(LanguageManager.current.string("Length of Day")): \(planet.lengthOfDay.isEmpty ? LanguageManager.current.string("N/A") : planet.lengthOfDay)")
    infoRow(icon: "thermometer", color: .red, text: "\(LanguageManager.current.string("Temperature")): \(planet.temperature.isEmpty ? LanguageManager.current.string("N/A") : planet.temperature)")
    infoRow(icon: "hourglass", color: .teal, text: "\(LanguageManager.current.string("Age")): \(planet.age.isEmpty ? LanguageManager.current.string("N/A") : planet.age)")
                }
                .padding()
                .transition(.move(edge: .leading))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        (planet.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0) } ?? Color.blue).opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
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
            .padding(.horizontal, 2)
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: UUID())
        }
    }

    struct GalleriesView: View {
        let planet: PlanetModel
        let animation: Namespace.ID

        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        (planet.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0) } ?? Color.blue).opacity(0.4),
                        (planet.imageData
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
                        ForEach(planet.galleryImageData.indices, id: \.self) { index in
                            if let data = planet.galleryImageData[index], let uiImage = UIImage(data: data) {
                                ZStack(alignment: .bottom) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 180, height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 4)
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

    struct MythView: View {
        let planet: PlanetModel
        let animation: Namespace.ID
        
        var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        (planet.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0) } ?? Color.blue).opacity(0.8),
                        Color.black
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                ScrollView {
                    MythContentView(planet: planet, animation: animation)
                }
            }
        }
    }

    private struct MythContentView: View {
        let planet: PlanetModel
        let animation: Namespace.ID
        
        var body: some View {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(planet.mythTitle.isEmpty ? LanguageManager.current.string("Myths Across Cultures") : planet.mythTitle)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(planet.mythDescription.isEmpty ? LanguageManager.current.string("No myth description available") : planet.mythDescription)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // List of myths
                ForEach(planet.myths) { myth in
                    MythItemView(myth: myth, animation: animation)
                }
            }
            .padding(.bottom, 40)
        }
    }

    private struct MythItemView: View {
        let myth: PlanetMyth
        let animation: Namespace.ID
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Myth image
                    if let data = myth.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .matchedGeometryEffect(id: "myth-\(myth.id)", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                    
                    // Myth info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(myth.culture.isEmpty ? LanguageManager.current.string("N/A") : myth.culture)
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.leading)
                        Text(myth.godName.isEmpty ? LanguageManager.current.string("N/A") : myth.godName)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Text(myth.mythDescription.isEmpty ? LanguageManager.current.string("No description available") : myth.mythDescription)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(width: 360, height: 200)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
    }

    struct InternalView: View {
        let planet: PlanetModel
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                InternalContentView(planet: planet, animation: animation)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.black,
                        (planet.imageData
                            .flatMap { UIImage(data: $0)?.dominantColor() }
                            .map { Color($0) } ?? Color.blue).opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }

    private struct InternalContentView: View {
        let planet: PlanetModel
        let animation: Namespace.ID
        
        var body: some View {
            VStack(spacing: 20) {
                // Header
                Text(planet.internalTitle.isEmpty ? LanguageManager.current.string("Internal Layers") : planet.internalTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // List of layers
                ForEach(planet.layers) { layer in
                    LayerItemView(layer: layer)
                }
                
                // Internal image
                if let internalImageData = planet.internalImage, !internalImageData.isEmpty {
                    if let uiImage = UIImage(data: internalImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                            .matchedGeometryEffect(id: "internal-planet", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.bottom, 30)
        }
    }

    private struct LayerItemView: View {
        let layer: PlanetLayer
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: layer.icon.isEmpty ? "star.fill" : layer.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(layer.name.isEmpty ? LanguageManager.current.string("N/A") : layer.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Text(layer.layerDescription.isEmpty ? LanguageManager.current.string("No description available") : layer.layerDescription)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
            .frame(width: 360, height: 120)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: layer.colorStart.isEmpty ? "#FFFFFF" : layer.colorStart) ?? .white,
                        Color(hex: layer.colorEnd.isEmpty ? "#FFFFFF" : layer.colorEnd) ?? .white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
            .padding(.horizontal)
        }
    }

    struct InDepthView: View {
        let planet: PlanetModel
        let animation: Namespace.ID

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    if let data = planet.headerImageInDepthData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 8)
                            .padding(.horizontal)
                            .matchedGeometryEffect(id: "indepth-planet", in: animation)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }

                    Text(planet.inDepthTitle.isEmpty ? LanguageManager.current.string("In-Depth Study") : planet.inDepthTitle)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        ForEach(planet.infoCards) { card in
                            InfoCardView(
                                icon: card.icon.isEmpty ? "star.fill" : card.icon,
                                title: card.title.isEmpty ? LanguageManager.current.string("N/A") : card.title,
                                description: card.infoCardDescription.isEmpty ? LanguageManager.current.string("No description available") : card.infoCardDescription,
                                iconColor: Color(hex: card.iconColor.isEmpty ? "#FFFFFF" : card.iconColor) ?? .white
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    struct InfoCardView: View {
        let icon: String
        let title: String
        let description: String
        let iconColor: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }

    struct ExplorationView: View {
        let planet: PlanetModel
        let animation: Namespace.ID

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack(alignment: .bottomLeading) {
                        if let data = planet.headerImageExplorationData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 220)
                                .foregroundColor(.gray)
                        }
                        Text(planet.explorationTitle.isEmpty ? LanguageManager.current.string("Exploration") : planet.explorationTitle)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding()
                    }
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(planet.missions) { mission in
                            MissionCardView(
                                title: mission.title.isEmpty ? LanguageManager.current.string("N/A") : mission.title,
                                description: mission.missionDescription.isEmpty ?LanguageManager.current.string("No description available") : mission.missionDescription,
                                icon: mission.icon.isEmpty ? "star.fill" : mission.icon,
                                animation: animation,
                                id: mission.missionId
                            )
                        }
                    }
                    .padding(.horizontal)

                    Text(planet.highlightQuote.isEmpty ? LanguageManager.current.string("No quote available") : planet.highlightQuote)
                        .font(.title3.italic())
                        .foregroundStyle(LinearGradient(
                            colors: [
                                (planet.imageData
                                    .flatMap { UIImage(data: $0)?.dominantColor() }
                                    .map { Color($0) } ?? Color.blue),
                                (planet.imageData
                                    .flatMap { UIImage(data: $0)?.dominantColor() }
                                    .map { Color($0).lighter(by: 0.2) } ?? Color.blue)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 12)

                    if let data = planet.showcaseImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    struct MissionCardView: View {
        let title: String
        let description: String
        let icon: String
        let animation: Namespace.ID
        let id: String

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .matchedGeometryEffect(id: id, in: animation)
            )
            .shadow(radius: 6)
        }
    }
}

// Color extension để chuyển hex sang Color
extension Color {
    init?(hex: String) {
        let r, g, b: Double
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString)
        
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        if hexString.count == 6 {
            r = Double((hexNumber & 0xFF0000) >> 16) / 255
            g = Double((hexNumber & 0x00FF00) >> 8) / 255
            b = Double(hexNumber & 0x0000FF) / 255
            self.init(red: r, green: g, blue: b)
        } else {
            return nil
        }
    }
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return nil }
        
        let pixelData = cgImage.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var count: CGFloat = 0
        
        // Lấy màu trung bình từ các pixel
        for x in 0..<width {
            for y in 0..<height {
                let pixelInfo = (width * y + x) * 4
                r += CGFloat(data[pixelInfo]) / 255.0
                g += CGFloat(data[pixelInfo + 1]) / 255.0
                b += CGFloat(data[pixelInfo + 2]) / 255.0
                count += 1
            }
        }
        
        r /= count
        g /= count
        b /= count
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Color {
    func lighter(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(UIColor(red: min(r + percentage, 1.0),
                           green: min(g + percentage, 1.0),
                           blue: min(b + percentage, 1.0),
                           alpha: a))
    }
}

#Preview {
    PlanetView(
        planet: PlanetModel(name: "Your Planet", planetDescription: "A test planet.", planet_order: 0),
        viewModel: SolarSystemViewModel()
    )
}
