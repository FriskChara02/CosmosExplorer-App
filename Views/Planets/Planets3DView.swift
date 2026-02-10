//
//  Planets3DView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/12/25.
//

import SwiftUI
import RealityKit
import simd

struct Planet3DView: View {
    var body: some View {
        ExoPlanets3DView()
    }
}

struct ExoPlanet3DInfo: Equatable {
    let name: String
    let description: String
    let diameter: String
    let distance: String
}

struct ExoPlanets3DView: View {
    @State private var scale: Float = 1.0
    @State private var tempScale: Float = 1.0
    @State private var rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    @State private var currentDragOffset: CGSize = .zero
    @State private var selectedPlanet: ExoPlanet3DInfo? = nil
    @State private var showUI: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    func getPlanetInfo(_ name: String) -> ExoPlanet3DInfo? {
        switch name {
        case "Sun":
            return ExoPlanet3DInfo(name: "Sun", description: "The star at the center of our Solar System", diameter: "1,392,700 km", distance: "0 km")
        case "Earth":
            return ExoPlanet3DInfo(name: "Earth", description: "Our home planet with life", diameter: "12,742 km", distance: "149.6 million km")
        case "Proxima b":
            return ExoPlanet3DInfo(name: "Proxima b", description: "Closest exoplanet in habitable zone", diameter: "~14,000 km", distance: "4.24 light-years")
        case "Kepler-452b":
            return ExoPlanet3DInfo(name: "Kepler-452b", description: "Earth's cousin in habitable zone", diameter: "~19,000 km", distance: "1,400 light-years")
        case "55 Cancri e":
            return ExoPlanet3DInfo(name: "55 Cancri e", description: "Super-Earth diamond planet", diameter: "~24,000 km", distance: "41 light-years")
        default:
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            // 3D Exoplanets System
            TimelineView(.animation) { timeline in
                RealityView { content in
                    await setupExoplanetsSystem(in: content)
                } update: { content in
                    updateExoplanetsSystem(in: content, timeline: timeline)
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
                            let yawDelta = Float(value.translation.width) * 0.01
                            let pitchDelta = Float(value.translation.height) * 0.01
                            
                            let yawRotation = simd_quatf(angle: yawDelta, axis: [0, 1, 0])
                            let pitchRotation = simd_quatf(angle: pitchDelta, axis: [1, 0, 0])
                            
                            rotation = yawRotation * rotation * pitchRotation
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
    
    
    // MARK: - Setup Exoplanets System
    func setupExoplanetsSystem(in content: RealityViewCameraContent) async {
        let rootEntity = Entity()
        rootEntity.name = "Root"
        
        let planets: [(name: String, texture: String, radius: Float, position: Float, fallback: Color)] = [
            ("Earth", "Earth_Texture", 0.19, 0, .blue),
            ("Sun", "Sun_Texture", 0.5, -0.75, .yellow),
            ("Proxima b", "ProximaB_texture", 0.2, 0.45, .red),
            ("Kepler-452b", "Kepler452B_texture", 0.25, 1, .green),
            ("55 Cancri e", "Cancri55E_texture", 0.3, 1.65, .orange)
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
    
    // MARK: - Update Exoplanets System
    func updateExoplanetsSystem(in content: RealityViewCameraContent, timeline: TimelineViewDefaultContext) {
        let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
        
        guard let root = content.entities.first(where: { $0.name == "Root" }) else { return }
        
        // Rotation
        let rotations: [(String, Float)] = [
            ("Sun", 0.8), ("Earth", 0.5), ("Proxima b", 0.5),
            ("Kepler-452b", 0.5), ("55 Cancri e", 0.5)
        ]
        
        for (name, speed) in rotations {
            if let entity = root.findEntity(named: name) {
                entity.transform.rotation = simd_quatf(angle: angle * speed, axis: [0, 1, 0])
            }
        }
        
        // Scale & Rotation với drag
        root.scale = SIMD3(repeating: scale * tempScale)
        
        let currentYaw = Float(currentDragOffset.width) * 0.01
        let currentPitch = Float(currentDragOffset.height) * 0.01
        
        let currentYawRotation = simd_quatf(angle: currentYaw, axis: [0, 1, 0])
        let currentPitchRotation = simd_quatf(angle: currentPitch, axis: [1, 0, 0])
        
        root.transform.rotation = currentYawRotation * rotation * currentPitchRotation
    }
}

#Preview {
    Planet3DView()
}
