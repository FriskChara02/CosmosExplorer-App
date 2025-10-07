import SwiftUI
import RealityKit
import WebKit
import UIKit
import SwiftData

struct SaturnView: View {
    let planet: PlanetModel
    @ObservedObject var viewModel: SolarSystemViewModel
    @State private var glowIntensity: Float = 0.8
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = "Overview"
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    private let infoItems: [String] = [
        LanguageManager.current.string("Saturn Random Info 1"),
        LanguageManager.current.string("Saturn Random Info 2"),
        LanguageManager.current.string("Saturn Random Info 3"),
        LanguageManager.current.string("Saturn Random Info 4"),
        LanguageManager.current.string("Saturn Random Info 5")
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
                    Text("\(LanguageManager.current.string(selectedTab)) Planet")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == "Wiki" {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Saturn"
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
                            Text(LanguageManager.current.string("Wikipedia: Saturn"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Saturn")!)
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
        randomInfo = infoItems.randomElement() ?? ""
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
        @State private var dragRotationY: Float = 0
        @State private var dragRotationX: Float = 0
        @State private var isDragging: Bool = false

        var body: some View {
            ZStack {
                RealityView { content in
                    // Saturn Mesh
                    let saturnMesh = MeshResource.generateSphere(radius: 0.6)
                    var saturnMaterial = PhysicallyBasedMaterial()
                    do {
                        let textureResource = try await TextureResource(named: "Saturn_Texture")
                        saturnMaterial.baseColor = .init(texture: .init(textureResource))
                        if let normalResource = try? await TextureResource(named: "Saturn_Texture") {
                            saturnMaterial.normal = .init(texture: .init(normalResource))
                        }
                    } catch {
                        print("Error loading texture: \(error)")
                        saturnMaterial.baseColor = .init(tint: .yellow)
                    }
                    saturnMaterial.emissiveIntensity = glowIntensity
                    saturnMaterial.roughness = 1.0
                    saturnMaterial.metallic = 0.0
                    
                    let saturnEntity = ModelEntity(mesh: saturnMesh, materials: [saturnMaterial])
                    saturnEntity.name = "Saturn"
                    saturnEntity.position = [0, 0, 0]
                    
                    // Rings Mesh
                    let ringEntity = SaturnView.makeRing(outerRadius: 1.08, innerRadius: 0.8, thickness: 0.01)
                    ringEntity.name = "SaturnRings"
                    ringEntity.position = [0, 0, 0]
                    ringEntity.transform.rotation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                    
                    // Lighting
                    let pointLight = PointLight()
                    pointLight.light.intensity = 2000
                    pointLight.light.color = .white
                    pointLight.position = [1.5, 1.5, 1.5]
                    
                    let ambientLight = PointLight()
                    ambientLight.light.intensity = 400
                    ambientLight.light.color = .white
                    ambientLight.position = [0, 0, 0]
                    
                    content.add(saturnEntity)
                    content.add(ringEntity)
                    content.add(pointLight)
                    content.add(ambientLight)
                    
                    Task { @MainActor in
                        var angle: Float = 0
                        while true {
                            if !isDragging {
                                angle += 0.01
                            }
                            let rotationY = simd_quatf(angle: angle + dragRotationY, axis: [0, 1, 0])
                            let rotationX = simd_quatf(angle: dragRotationX, axis: [1, 0, 0])
                            saturnEntity.transform.rotation = rotationY * rotationX
                            ringEntity.transform.rotation = rotationY * rotationX * simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                            try? await Task.sleep(nanoseconds: 16_666_666)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                .matchedGeometryEffect(id: "saturn-\(planet.id)", in: animation)
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
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                isDragging = false
                            }
                        }
                )
                
                // 360° Icon and Text
                VStack {
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 0, y: -220)
                    Text(LanguageManager.current.string("360°"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(x: 0, y: -215)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Planet Name and Random Info
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
                        // Saturn Mesh
                        let saturnMesh = MeshResource.generateSphere(radius: 0.3)
                        var saturnMaterial = PhysicallyBasedMaterial()
                        do {
                            let textureResource = try await TextureResource(named: "Saturn_Texture")
                            saturnMaterial.baseColor = .init(texture: .init(textureResource))
                        } catch {
                            saturnMaterial.baseColor = .init(tint: .yellow)
                        }
                        saturnMaterial.emissiveIntensity = glowIntensity
                        saturnMaterial.roughness = 1.0
                        saturnMaterial.metallic = 0.0
                        
                        let saturnEntity = ModelEntity(mesh: saturnMesh, materials: [saturnMaterial])
                        saturnEntity.position = [0, 0, 0]
                        
                        // Rings Mesh
                        let ringEntity = SaturnView.makeRing(outerRadius: 0.45, innerRadius: 0.37, thickness: 0.01)
                        ringEntity.name = "SaturnRings"
                        ringEntity.position = [0, 0, 0]
                        ringEntity.transform.rotation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                        
                        // Lighting
                        let pointLight = PointLight()
                        pointLight.light.intensity = 2000
                        pointLight.light.color = .white
                        pointLight.position = [1.5, 1.5, 1.5]
                        
                        let ambientLight = PointLight()
                        ambientLight.light.intensity = 400
                        ambientLight.light.color = .white
                        ambientLight.position = [0, 0, 0]
                        
                        content.add(saturnEntity)
                        content.add(ringEntity)
                        content.add(pointLight)
                        content.add(ambientLight)
                        
                        Task { @MainActor in
                            var angle: Float = 0
                            while true {
                                angle += 0.01
                                let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                                saturnEntity.transform.rotation = rotation
                                ringEntity.transform.rotation = rotation * simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                                try? await Task.sleep(nanoseconds: 16_666_666)
                            }
                        }
                    }
                    .frame(height: 150)
                    .matchedGeometryEffect(id: "saturn-\(planet.id)", in: animation)
                    
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
                                    if selectedTab == "Wiki" {
                                        UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Saturn"
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
                            
                            Text(LanguageManager.current.string("Saturn About Description"))
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
                                NavigationLink(destination: VideoListView()) {
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
                                ForEach([
                                    "https://www.youtube.com/embed/7qyKZz844o0",
                                    "https://www.youtube.com/embed/iBsJFhy7xN4"
                                ],  id: \.self) { url in
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
    
    struct VideoListView: View {
        let videoURLs = [
            "https://www.youtube.com/embed/Qmm-vJj--iA",
            "https://www.youtube.com/embed/R_y3lB0lNmo",
            "https://www.youtube.com/embed/epZdZaEQhS0",
            "https://www.youtube.com/embed/ozTLbOcTcZ4",
            "https://www.youtube.com/embed/33yOQsptNis",
            "https://www.youtube.com/embed/6Bv8g5xBJSo",
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
    
    struct ByTheNumbersView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    infoRow(icon: "star.fill", color: .yellow,
                            text: LanguageManager.current.string("Saturn By The Numbers Planet Type"))
                    infoRow(icon: "circle.fill", color: .orange,
                            text: LanguageManager.current.string("Saturn By The Numbers Radius"))
                    infoRow(icon: "sun.max.fill", color: .red,
                            text: LanguageManager.current.string("Saturn By The Numbers Distance"))
                    infoRow(icon: "moon.fill", color: .gray,
                            text: LanguageManager.current.string("Saturn By The Numbers Moons"))
                    infoRow(icon: "gauge", color: .green,
                            text: LanguageManager.current.string("Saturn By The Numbers Gravity"))
                    infoRow(icon: "arrow.triangle.2.circlepath", color: .blue,
                            text: LanguageManager.current.string("Saturn By The Numbers Tilt"))
                    infoRow(icon: "calendar", color: .purple,
                            text: LanguageManager.current.string("Saturn By The Numbers Year"))
                    infoRow(icon: "clock", color: .pink,
                            text: LanguageManager.current.string("Saturn By The Numbers Day"))
                    infoRow(icon: "thermometer", color: .red,
                            text: LanguageManager.current.string("Saturn By The Numbers Temperature"))
                    infoRow(icon: "hourglass", color: .teal,
                            text: LanguageManager.current.string("Saturn By The Numbers Age"))
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
        let animation: Namespace.ID
        let images = ["Saturn", "Saturn01", "Saturn02", "Saturn03", "Saturn04", "Saturn05"]
        
        var body: some View {
            ZStack {
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
                                    .frame(width: 180, height: 180)
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

    struct MythView: View {
        let animation: Namespace.ID
        
        struct Myth: Identifiable {
            let id = UUID()
            let culture: String
            let godName: String
            let description: String
            let imageName: String
        }
        
        private let myths: [Myth] = [
            Myth(culture: LanguageManager.current.string("Roman Myth Culture"), godName: LanguageManager.current.string("Roman Myth God"), description: LanguageManager.current.string("Roman Myth Description"), imageName: "SaturnGod_Saturn"),
            Myth(culture: LanguageManager.current.string("Greek Myth Culture"), godName: LanguageManager.current.string("Greek Myth God"), description: LanguageManager.current.string("Greek Myth Description"), imageName: "SaturnGod_Cronus"),
            Myth(culture: LanguageManager.current.string("Hindu Myth Culture"), godName: LanguageManager.current.string("Hindu Myth God"), description: LanguageManager.current.string("Hindu Myth Description"), imageName: "SaturnGod_Shani")
        ]
        
        var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.black]),
                               startPoint: .bottom,
                               endPoint: .top)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(LanguageManager.current.string("Saturn Myths Title"))
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text(LanguageManager.current.string("Saturn Myths Description"))
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
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
                                    .lineLimit(3)
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

    struct InternalView: View {
        let animation: Namespace.ID
        
        struct SaturnLayer: Identifiable {
            let id = UUID()
            let name: String
            let description: String
            let color: LinearGradient
            let icon: String
        }
        
        private let layers: [SaturnLayer] = [
            SaturnLayer(
                name: LanguageManager.current.string("Saturn Layer Core"),
                description: LanguageManager.current.string("Saturn Layer Core Description"),
                color: LinearGradient(colors: [.gray, .white], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "flame.fill"
            ),
            SaturnLayer(
                name: LanguageManager.current.string("Saturn Layer Mantle"),
                description: LanguageManager.current.string("Saturn Layer Mantle Description"),
                color: LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "cloud.fill"
            ),
            SaturnLayer(
                name: LanguageManager.current.string("Saturn Layer Atmosphere"),
                description: LanguageManager.current.string("Saturn Layer Atmosphere Description"),
                color: LinearGradient(colors: [.blue, .yellow], startPoint: .top, endPoint: .bottom),
                icon: "wind"
            )
        ]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text(LanguageManager.current.string("Saturn Internal Title"))
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
                    
                    Image("Saturn")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .matchedGeometryEffect(id: "internal-saturn", in: animation)
                }
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.black, .yellow.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    struct InDepthView: View {
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Image("Saturn")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        .padding(.horizontal)
                        .matchedGeometryEffect(id: "indepth-saturn", in: animation)
                    
                    Text(LanguageManager.current.string("Saturn In Depth Title"))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        InfoCardView(
                            icon: "circle.dashed",
                            title: LanguageManager.current.string("Saturn In Depth Rings"),
                            description: LanguageManager.current.string("Saturn In Depth Rings Description"),
                            iconColor: .cyan
                        )
                        InfoCardView(
                            icon: "cloud.fill",
                            title: LanguageManager.current.string("Saturn In Depth Atmosphere"),
                            description: LanguageManager.current.string("Saturn In Depth Atmosphere Description"),
                            iconColor: .orange
                        )
                        InfoCardView(
                            icon: "moon.stars.fill",
                            title: LanguageManager.current.string("Saturn In Depth Moons"),
                            description: LanguageManager.current.string("Saturn In Depth Moons Description"),
                            iconColor: .purple
                        )
                        InfoCardView(
                            icon: "airplane",
                            title: LanguageManager.current.string("Saturn In Depth Missions"),
                            description: LanguageManager.current.string("Saturn In Depth Missions Description"),
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

    struct ExplorationView: View {
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack(alignment: .bottomLeading) {
                        Image("Saturn")
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
                        Text(LanguageManager.current.string("Saturn Exploration Title"))
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding()
                    }
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        MissionCardView(
                            title: LanguageManager.current.string("Saturn Mission Pioneer"),
                            description: LanguageManager.current.string("Saturn Mission Pioneer Description"),
                            icon: "airplane",
                            animation: animation,
                            id: "pioneer"
                        )
                        MissionCardView(
                            title: LanguageManager.current.string("Saturn Mission Voyager"),
                            description: LanguageManager.current.string("Saturn Mission Voyager Description"),
                            icon: "star.hexagon.fill",
                            animation: animation,
                            id: "voyager"
                        )
                        MissionCardView(
                            title: LanguageManager.current.string("Saturn Mission Cassini"),
                            description: LanguageManager.current.string("Saturn Mission Cassini Description"),
                            icon: "paperplane.fill",
                            animation: animation,
                            id: "cassini"
                        )
                    }
                    .padding(.horizontal)
                    
                    Text(LanguageManager.current.string("Saturn Exploration Quote"))
                        .font(.title3.italic())
                        .foregroundStyle(LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    Image("CassiniProbe")
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
    
    // Tạo vòng 3D
    static func makeRing(outerRadius: Float, innerRadius: Float, thickness: Float, segments: Int = 100) -> ModelEntity {
        var meshDescriptor = MeshDescriptor()
        
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureCoordinates: [SIMD2<Float>] = []
        
        let angleStep = Float.pi * 2 / Float(segments)
        
        // Tạo các đỉnh cho vòng (vành đai)
        for i in 0..<segments {
            let angle = angleStep * Float(i)
            let cosAngle = cos(angle)
            let sinAngle = sin(angle)
            
            // Nội vi và ngoại vi của vòng
            let outerX = outerRadius * cosAngle
            let outerZ = outerRadius * sinAngle
            let innerX = innerRadius * cosAngle
            let innerZ = innerRadius * sinAngle
            
            // Thêm đỉnh cho mặt trên và dưới của vòng để tạo độ dày
            positions.append([innerX, -thickness / 2, innerZ]) // Nội vi, mặt dưới
            positions.append([outerX, -thickness / 2, outerZ]) // Ngoại vi, mặt dưới
            positions.append([innerX, thickness / 2, innerZ])  // Nội vi, mặt trên
            positions.append([outerX, thickness / 2, outerZ])  // Ngoại vi, mặt trên
            
            // Tọa độ texture
            let u = Float(i) / Float(segments)
            textureCoordinates.append([u, 0]) // Nội vi, mặt dưới
            textureCoordinates.append([u, 1]) // Ngoại vi, mặt dưới
            textureCoordinates.append([u, 0]) // Nội vi, mặt trên
            textureCoordinates.append([u, 1]) // Ngoại vi, mặt trên
            
            // Pháp tuyến (hướng lên/xuống để ánh sáng hiển thị đúng)
            normals.append([0, -1, 0]) // Mặt dưới
            normals.append([0, -1, 0]) // Mặt dưới
            normals.append([0, 1, 0])  // Mặt trên
            normals.append([0, 1, 0])  // Mặt trên
        }
        
        // Tạo chỉ số cho các tam giác
        for i in 0..<segments {
            let base = UInt32(i * 4)
            let next = UInt32(((i + 1) % segments) * 4)
            
            // Mặt trên
            indices.append(contentsOf: [
                base + 2, base + 3, next + 2,
                base + 3, next + 3, next + 2
            ])
            
            // Mặt dưới
            indices.append(contentsOf: [
                base + 1, base, next,
                base + 1, next, next + 1
            ])
            
            // Mặt ngoài
            indices.append(contentsOf: [
                base + 3, base + 1, next + 3,
                base + 1, next + 1, next + 3
            ])
            
            // Mặt trong
            indices.append(contentsOf: [
                base, base + 2, next + 2,
                base, next + 2, next
            ])
        }
        
        meshDescriptor.positions = MeshBuffer(positions)
        meshDescriptor.normals = MeshBuffer(normals)
        meshDescriptor.textureCoordinates = MeshBuffer(textureCoordinates)
        meshDescriptor.primitives = .triangles(indices)
        
        let meshResource = try! MeshResource.generate(from: [meshDescriptor])
        var ringMaterial = PhysicallyBasedMaterial()
        do {
            let ringTexture = try TextureResource.load(named: "SaturnRing_Texture")
            ringMaterial.baseColor = .init(tint: .white.withAlphaComponent(0.4), texture: .init(ringTexture))
        } catch {
            print("Error loading ring texture: \(error)")
            ringMaterial.baseColor = .init(tint: .white.withAlphaComponent(0.4))
        }
        ringMaterial.roughness = 1.0
        ringMaterial.metallic = 0.0
        
        return ModelEntity(mesh: meshResource, materials: [ringMaterial])
    }
}

#Preview {
    SaturnView(
        planet: PlanetModel(name: "Saturn", planetDescription: "The ringed gas giant of the Solar System."),
        viewModel: SolarSystemViewModel()
    )
}
