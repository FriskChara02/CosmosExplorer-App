//
//  SolarSystem3DView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/12/25.
//

import SwiftUI
import RealityKit
import simd

struct SolarSystem3DView: View {
    var body: some View {
        Planets3DView()
    }
}

struct Planet3DInfo: Equatable {
    let name: String
    let description: String
    let diameter: String
    let distance: String
}

struct Planets3DView: View {
    @State private var scale: Float = 1.0
    @State private var tempScale: Float = 1.0
    @State private var yaw: Float = 0.0
    @State private var pitch: Float = 0.0
    @State private var currentDragOffset: CGSize = .zero
    @State private var selectedPlanet: Planet3DInfo? = nil
    @State private var showUI: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    func getPlanetInfo(_ name: String) -> Planet3DInfo? {
        switch name {
        case "Sun":
            return Planet3DInfo(name: "Sun", description: "The star at the center of our Solar System", diameter: "1,392,700 km", distance: "0 km")
        case "Mercury":
            return Planet3DInfo(name: "Mercury", description: "Smallest planet, closest to the Sun", diameter: "4,879 km", distance: "57.9 million km")
        case "Venus":
            return Planet3DInfo(name: "Venus", description: "Hottest planet with thick atmosphere", diameter: "12,104 km", distance: "108.2 million km")
        case "Earth":
            return Planet3DInfo(name: "Earth", description: "Our home planet with life", diameter: "12,742 km", distance: "149.6 million km")
        case "Moon":
            return Planet3DInfo(name: "Moon", description: "Earth's natural satellite", diameter: "3,474 km", distance: "384,400 km from Earth")
        case "Mars":
            return Planet3DInfo(name: "Mars", description: "The Red Planet", diameter: "6,779 km", distance: "227.9 million km")
        case "Jupiter":
            return Planet3DInfo(name: "Jupiter", description: "Largest planet in Solar System", diameter: "139,820 km", distance: "778.5 million km")
        case "Saturn":
            return Planet3DInfo(name: "Saturn", description: "Famous for its beautiful rings", diameter: "116,460 km", distance: "1.434 billion km")
        case "Uranus":
            return Planet3DInfo(name: "Uranus", description: "Ice giant tilted on its side", diameter: "50,724 km", distance: "2.871 billion km")
        case "Neptune":
            return Planet3DInfo(name: "Neptune", description: "Farthest planet from the Sun", diameter: "49,244 km", distance: "4.495 billion km")
        default:
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            // 3D Solar System
            TimelineView(.animation) { timeline in
                RealityView { content in
                    await setupSolarSystem(in: content)
                } update: { content in
                    updateSolarSystem(in: content, timeline: timeline)
                }
                .gesture(
                    TapGesture()
                        .targetedToAnyEntity()
                        .onEnded { value in
                            if let info = getPlanetInfo(value.entity.name) {
                                withAnimation {
                                    selectedPlanet = info
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            tempScale = Float(value)
                        }
                        .onEnded { value in
                            scale *= Float(value)
                            tempScale = 1.0
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentDragOffset = value.translation
                        }
                        .onEnded { value in
                            yaw += Float(value.translation.width) * 0.01
                            pitch += Float(value.translation.height) * 0.01
                            currentDragOffset = .zero
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("BlackBG2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            
            // UI Controls
            VStack {
                HStack {
                    if showUI {
                        // Back button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    
                    // Hide UI button
                    Button(action: {
                        withAnimation {
                            showUI.toggle()
                        }
                    }) {
                        Image(systemName: showUI ? "eye.slash" : "eye")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Planet Info Card
            if let planet = selectedPlanet {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(planet.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPlanet = nil
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Text(planet.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(3)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .blue.opacity(0.4), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.vertical, 4)
                        
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.dashed")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue.opacity(0.8))
                                    
                                    Text("Diameter")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Text(planet.diameter)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.left.and.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.purple.opacity(0.8))
                                    
                                    Text("Distance")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Text(planet.distance)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.45))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                    )
                    .padding(20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut, value: showUI)
        .animation(.easeInOut, value: selectedPlanet)
    }
    
    
    // MARK: - Setup Solar System
    func setupSolarSystem(in content: RealityViewCameraContent) async {
        let rootEntity = Entity()
        rootEntity.name = "Root"
        
        let planets: [(name: String, texture: String, radius: Float, position: Float, fallback: Color)] = [
            ("Sun", "Sun_Texture", 0.5, 0, .yellow),
            ("Mercury", "Mercury_Texture", 0.12, 0.7, .gray),
            ("Venus", "Venus_Texture", 0.18, 1.1, .orange),
            ("Earth", "Earth_Texture", 0.19, 1.5, .blue),
            ("Moon", "Moon_Texture", 0.08, 1.8, .gray),
            ("Mars", "Mars_Texture", 0.15, 2.0, .red),
            ("Jupiter", "Jupiter_Texture", 0.4, 2.8, .orange),
            ("Saturn", "Saturn_Texture", 0.35, 3.5, .yellow),
            ("Uranus", "Uranus_Texture", 0.22, 4.2, .cyan),
            ("Neptune", "Neptune_Texture", 0.21, 4.8, .blue)
        ]
        
        for planet in planets {
            let mesh = MeshResource.generateSphere(radius: planet.radius)
            var material = PhysicallyBasedMaterial()
            
            do {
                let texture = try await TextureResource(named: planet.texture)
                material.baseColor = .init(texture: .init(texture))
            } catch {
                material.baseColor = .init(tint: .cyan)
            }
            
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = planet.name
            entity.position = [planet.position, 0, 0]
            entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: planet.radius)]))
            entity.components.set(InputTargetComponent())
            rootEntity.addChild(entity)
        }
        
        // Light
        let light = PointLight()
        light.light.intensity = 2000
        light.light.color = .white
        light.position = [0, 0, 3]
        rootEntity.addChild(light)
        
        content.add(rootEntity)
    }
    
    // MARK: - Update Solar System
    func updateSolarSystem(in content: RealityViewCameraContent, timeline: TimelineViewDefaultContext) {
        let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
        
        guard let root = content.entities.first(where: { $0.name == "Root" }) else { return }
        
        // Rotation
        let rotations: [(String, Float)] = [
            ("Sun", 0.8), ("Mercury", 0.5), ("Venus", 0.5),
            ("Earth", 0.5), ("Moon", 0.8), ("Mars", 0.5),
            ("Jupiter", 0.5), ("Saturn", 0.5), ("Uranus", 0.5), ("Neptune", 0.5)
        ]
        
        for (name, speed) in rotations {
            if let entity = root.findEntity(named: name) {
                entity.transform.rotation = simd_quatf(angle: angle * speed, axis: [0, 1, 0])
            }
        }
        
        // Orbits
        let orbits: [(String, Float, Float)] = [
            ("Mercury", 0.7, 0.1), ("Venus", 1.1, 0.08), ("Earth", 1.5, 0.06),
            ("Mars", 2.0, 0.05), ("Jupiter", 2.8, 0.04), ("Saturn", 3.5, 0.03),
            ("Uranus", 4.2, 0.02), ("Neptune", 4.8, 0.01)
        ]
        
        for (name, radius, speed) in orbits {
            if let entity = root.findEntity(named: name) {
                let a = angle * speed
                entity.position = [radius * cos(a), 0, radius * sin(a)]
            }
        }
        
        // Moon orbit around Earth
        if let earth = root.findEntity(named: "Earth"),
           let moon = root.findEntity(named: "Moon") {
            let a = angle * 0.2
            moon.position = earth.position + [0.3 * cos(a), 0, 0.3 * sin(a)]
        }
        
        // Scale & Rotation
        root.scale = SIMD3(repeating: scale * tempScale)
        let yawQ = simd_quatf(angle: yaw + Float(currentDragOffset.width) * 0.01, axis: [0, 1, 0])
        let pitchQ = simd_quatf(angle: pitch + Float(currentDragOffset.height) * 0.01, axis: [1, 0, 0])
        root.transform.rotation = yawQ * pitchQ
    }
}

#Preview {
    SolarSystem3DView()
}
