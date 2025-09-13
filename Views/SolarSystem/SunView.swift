//
//  SunView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/8/25.
//

import SwiftUI
import RealityKit
import WebKit
import UIKit
import SwiftData

struct SunView: View {
    let planet: PlanetModel
    @ObservedObject var viewModel: SolarSystemViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = "Overview"
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]
    private let infoItems: [String] = [
        "The Sun is a G-type main-sequence star.",
        "It accounts for 99.86% of the Solar System's mass.",
        "The Sun's surface temperature is about 5,500°C.",
        "It is approximately 4.6 billion years old.",
        "The Sun drives Earth's climate and sustains life."
    ]

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
                    Text("\(selectedTab) Planet")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == "Wiki" {
                            // Sao chép link Wikipedia
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Sun"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                planet.isFavorite = isFavorite
                                viewModel.toggleFavorite(planet: planet)
                            }
                        }
                    }) {
                        Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabBarView(selectedTab: $selectedTab)
                
                // Nội dung tab
                VStack {
                    if selectedTab == "Overview" {
                        OverviewView(
                            planet: planet,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == "Information" {
                        InformationView(
                            planet: planet,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == "By the Numbers" {
                        ByTheNumbersView()
                    } else if selectedTab == "Galleries" {
                        GalleriesView(animation: animation)
                    } else if selectedTab == "Wiki" {
                        VStack {
                            Text("Wikipedia: Sun")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Sun")!)
                                .frame(maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                        }
                    } else if selectedTab == "Myth" {
                        MythView(animation: animation)
                    } else if selectedTab == "Internal" {
                        InternalView(animation: animation)
                    } else if selectedTab == "In Depth" {
                        InDepthView(animation: animation)
                    } else if selectedTab == "Exploration" {
                        ExplorationView(animation: animation)
                    } else {
                        Text("Content for \(selectedTab) tab coming soon!")
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
            randomInfo = infoItems.randomElement() ?? ""
        }
    
    struct TabBarView: View {
        @Binding var selectedTab: String
        
        let tabs = ["Overview", "Information", "By the Numbers", "Galleries", "Myth", "Internal", "In Depth", "Exploration", "Comment", "Wiki"]
        
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
        @State private var dragRotationY: Float = 0
        @State private var dragRotationX: Float = 0
        @State private var isDragging: Bool = false

        var body: some View {
            ZStack {
                RealityView { content in
                    let sunMesh = MeshResource.generateSphere(radius: 1.0)
                    var sunMaterial = PhysicallyBasedMaterial()
                    do {
                        let textureResource = try await TextureResource(named: "Sun")
                        sunMaterial.baseColor = .init(texture: .init(textureResource))
                        if let normalResource = try? await TextureResource(named: "Sun") {
                            sunMaterial.normal = .init(texture: .init(normalResource))
                        }
                    } catch {
                        print("Error loading texture: \(error)")
                        sunMaterial.baseColor = .init(tint: .yellow)
                    }
                    sunMaterial.emissiveColor = .init(color: .orange)
                    sunMaterial.emissiveIntensity = glowIntensity
                    sunMaterial.roughness = 0.2
                    sunMaterial.metallic = 0.9
                    
                    let sunEntity = ModelEntity(mesh: sunMesh, materials: [sunMaterial])
                    sunEntity.name = "Sun"
                    sunEntity.position = [0, 0, 0]
                    
                    var flareComponent = ParticleEmitterComponent()
                    flareComponent.emitterShape = .sphere
                    flareComponent.emitterShapeSize = SIMD3<Float>(repeating: 1.0)
                    flareComponent.burstCount = 30
                    flareComponent.burstCountVariation = 10
                    flareComponent.speed = 0.15
                    flareComponent.speedVariation = 0.05
                    flareComponent.birthLocation = .surface
                    flareComponent.birthDirection = .normal
                    flareComponent.timing = .repeating(warmUp: 0.0, emit: .init(duration: 2.0), idle: .init(duration: 1.0))
                    flareComponent.particlesInheritTransform = true
                    
                    let flareEntity = ModelEntity()
                    flareEntity.components.set(flareComponent)
                    flareEntity.position = [0, 0, 0]
                    sunEntity.addChild(flareEntity)
                    
                    var flareMaterial = UnlitMaterial()
                    flareMaterial.color = .init(tint: .orange)
                    flareEntity.model = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.01), materials: [flareMaterial])
                    
                    let pointLight = PointLight()
                    pointLight.light.intensity = 2500
                    pointLight.light.color = .yellow
                    pointLight.position = [1, 1, 1]
                    
                    let spotLight = SpotLight()
                    spotLight.light.intensity = 1500
                    spotLight.light.color = .white
                    spotLight.position = [2, 2, 2]
                    spotLight.look(at: [0, 0, 0], from: spotLight.position, relativeTo: nil)
                    
                    let ambientLight = PointLight()
                    ambientLight.light.intensity = 500
                    ambientLight.light.color = .white
                    ambientLight.position = [0, 0, 0]
                    
                    content.add(sunEntity)
                    content.add(pointLight)
                    content.add(spotLight)
                    content.add(ambientLight)
                    
                    Task { @MainActor in
                        var angle: Float = 0
                        while true {
                            if !isDragging {
                                angle += 0.01
                            }
                            let rotationY = simd_quatf(angle: angle + dragRotationY, axis: [0, 1, 0])
                            let rotationX = simd_quatf(angle: dragRotationX, axis: [1, 0, 0])
                            sunEntity.transform.rotation = rotationY * rotationX
                            try? await Task.sleep(nanoseconds: 16_666_666)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                .matchedGeometryEffect(id: "sun-\(planet.id)", in: animation)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let dragDistanceX = Float(value.translation.height)
                            let dragDistanceY = Float(value.translation.width)
                            dragRotationX = dragDistanceX * 0.01
                            dragRotationY = dragDistanceY * 0.01
                        }
                        .onEnded { _ in
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // Chờ 1 giây
                                isDragging = false
                            }
                        }
                )
                
                // Icon 360 độ và số 360 độ với offset
                VStack {
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 0, y: -220)
                    Text("360°")
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
                    RealityView { content in
                        let sunMesh = MeshResource.generateSphere(radius: 0.5)
                        var sunMaterial = PhysicallyBasedMaterial()
                        do {
                            let textureResource = try await TextureResource(named: "Sun")
                            sunMaterial.baseColor = .init(texture: .init(textureResource))
                        } catch {
                            sunMaterial.baseColor = .init(tint: .yellow)
                        }
                        sunMaterial.emissiveColor = .init(color: .orange)
                        sunMaterial.emissiveIntensity = glowIntensity
                        sunMaterial.roughness = 0.2
                        sunMaterial.metallic = 0.9
                        
                        let sunEntity = ModelEntity(mesh: sunMesh, materials: [sunMaterial])
                        sunEntity.position = [0, 0, 0]
                        
                        content.add(sunEntity)
                        
                        Task { @MainActor in
                            var angle: Float = 0
                            while true {
                                angle += 0.01
                                let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                                sunEntity.transform.rotation = rotation
                                try? await Task.sleep(nanoseconds: 16_666_666)
                            }
                        }
                    }
                    .frame(height: 150)
                    .matchedGeometryEffect(id: "sun-\(planet.id)", in: animation)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    if selectedTab == "Wiki" {
                                        // Sao chép link Wikipedia
                                        UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Sun"
                                    } else {
                                        withAnimation(.spring()) {
                                            isFavorite.toggle()
                                            planet.isFavorite = isFavorite
                                            viewModel.toggleFavorite(planet: planet)
                                        }
                                    }
                                }) {
                                    Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            
                            Text("The Sun, a colossal G-type main-sequence star, sits at the heart of our Solar System, anchoring its planets with immense gravity. It is roughly 4.6 billion years old, making it one of the oldest celestial bodies in our cosmic neighborhood. Its fiery surface, reaching temperatures of about 5,500°C, radiates life-sustaining energy to Earth. The Sun's dynamic atmosphere features solar flares and sunspots, shaping space weather across the system.")
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
                                Text("Video")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                NavigationLink(destination: VideoListView()) {
                                    Text("See more           ")
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
                                ForEach([
                                    "https://www.youtube.com/embed/2HoTK_Gqi2Q?playsinline=1",
                                    "https://www.youtube.com/embed/SLmWY_ycFUA?playsinline=1"
                                ], id: \.self) { url in
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

            let request = URLRequest(url: url)
            webView.load(request)

            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            if uiView.url != url {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }
    
    struct VideoListView: View {
        let videoURLs = [
            "https://www.youtube.com/embed/2HoTK_Gqi2Q?playsinline=1",
            "https://www.youtube.com/embed/SLmWY_ycFUA?playsinline=1",
            "https://www.youtube.com/embed/YFNwWpf9Bbs?playsinline=1",
            "https://www.youtube.com/embed/VkW54j82e9U?playsinline=1",
            "https://www.youtube.com/embed/dGPKTtt05wc?playsinline=1",
            "https://www.youtube.com/embed/D0D4m2qAY3g?playsinline=1"
        ]

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
            .navigationTitle("Videos")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // By the Numbers Tab
    struct ByTheNumbersView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    
                    infoRow(icon: "star.fill", color: .yellow,
                            text: "Planet Type: G-type main-sequence star")
                    
                    infoRow(icon: "circle.fill", color: .orange,
                            text: "Radius: ~696,340 km")
                    
                    infoRow(icon: "sun.max.fill", color: .red,
                            text: "Distance from Sun: 0 km (center of Solar System)")
                    
                    infoRow(icon: "moon.fill", color: .gray,
                            text: "Moons: None")
                    
                    infoRow(icon: "gauge", color: .green,
                            text: "Gravity: ~274 m/s²")
                    
                    infoRow(icon: "arrow.triangle.2.circlepath", color: .blue,
                            text: "Tilt of Axis: ~7.25°")
                    
                    infoRow(icon: "calendar", color: .purple,
                            text: "Length of Year: N/A (stationary)")
                    
                    infoRow(icon: "clock", color: .pink,
                            text: "Length of Day: ~25.38 Earth days")
                    
                    infoRow(icon: "thermometer", color: .red,
                            text: "Temperature: ~5,500°C (surface)")
                    
                    infoRow(icon: "hourglass", color: .teal,
                            text: "Age: ~4.6 billion years")
                }
                .padding()
                .transition(.move(edge: .leading))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.yellow.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
        
        // MARK: - Reusable Row Component (Compact)
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

    // Galleries Tab
    struct GalleriesView: View {
        let animation: Namespace.ID
        
        // Mock data (Thay bằng ảnh thật)
        let images = ["Sun", "Sun01", "Sun02", "Sun03", "Sun04", "Sun05"]
        
        var body: some View {
            ZStack {
                // 🌌 Cosmos Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.yellow.opacity(0.4), Color.orange.opacity(0.4)]),
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
                                    .frame(height: 180)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .purple.opacity(0.6), radius: 10, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(LinearGradient(
                                                gradient: Gradient(colors: [.yellow, .orange, .clear]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 2)
                                    )
                                    .matchedGeometryEffect(id: "gallery-\(image)", in: animation)
                                
                                // ✨ Overlay Title
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

    // Myth Tab
    struct MythView: View {
        let animation: Namespace.ID
        
        struct Myth: Identifiable {
            let id = UUID()
            let culture: String
            let godName: String
            let description: String
            let imageName: String
        }
        
        // Danh sách thần thoại
        private let myths: [Myth] = [
            Myth(culture: "Egyptian", godName: "Ra", description: "Ra was the Sun god, sailing across the sky each day and traveling through the underworld each night.", imageName: "egypt_sun"),
            Myth(culture: "Greek", godName: "Helios", description: "Helios drove his fiery chariot across the heavens, bringing daylight to the world.", imageName: "greek_sun"),
            Myth(culture: "Aztec", godName: "Tonatiuh", description: "Tonatiuh was the Aztec Sun god, demanding sacrifices to maintain cosmic order.", imageName: "aztec_sun"),
            Myth(culture: "Japanese", godName: "Amaterasu", description: "Amaterasu, the Sun goddess, was a central deity in Shinto, symbolizing light and life.", imageName: "japan_sun")
        ]
        
        var body: some View {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.black]),
                               startPoint: .bottom,
                               endPoint: .top)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("☀️ Sun Myths Across Cultures")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text("Throughout history, civilizations revered the Sun as a divine force, shaping myths and legends worldwide.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Myth Cards
                        ForEach(myths) { myth in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(myth.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.5), lineWidth: 1))
                                        .matchedGeometryEffect(id: "myth-\(myth.culture)", in: animation)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(myth.culture)
                                            .font(.headline)
                                            .foregroundColor(.yellow)
                                        Text(myth.godName)
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text(myth.description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(3) // Giới hạn số dòng
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .frame(width: 360, height: 200)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // Internal Tab
    struct InternalView: View {
        let animation: Namespace.ID
        
        // Data model for Sun layers
        struct SunLayer: Identifiable {
            let id = UUID()
            let name: String
            let description: String
            let color: LinearGradient
            let icon: String
        }
        
        private let layers: [SunLayer] = [
            SunLayer(
                name: "Core",
                description: "At 15 million °C, nuclear fusion happens here, producing the Sun’s immense energy.",
                color: LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "flame.fill"
            ),
            SunLayer(
                name: "Radiative Zone",
                description: "Energy slowly travels outward as radiation, taking thousands of years to escape.",
                color: LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "rays"
            ),
            SunLayer(
                name: "Convective Zone",
                description: "Hot gases move in convection currents, transporting energy to the surface.",
                color: LinearGradient(colors: [.yellow, .white], startPoint: .top, endPoint: .bottom),
                icon: "waveform.path.ecg"
            ),
            SunLayer(
                name: "Photosphere",
                description: "The visible surface (~5,500 °C), where sunlight escapes into space.",
                color: LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                icon: "sun.max.fill"
            ),
            SunLayer(
                name: "Chromosphere",
                description: "A reddish layer seen during eclipses, where solar prominences rise.",
                color: LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom),
                icon: "sparkles"
            ),
            SunLayer(
                name: "Corona",
                description: "The outer atmosphere, millions of km into space, hotter than the surface.",
                color: LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "globe.americas.fill"
            )
        ]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("☀️ Internal Layers of the Sun")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    ForEach(layers) { layer in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: layer.icon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(layer.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(layer.description)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .padding()
                        .frame(width: 360, height: 120)
                        .background(layer.color.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                    
                    // Sun Image
                    Image("Sun")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .matchedGeometryEffect(id: "internal-sun", in: animation)
                }
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.black, .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    // MARK: - In Depth Tab
    struct InDepthView: View {
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header Image
                    Image("Sun")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        .padding(.horizontal)
                        .matchedGeometryEffect(id: "indepth-sun", in: animation)
                    
                    // Title
                    Text("In-Depth Study of the Sun")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Info Cards
                    VStack(spacing: 16) {
                        InfoCardView(
                            icon: "wave.3.forward.circle.fill",
                            title: "Magnetic Fields",
                            description: "The Sun’s magnetic fields create sunspots and drive solar activity. These powerful forces shape the solar wind and influence space weather affecting Earth.",
                            iconColor: .cyan
                        )
                        
                        InfoCardView(
                            icon: "flame.fill",
                            title: "Solar Flares",
                            description: "Solar flares are bursts of energy and radiation that can disrupt communications and GPS signals. They are often associated with sunspot regions.",
                            iconColor: .orange
                        )
                        
                        InfoCardView(
                            icon: "bolt.fill",
                            title: "Coronal Mass Ejections",
                            description: "Massive clouds of plasma ejected from the Sun’s corona. CMEs can impact satellites, astronauts, and even cause geomagnetic storms on Earth.",
                            iconColor: .purple
                        )
                        
                        InfoCardView(
                            icon: "airplane",
                            title: "Scientific Missions",
                            description: "NASA’s Parker Solar Probe and ESA’s Solar Orbiter are studying the Sun closer than ever, providing unprecedented insights into heliophysics.",
                            iconColor: .green
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    // MARK: - Reusable Card Component
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
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }

    // 🚀 Exploration Tab - Beautiful Timeline
    struct ExplorationView: View {
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // 🌞 Header with image + overlay
                    ZStack(alignment: .bottomLeading) {
                        Image("Sun")
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
                        
                        Text("Exploration of the Sun")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding()
                    }
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    
                    // 🚀 Timeline Cards
                    VStack(alignment: .leading, spacing: 16) {
                        MissionCardView(
                            title: "SOHO (1995)",
                            description: "SOHO has been observing the Sun for over 25 years, monitoring solar winds and sunspots.",
                            icon: "sun.max.fill",
                            animation: animation,
                            id: "soho"
                        )
                        
                        MissionCardView(
                            title: "SDO (2010)",
                            description: "The Solar Dynamics Observatory provides stunning high-resolution images of the Sun’s atmosphere.",
                            icon: "camera.metering.matrix",
                            animation: animation,
                            id: "sdo"
                        )
                        
                        MissionCardView(
                            title: "Parker Solar Probe (2018)",
                            description: "The first spacecraft to 'touch' the Sun’s outer atmosphere, revolutionizing our understanding of solar winds.",
                            icon: "paperplane.fill",
                            animation: animation,
                            id: "parker"
                        )
                    }
                    .padding(.horizontal)
                    
                    // ✨ Highlight Quote
                    Text("“The Parker Solar Probe is humanity’s closest encounter with our star.”")
                        .font(.title3.italic())
                        .foregroundStyle(LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    // 📸 Showcase Image
                    Image("ParkerProbe")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }

    // 🌌 Reusable Card View
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

#Preview {
    SunView(
        planet: PlanetModel(name: "Sun", planetDescription: "The star at the center of the Solar System."),
        viewModel: SolarSystemViewModel()
    )
}
