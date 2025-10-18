//
//  SiriusView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI
import WebKit
import UIKit
import RealityKit

struct SiriusView: View {
    let star: StarModel
    @ObservedObject var viewModel: StarViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = LanguageManager.current.string("Overview")
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]

    private let infoItems: [String] = [
        LanguageManager.current.string("Sirius Random Info 1"),
        LanguageManager.current.string("Sirius Random Info 2"),
        LanguageManager.current.string("Sirius Random Info 3"),
        LanguageManager.current.string("Sirius Random Info 4"),
        LanguageManager.current.string("Sirius Random Info 5")
    ]

    init(star: StarModel, viewModel: StarViewModel) {
        self.star = star
        self._isFavorite = State(initialValue: star.isFavorite)
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
                    Text("\(LanguageManager.current.string(selectedTab)) Star")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == LanguageManager.current.string("Wiki") {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Sirius"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                viewModel.toggleFavorite(star: star)
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

                TabBarSiriusView(selectedTab: $selectedTab)

                // Nội dung tab
                VStack {
                    if selectedTab == LanguageManager.current.string("Overview") {
                        OverviewSiriusView(
                            star: star,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == LanguageManager.current.string("Information") {
                        InformationSiriusView(
                            star: star,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == LanguageManager.current.string("Galleries") {
                        GalleriesSiriusView(animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Comment") {
                        CommentSiriusView()
                    } else if selectedTab == LanguageManager.current.string("Wiki") {
                        VStack {
                            Text(LanguageManager.current.string("Wikipedia: Sirius Star"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Sirius")!)
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
            .background(Image("Sirius_background").resizable().scaledToFill().ignoresSafeArea().overlay(Color.black.opacity(0.4)))
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(star: star)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func updateRandomInfo() {
        randomInfo = infoItems.randomElement() ?? ""
    }
}

struct TabBarSiriusView: View {
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
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
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
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
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

struct OverviewSiriusView: View {
    let star: StarModel
    @Binding var glowIntensity: Float
    @Binding var randomInfo: String
    let animation: Namespace.ID
    @State private var dragRotationY: Float = 0
    @State private var dragRotationX: Float = 0
    @State private var isDragging: Bool = false

    var body: some View {
        ZStack {
            RealityView { content in
                let siriusMesh = MeshResource.generateSphere(radius: 1.0)
                var siriusMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Star_texture")
                    siriusMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Star_texture") {
                        siriusMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    siriusMaterial.baseColor = .init(tint: .white)
                }
                
                siriusMaterial.emissiveColor = .init(color: .cyan)
                siriusMaterial.emissiveIntensity = 4.0
                siriusMaterial.roughness = 1.0
                siriusMaterial.metallic = 0.0
                
                let siriusEntity = ModelEntity(mesh: siriusMesh, materials: [siriusMaterial])
                siriusEntity.name = "Sirius"
                siriusEntity.position = [0, 0, 0]
                
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
                siriusEntity.addChild(flareEntity)
                
                var flareMaterial = UnlitMaterial()
                flareMaterial.color = .init(tint: .blue)
                flareEntity.model = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.01), materials: [flareMaterial])
                
                let pointLight = PointLight()
                pointLight.light.intensity = 2500
                pointLight.light.color = .white
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
                
                content.add(siriusEntity)
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
                        siriusEntity.transform.rotation = rotationY * rotationX
                        try? await Task.sleep(nanoseconds: 16_666_666)
                    }
                }
            }
            .frame(height: 300)
            .padding()
            .matchedGeometryEffect(id: "sirius-\(star.id)", in: animation)
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
        Text(star.name)
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

struct InformationSiriusView: View {
    let star: StarModel
    @Binding var glowIntensity: Float
    @Binding var isFavorite: Bool
    @Binding var selectedTab: String
    let animation: Namespace.ID
    let viewModel: StarViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                RealityView { content in
                    let siriusMesh = MeshResource.generateSphere(radius: 0.5)
                    var siriusMaterial = PhysicallyBasedMaterial()
                    do {
                        let textureResource = try await TextureResource(named: "Star_texture")
                        siriusMaterial.baseColor = .init(texture: .init(textureResource))
                        if let normalResource = try? await TextureResource(named: "Star_texture") {
                            siriusMaterial.normal = .init(texture: .init(normalResource))
                        }
                    } catch {
                        print("Error loading texture: \(error)")
                        siriusMaterial.baseColor = .init(tint: .white)
                    }
                    
                    siriusMaterial.emissiveColor = .init(color: .cyan)
                    siriusMaterial.emissiveIntensity = 4.0
                    siriusMaterial.roughness = 1.0
                    siriusMaterial.metallic = 0.0
                    
                    let siriusEntity = ModelEntity(mesh: siriusMesh, materials: [siriusMaterial])
                    siriusEntity.position = [0, 0, 0]
                    
                    content.add(siriusEntity)
                    
                    Task { @MainActor in
                        var angle: Float = 0
                        while true {
                            angle += 0.01
                            let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                            siriusEntity.transform.rotation = rotation
                            try? await Task.sleep(nanoseconds: 16_666_666)
                        }
                    }
                }
                .frame(height: 150)
                .matchedGeometryEffect(id: "sirius-\(star.id)", in: animation)
                
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
                                    UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Sirius"
                                } else {
                                    withAnimation(.spring()) {
                                        isFavorite.toggle()
                                        viewModel.toggleFavorite(star: star)
                                    }
                                }
                            }) {
                                Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)

                        Text(star.aboutDescription.isEmpty ? LanguageManager.current.string("Sirius About Description") : star.aboutDescription)
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
                            NavigationLink(destination: VideoListSiriusView(videoURLs: star.videoURLs)) {
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
                            ForEach(star.videoURLs.isEmpty ? [
                                "https://www.youtube.com/embed/X7otJuJ_7Wk",
                                "https://www.youtube.com/embed/59RDcBcxJqo"
                            ] : star.videoURLs, id: \.self) { url in
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
                            infoCard(icon: "circle.fill", color: .orange, title: LanguageManager.current.string("Radius"), value: star.radius.isEmpty ? LanguageManager.current.string("~1.711 solar radii") : star.radius)
                            infoCard(icon: "sun.max.fill", color: .red, title: LanguageManager.current.string("Distance from Sun"), value: star.distanceFromSun.isEmpty ? LanguageManager.current.string("~8.6 light-years") : star.distanceFromSun)
                            infoCard(icon: "hourglass", color: .teal, title: LanguageManager.current.string("Age"), value: star.age.isEmpty ? LanguageManager.current.string("~242 million years") : star.age)
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

struct VideoListSiriusView: View {
    let videoURLs: [String]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(videoURLs.isEmpty ? [
                    "https://www.youtube.com/embed/X7otJuJ_7Wk",
                    "https://www.youtube.com/embed/59RDcBcxJqo",
                    "https://www.youtube.com/embed/L6nngEFKPsk",
                    "https://www.youtube.com/embed/zKrVLc2wb_c"
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
        .background(Image("Sirius_background").resizable().scaledToFill().ignoresSafeArea())
        .navigationTitle(LanguageManager.current.string("Videos"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleriesSiriusView: View {
    let animation: Namespace.ID
    let images = ["Sirius_background", "Sirius01", "Sirius02", "Sirius03", "Sirius04", "Sirius05", "Sirius06"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.1), Color.cyan.opacity(0.4), Color.white.opacity(0.4)]),
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
                                            gradient: Gradient(colors: [.cyan, .white, .clear]),
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

struct CommentSiriusView: View {
    var body: some View {
        Text(LanguageManager.current.string("Comment Under Development"))
            .font(.title2)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    SiriusView(
        star: StarModel(name: "Sirius", starDescription: "The brightest star in the night sky.", star_order: 0),
        viewModel: StarViewModel()
    )
}
