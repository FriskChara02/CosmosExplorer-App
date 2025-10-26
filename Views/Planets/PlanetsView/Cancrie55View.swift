//
//  Cancrie55View.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 23/10/25.
//

import SwiftUI
import WebKit
import UIKit
import RealityKit

struct Cancrie55View: View {
    let planets: PlanetsModel
    @ObservedObject var viewModel: PlanetsViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = "Overview"
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]
    
    private let infoItems: [String] = [
        LanguageManager.current.string("Mass 7.99 Earths, orbits in 0.7 days"),
        LanguageManager.current.string("Super-Earth with possible diamond composition"),
        LanguageManager.current.string("Has a thick atmosphere detected by JWST"),
        LanguageManager.current.string("Surface temperature nearly 2400K, uninhabitable"),
        LanguageManager.current.string("Twice Earth's size, eight times more massive")
    ]
    
    init(planets: PlanetsModel, viewModel: PlanetsViewModel) {
        self.planets = planets
        self._isFavorite = State(initialValue: planets.isFavorite)
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
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("\(LanguageManager.current.string(selectedTab)) Planets")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        if selectedTab == "Wiki" {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/55_Cancri_e"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                planets.isFavorite = isFavorite
                                viewModel.toggleFavorite(planets: planets)
                            }
                        }
                    }) {
                        Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabBarCancrie55View(selectedTab: $selectedTab)
                
                // Nội dung tab
                VStack {
                    if selectedTab == "Overview" {
                        OverviewCancrie55View(
                            planets: planets,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == "Information" {
                        InformationCancrie55View(
                            planets: planets,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == "Galleries" {
                        GalleriesCancrie55View(animation: animation)
                    } else if selectedTab == "Comment" {
                        CommentCancrie55View()
                    } else if selectedTab == "Wiki" {
                        VStack {
                            Text(LanguageManager.current.string("Wikipedia: 55 Cancri e"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/55_Cancri_e")!)
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
            .background(Image("Cancrie55_background").resizable().scaledToFill().ignoresSafeArea())
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(planets: planets)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func updateRandomInfo() {
        randomInfo = infoItems.randomElement() ?? ""
    }
}

struct TabBarCancrie55View: View {
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

struct OverviewCancrie55View: View {
    let planets: PlanetsModel
    @Binding var glowIntensity: Float
    @Binding var randomInfo: String
    let animation: Namespace.ID
    @State private var dragRotationY: Float = 0
    @State private var dragRotationX: Float = 0
    @State private var isDragging: Bool = false
    var body: some View {
        ZStack {
            RealityView { content in
                let planetMesh = MeshResource.generateSphere(radius: 1.0)
                var planetMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Cancri55E_texture")
                    planetMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Cancri55E_texture") {
                        planetMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    planetMaterial.baseColor = .init(tint: .white)
                }
                
                planetMaterial.emissiveColor = .init(color: .red)
                planetMaterial.emissiveIntensity = 0.0
                planetMaterial.roughness = 0.9
                planetMaterial.metallic = 0.1
                
                let planetEntity = ModelEntity(mesh: planetMesh, materials: [planetMaterial])
                planetEntity.name = "Cancri55E"
                planetEntity.position = [0, 0, 0]
                
                var atmosphereComponent = ParticleEmitterComponent()
                atmosphereComponent.emitterShape = .sphere
                atmosphereComponent.emitterShapeSize = SIMD3<Float>(repeating: 1.1)
                atmosphereComponent.burstCount = 25
                atmosphereComponent.burstCountVariation = 5
                atmosphereComponent.speed = 0.12
                atmosphereComponent.speedVariation = 0.04
                atmosphereComponent.birthLocation = .surface
                atmosphereComponent.birthDirection = .normal
                atmosphereComponent.timing = .repeating(warmUp: 0.0, emit: .init(duration: 2.0), idle: .init(duration: 1.0))
                atmosphereComponent.particlesInheritTransform = true
                
                let atmosphereEntity = ModelEntity()
                atmosphereEntity.components.set(atmosphereComponent)
                atmosphereEntity.position = [0, 0, 0]
                planetEntity.addChild(atmosphereEntity)
                
                var atmosphereMaterial = UnlitMaterial()
                atmosphereMaterial.color = .init(tint: .red)
                atmosphereEntity.model = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.01), materials: [atmosphereMaterial])
                
                let pointLight = PointLight()
                pointLight.light.intensity = 2200
                pointLight.light.color = .white
                pointLight.position = [1, 1, 1]
                
                let spotLight = SpotLight()
                spotLight.light.intensity = 1200
                spotLight.light.color = .white
                spotLight.position = [2, 2, 2]
                spotLight.look(at: [0, 0, 0], from: spotLight.position, relativeTo: nil)
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 450
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(planetEntity)
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
                        planetEntity.transform.rotation = rotationY * rotationX
                        try? await Task.sleep(nanoseconds: 16_666_666)
                    }
                }
            }
            .frame(height: 300)
            .padding()
            .matchedGeometryEffect(id: "cancrie55-\(planets.id)", in: animation)
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
        Text(planets.name)
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

struct InformationCancrie55View: View {
    let planets: PlanetsModel
    @Binding var glowIntensity: Float
    @Binding var isFavorite: Bool
    @Binding var selectedTab: String
    let animation: Namespace.ID
    let viewModel: PlanetsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                RealityView { content in
                    let planetMesh = MeshResource.generateSphere(radius: 0.5)
                    var planetMaterial = PhysicallyBasedMaterial()
                    do {
                        let textureResource = try await TextureResource(named: "Cancri55E_texture")
                        planetMaterial.baseColor = .init(texture: .init(textureResource))
                        if let normalResource = try? await TextureResource(named: "Cancri55E_texture") {
                            planetMaterial.normal = .init(texture: .init(normalResource))
                        }
                    } catch {
                        print("Error loading texture: \(error)")
                        planetMaterial.baseColor = .init(tint: .white)
                    }
                    
                    planetMaterial.emissiveColor = .init(color: .red)
                    planetMaterial.emissiveIntensity = 0.0
                    planetMaterial.roughness = 0.9
                    planetMaterial.metallic = 0.1
                    
                    let planetEntity = ModelEntity(mesh: planetMesh, materials: [planetMaterial])
                    planetEntity.position = [0, 0, 0]
                    
                    content.add(planetEntity)
                    
                    Task { @MainActor in
                        var angle: Float = 0
                        while true {
                            angle += 0.01
                            let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                            planetEntity.transform.rotation = rotation
                            try? await Task.sleep(nanoseconds: 16_666_666)
                        }
                    }
                }
                .frame(height: 150)
                .matchedGeometryEffect(id: "cancrie55-\(planets.id)", in: animation)
                
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
                                    UIPasteboard.general.string = "https://en.wikipedia.org/wiki/55_Cancri_e"
                                } else {
                                    withAnimation(.spring()) {
                                        isFavorite.toggle()
                                        planets.isFavorite = isFavorite
                                        viewModel.toggleFavorite(planets: planets)
                                    }
                                }
                            }) {
                                Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(planets.aboutDescription.isEmpty ? LanguageManager.current.string("55 Cancri e is a super-Earth exoplanet with a possible diamond interior and thick atmosphere, extremely hot and close to its star.") : planets.aboutDescription)
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
                            NavigationLink(destination: VideoListCancrie55View(videoURLs: planets.videoURLs)) {
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
                            ForEach(planets.videoURLs.isEmpty ? [
                                "https://www.youtube.com/embed/QoD5vqd-hJ8",
                                "https://www.youtube.com/embed/IJNVHQuRcJ4"
                            ] : planets.videoURLs, id: \.self) { url in
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow(icon: "circle.fill", color: .orange, text: "\(LanguageManager.current.string("Radius")): \(planets.radius.isEmpty ? "Unknown" : planets.radius)")
                            infoRow(icon: "sun.max.fill", color: .red, text: "\(LanguageManager.current.string("Distance from Sun")): \(planets.distanceFromSun.isEmpty ? "Unknown" : planets.distanceFromSun)")
                            infoRow(icon: "hourglass", color: .teal, text: "\(LanguageManager.current.string("Age")): \(planets.age.isEmpty ? "Unknown" : planets.age)")
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

struct VideoListCancrie55View: View {
    let videoURLs: [String]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(videoURLs.isEmpty ? [
                    "https://www.youtube.com/embed/QoD5vqd-hJ8",
                    "https://www.youtube.com/embed/IJNVHQuRcJ4",
                    "https://www.youtube.com/embed/e9aqbMcYhsA",
                    "https://www.youtube.com/embed/qbwmHJDgnzo"
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
        .background(Image("Cancrie55_background").resizable().scaledToFill().ignoresSafeArea())
        .navigationTitle("Videos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleriesCancrie55View: View {
    let animation: Namespace.ID
    let images = ["Cancri55E", "Cancri55E01", "Cancri55E02", "Cancri55E03", "Cancri55E04", "Cancri55E05"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.red.opacity(0.4), Color.purple.opacity(0.4)]),
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
                                .shadow(color: .red.opacity(0.6), radius: 10, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [.red, .purple, .clear]),
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

struct CommentCancrie55View: View {
    var body: some View {
        Text("Phần Comment đang phát triển...")
            .font(.title2)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    Cancrie55View(
        planets: PlanetsModel(name: "55 Cancri e", planetsDescription: "A hot super-Earth.", planets_order: 0),
        viewModel: PlanetsViewModel()
    )
}
