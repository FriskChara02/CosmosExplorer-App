//
//  MercuryView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/9/25.
//

import SwiftUI
import RealityKit
import WebKit
import UIKit
import SwiftData

struct MercuryView: View {
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
        LanguageManager.current.string("Mercury Random Info 1"),
        LanguageManager.current.string("Mercury Random Info 2"),
        LanguageManager.current.string("Mercury Random Info 3"),
        LanguageManager.current.string("Mercury Random Info 4"),
        LanguageManager.current.string("Mercury Random Info 5")
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
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Mercury_(planet)"
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
                            Text(LanguageManager.current.string("Wikipedia: Mercury"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Mercury_(planet)")!)
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
        
        let tabs = [LanguageManager.current.string("Overview"),
                    LanguageManager.current.string("Information"),
                    LanguageManager.current.string("By the Numbers"),
                    LanguageManager.current.string("Galleries"),
                    LanguageManager.current.string("Myth"),
                    LanguageManager.current.string("Internal"),
                    LanguageManager.current.string("In Depth"),
                    LanguageManager.current.string("Exploration"),
                    LanguageManager.current.string("Comment"),
                    LanguageManager.current.string("Wiki")]
        
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
                    let mercuryMesh = MeshResource.generateSphere(radius: 1.0)
                    var mercuryMaterial = PhysicallyBasedMaterial()
                    do {
                        let textureResource = try await TextureResource(named: "Mercury_Texture")
                        mercuryMaterial.baseColor = .init(texture: .init(textureResource))
                        if let normalResource = try? await TextureResource(named: "Mercury_Texture") {
                            mercuryMaterial.normal = .init(texture: .init(normalResource))
                        }
                    } catch {
                        print("Error loading texture: \(error)")
                        mercuryMaterial.baseColor = .init(tint: .gray)
                    }
                    mercuryMaterial.roughness = 1.0
                    mercuryMaterial.metallic = 0.0
                    
                    let mercuryEntity = ModelEntity(mesh: mercuryMesh, materials: [mercuryMaterial])
                    mercuryEntity.name = "Mercury"
                    mercuryEntity.position = [0, 0, 0]
                    
                    let pointLight = PointLight()
                    pointLight.light.intensity = 2000
                    pointLight.light.color = .white
                    pointLight.position = [1, 1, 1]
                    
                    let ambientLight = PointLight()
                    ambientLight.light.intensity = 500
                    ambientLight.light.color = .white
                    ambientLight.position = [0, 0, 0]
                    
                    content.add(mercuryEntity)
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
                            mercuryEntity.transform.rotation = rotationY * rotationX
                            try? await Task.sleep(nanoseconds: 16_666_666)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                .matchedGeometryEffect(id: "mercury-\(planet.id)", in: animation)
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
                        let mercuryMesh = MeshResource.generateSphere(radius: 0.5)
                        var mercuryMaterial = PhysicallyBasedMaterial()
                        do {
                            let textureResource = try await TextureResource(named: "Mercury_Texture")
                            mercuryMaterial.baseColor = .init(texture: .init(textureResource))
                        } catch {
                            mercuryMaterial.baseColor = .init(tint: .gray)
                        }
                        mercuryMaterial.emissiveColor = .init(color: .white)
                        mercuryMaterial.emissiveIntensity = glowIntensity
                        mercuryMaterial.roughness = 1.0
                        mercuryMaterial.metallic = 0.0
                        
                        let mercuryEntity = ModelEntity(mesh: mercuryMesh, materials: [mercuryMaterial])
                        mercuryEntity.position = [0, 0, 0]
                        
                        content.add(mercuryEntity)
                        
                        Task { @MainActor in
                            var angle: Float = 0
                            while true {
                                angle += 0.01
                                let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                                mercuryEntity.transform.rotation = rotation
                                try? await Task.sleep(nanoseconds: 16_666_666)
                            }
                        }
                    }
                    .frame(height: 150)
                    .matchedGeometryEffect(id: "mercury-\(planet.id)", in: animation)
                    
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
                                        UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Mercury_(planet)"
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
                            
                            Text(LanguageManager.current.string("Mercury About Description"))
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
                                    "https://www.youtube.com/embed/0KBjnNuhRHs",
                                    "https://www.youtube.com/embed/XhKAxwfNW_c"
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
            "https://www.youtube.com/embed/0KBjnNuhRHs",
            "https://www.youtube.com/embed/XhKAxwfNW_c",
            "https://www.youtube.com/embed/rX_NCCpw5Uo",
            "https://www.youtube.com/embed/B588JHKSlEE",
            "https://www.youtube.com/embed/NWUsfud9PzM"
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
                    infoRow(icon: "globe", color: .gray,
                            text: LanguageManager.current.string("Mercury By The Numbers Planet Type"))
                    infoRow(icon: "circle.fill", color: .blue,
                            text: LanguageManager.current.string("Mercury By The Numbers Radius"))
                    infoRow(icon: "sun.max.fill", color: .yellow,
                            text: LanguageManager.current.string("Mercury By The Numbers Distance"))
                    infoRow(icon: "moon.fill", color: .gray,
                            text: LanguageManager.current.string("Mercury By The Numbers Moons"))
                    infoRow(icon: "gauge", color: .cyan,
                            text: LanguageManager.current.string("Mercury By The Numbers Gravity"))
                    infoRow(icon: "arrow.triangle.2.circlepath", color: .purple,
                            text: LanguageManager.current.string("Mercury By The Numbers Tilt"))
                    infoRow(icon: "calendar", color: .orange,
                            text: LanguageManager.current.string("Mercury By The Numbers Year"))
                    infoRow(icon: "clock", color: .pink,
                            text: LanguageManager.current.string("Mercury By The Numbers Day"))
                    infoRow(icon: "thermometer", color: .red,
                            text: LanguageManager.current.string("Mercury By The Numbers Temperature"))
                    infoRow(icon: "hourglass", color: .teal,
                            text: LanguageManager.current.string("Mercury By The Numbers Age"))
                }
                .padding()
                .transition(.move(edge: .leading))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]),
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
        let images = ["Mercury", "Mercury01", "Mercury02", "Mercury03", "Mercury04", "Mercury05"]
        
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.4), Color.blue.opacity(0.4)]),
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
                                    .shadow(color: .gray.opacity(0.6), radius: 10, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(LinearGradient(
                                                gradient: Gradient(colors: [.gray, .blue, .clear]),
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
            Myth(culture: LanguageManager.current.string("Roman Myth Culture"), godName: LanguageManager.current.string("Roman Myth God"), description: LanguageManager.current.string("Roman Myth Description"), imageName: "MercuryGod_Mercury"),
            Myth(culture: LanguageManager.current.string("Greek Myth Culture"), godName: LanguageManager.current.string("Greek Myth God"), description: LanguageManager.current.string("Greek Myth Description"), imageName: "MercuryGod_Hermes"),
            Myth(culture: LanguageManager.current.string("Egyptian Myth Culture"), godName: LanguageManager.current.string("Egyptian Myth God"), description: LanguageManager.current.string("Egyptian Myth Description"), imageName: "MercuryGod_Thoth"),
            Myth(culture: LanguageManager.current.string("Mayan Myth Culture"), godName: LanguageManager.current.string("Mayan Myth God"), description: LanguageManager.current.string("Mayan Myth Description"), imageName: "MercuryGod_Kukulkan")
        ]
        
        var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black]),
                               startPoint: .bottom,
                               endPoint: .top)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(LanguageManager.current.string("Mercury Myths Title"))
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text(LanguageManager.current.string("Mercury Myths Description"))
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
                                            .foregroundColor(.gray)
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
        
        struct MercuryLayer: Identifiable {
            let id = UUID()
            let name: String
            let description: String
            let color: LinearGradient
            let icon: String
        }
        
        private let layers: [MercuryLayer] = [
            MercuryLayer(
                name: LanguageManager.current.string("Mercury Layer Core"),
                description: LanguageManager.current.string("Mercury Layer Core Description"),
                color: LinearGradient(colors: [.red, .gray], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "flame.fill"
            ),
            MercuryLayer(
                name: LanguageManager.current.string("Mercury Layer Mantle"),
                description: LanguageManager.current.string("Mercury Layer Mantle Description"),
                color: LinearGradient(colors: [.gray, .brown], startPoint: .topLeading, endPoint: .bottomTrailing),
                icon: "globe.asia.australia.fill"
            ),
            MercuryLayer(
                name: LanguageManager.current.string("Mercury Layer Crust"),
                description: LanguageManager.current.string("Mercury Layer Crust Description"),
                color: LinearGradient(colors: [.brown, .gray], startPoint: .top, endPoint: .bottom),
                icon: "leaf.fill"
            )
        ]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text(LanguageManager.current.string("Mercury Internal Title"))
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
                    
                    Image("Mercury")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                        .matchedGeometryEffect(id: "internal-mercury", in: animation)
                }
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(colors: [.black, .gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    struct InDepthView: View {
        let animation: Namespace.ID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Image("Mercury")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        .padding(.horizontal)
                        .matchedGeometryEffect(id: "indepth-mercury", in: animation)
                    
                    Text(LanguageManager.current.string("Mercury In Depth Title"))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        InfoCardView(
                            icon: "flame.fill",
                            title: LanguageManager.current.string("Mercury In Depth Surface"),
                            description: LanguageManager.current.string("Mercury In Depth Surface Description"),
                            iconColor: .gray
                        )
                        
                        InfoCardView(
                            icon: "wave.3.forward.circle.fill",
                            title: LanguageManager.current.string("Mercury In Depth Craters"),
                            description: LanguageManager.current.string("Mercury In Depth Craters Description"),
                            iconColor: .blue
                        )
                        
                        InfoCardView(
                            icon: "cloud.fill",
                            title: LanguageManager.current.string("Mercury In Depth Atmosphere"),
                            description: LanguageManager.current.string("Mercury In Depth Atmosphere Description"),
                            iconColor: .cyan
                        )
                        
                        InfoCardView(
                            icon: "binoculars.fill",
                            title: LanguageManager.current.string("Mercury In Depth Missions"),
                            description: LanguageManager.current.string("Mercury In Depth Missions Description"),
                            iconColor: .purple
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
                        Image("Mercury")
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
                        
                        Text(LanguageManager.current.string("Mercury Exploration Title"))
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding()
                    }
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        MissionCardView(
                            title: LanguageManager.current.string("Mercury Mission Mariner"),
                            description: LanguageManager.current.string("Mercury Mission Mariner Description"),
                            icon: "pencil.and.scribble",
                            animation: animation,
                            id: "mariner"
                        )
                        
                        MissionCardView(
                            title: LanguageManager.current.string("Mercury Mission Messenger"),
                            description: LanguageManager.current.string("Mercury Mission Messenger Description"),
                            icon: "camera.metering.matrix",
                            animation: animation,
                            id: "messenger"
                        )
                        
                        MissionCardView(
                            title: LanguageManager.current.string("Mercury Mission BepiColombo"),
                            description: LanguageManager.current.string("Mercury Mission BepiColombo Description"),
                            icon: "pencil.and.outline",
                            animation: animation,
                            id: "bepicolombo"
                        )
                    }
                    .padding(.horizontal)
                    
                    Text(LanguageManager.current.string("Mercury Exploration Quote"))
                        .font(.title3.italic())
                        .foregroundStyle(LinearGradient(
                            colors: [.gray, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    Image("MercuryProbe")
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
                    .foregroundColor(.gray)
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
    MercuryView(
        planet: PlanetModel(name: "Mercury", planetDescription: "The smallest planet, closest to the Sun, with extreme temperatures."),
        viewModel: SolarSystemViewModel()
    )
}
