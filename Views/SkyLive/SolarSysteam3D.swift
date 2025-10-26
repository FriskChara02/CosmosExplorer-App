//
//  SolarSysteam3D.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 25/10/25.
//

import SwiftUI
import RealityKit
import simd

struct Sun3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let sunMesh = MeshResource.generateSphere(radius: 1.0)
                var sunMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Sun_Texture")
                    sunMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Sun_Texture") {
                        sunMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    sunMaterial.baseColor = .init(tint: .yellow)
                }
                sunMaterial.emissiveIntensity = 1.0
                sunMaterial.roughness = 1.0
                sunMaterial.metallic = 0.0
                
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
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let sunEntity = content.entities.first(where: { $0.name == "Sun" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    sunEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Mercury3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let mercuryMesh = MeshResource.generateSphere(radius: 0.4)
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
                mercuryMaterial.emissiveIntensity = 1.0
                mercuryMaterial.roughness = 0.9
                mercuryMaterial.metallic = 0.1
                
                let mercuryEntity = ModelEntity(mesh: mercuryMesh, materials: [mercuryMaterial])
                mercuryEntity.name = "Mercury"
                mercuryEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(mercuryEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let mercuryEntity = content.entities.first(where: { $0.name == "Mercury" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    mercuryEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Venus3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let venusMesh = MeshResource.generateSphere(radius: 1.0)
                var venusMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Venus_Texture")
                    venusMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Venus_Texture") {
                        venusMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    venusMaterial.baseColor = .init(tint: .orange)
                }
                venusMaterial.emissiveIntensity = 1.0
                venusMaterial.roughness = 1.0
                venusMaterial.metallic = 0.0
                
                let venusEntity = ModelEntity(mesh: venusMesh, materials: [venusMaterial])
                venusEntity.name = "Venus"
                venusEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(venusEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let venusEntity = content.entities.first(where: { $0.name == "Venus" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    venusEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Earth3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let earthMesh = MeshResource.generateSphere(radius: 1.0)
                var earthMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Earth_Texture")
                    earthMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Earth_Texture") {
                        earthMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    earthMaterial.baseColor = .init(tint: .blue)
                }
                earthMaterial.emissiveIntensity = 1.0
                earthMaterial.roughness = 0.8
                earthMaterial.metallic = 0.2
                
                let earthEntity = ModelEntity(mesh: earthMesh, materials: [earthMaterial])
                earthEntity.name = "Earth"
                earthEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(earthEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let earthEntity = content.entities.first(where: { $0.name == "Earth" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    earthEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Moon3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let moonMesh = MeshResource.generateSphere(radius: 0.8)
                var moonMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Moon_Texture")
                    moonMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Moon_Texture") {
                        moonMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    moonMaterial.baseColor = .init(tint: .gray)
                }
                moonMaterial.emissiveIntensity = 1.0
                moonMaterial.roughness = 0.8
                moonMaterial.metallic = 0.2
                
                let moonEntity = ModelEntity(mesh: moonMesh, materials: [moonMaterial])
                moonEntity.name = "Moon"
                moonEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 200
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(moonEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let moonEntity = content.entities.first(where: { $0.name == "Moon" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    moonEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Mars3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let marsMesh = MeshResource.generateSphere(radius: 1.0)
                var marsMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Mars_Texture")
                    marsMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Mars_Texture") {
                        marsMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    marsMaterial.baseColor = .init(tint: .red)
                }
                marsMaterial.emissiveIntensity = 1.0
                marsMaterial.roughness = 1.0
                marsMaterial.metallic = 0.0
                
                let marsEntity = ModelEntity(mesh: marsMesh, materials: [marsMaterial])
                marsEntity.name = "Mars"
                marsEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(marsEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let marsEntity = content.entities.first(where: { $0.name == "Mars" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    marsEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Jupiter3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let jupiterMesh = MeshResource.generateSphere(radius: 1.0)
                var jupiterMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Jupiter_Texture")
                    jupiterMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Jupiter_Texture") {
                        jupiterMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    jupiterMaterial.baseColor = .init(tint: .brown)
                }
                jupiterMaterial.emissiveIntensity = 1.0
                jupiterMaterial.roughness = 1.0
                jupiterMaterial.metallic = 0.0
                
                let jupiterEntity = ModelEntity(mesh: jupiterMesh, materials: [jupiterMaterial])
                jupiterEntity.name = "Jupiter"
                jupiterEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(jupiterEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let jupiterEntity = content.entities.first(where: { $0.name == "Jupiter" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    jupiterEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Saturn3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
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
                saturnMaterial.emissiveIntensity = 1.0
                saturnMaterial.roughness = 1.0
                saturnMaterial.metallic = 0.0
                
                let saturnEntity = ModelEntity(mesh: saturnMesh, materials: [saturnMaterial])
                saturnEntity.name = "Saturn"
                saturnEntity.position = [0, 0, 0]
                
                let ringEntity = await Saturn3DView.makeRing(outerRadius: 1.08, innerRadius: 0.8, thickness: 0.01)
                ringEntity.name = "SaturnRings"
                ringEntity.position = [0, 0, 0]
                ringEntity.transform.rotation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(saturnEntity)
                content.add(ringEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let saturnEntity = content.entities.first(where: { $0.name == "Saturn" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    saturnEntity.transform.rotation = rotationY
                }
                if let ringEntity = content.entities.first(where: { $0.name == "SaturnRings" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    ringEntity.transform.rotation = rotationY * simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
    
    static func makeRing(outerRadius: Float, innerRadius: Float, thickness: Float) async -> ModelEntity {
        let ringMesh = MeshResource.generateCylinder(height: thickness, radius: outerRadius)
        var ringMaterial = PhysicallyBasedMaterial()
        do {
            let textureResource = try await TextureResource(named: "SaturnRing_Texture")
            ringMaterial.baseColor = .init(texture: .init(textureResource))
            if let normalResource = try? await TextureResource(named: "SaturnRing_Texture") {
                ringMaterial.normal = .init(texture: .init(normalResource))
            }
        } catch {
            print("Error loading texture: \(error)")
            ringMaterial.baseColor.tint = .gray
        }
        ringMaterial.roughness = 0.5
        ringMaterial.metallic = 0.8
        
        let ringEntity = ModelEntity(mesh: ringMesh, materials: [ringMaterial])
        return ringEntity
    }
}

struct Uranus3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let uranusMesh = MeshResource.generateSphere(radius: 0.8)
                var uranusMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Uranus_Texture")
                    uranusMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Uranus_Texture") {
                        uranusMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    uranusMaterial.baseColor = .init(tint: .cyan)
                }
                uranusMaterial.emissiveIntensity = 1.0
                uranusMaterial.roughness = 1.0
                uranusMaterial.metallic = 0.0
                
                let uranusEntity = ModelEntity(mesh: uranusMesh, materials: [uranusMaterial])
                uranusEntity.name = "Uranus"
                uranusEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(uranusEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let uranusEntity = content.entities.first(where: { $0.name == "Uranus" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    uranusEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct Neptune3DView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let neptuneMesh = MeshResource.generateSphere(radius: 0.8)
                var neptuneMaterial = PhysicallyBasedMaterial()
                do {
                    let textureResource = try await TextureResource(named: "Neptune_Texture")
                    neptuneMaterial.baseColor = .init(texture: .init(textureResource))
                    if let normalResource = try? await TextureResource(named: "Neptune_Texture") {
                        neptuneMaterial.normal = .init(texture: .init(normalResource))
                    }
                } catch {
                    print("Error loading texture: \(error)")
                    neptuneMaterial.baseColor = .init(tint: .blue)
                }
                neptuneMaterial.emissiveIntensity = 1.0
                neptuneMaterial.roughness = 1.0
                neptuneMaterial.metallic = 0.0
                
                let neptuneEntity = ModelEntity(mesh: neptuneMesh, materials: [neptuneMaterial])
                neptuneEntity.name = "Neptune"
                neptuneEntity.position = [0, 0, 0]
                
                let ambientLight = PointLight()
                ambientLight.light.intensity = 250
                ambientLight.light.color = .white
                ambientLight.position = [0, 0, 0]
                
                content.add(neptuneEntity)
                content.add(ambientLight)
            } update: { content in
                let angle = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 360))
                if let neptuneEntity = content.entities.first(where: { $0.name == "Neptune" }) {
                    let rotationY = simd_quatf(angle: angle * 0.5, axis: [0, 1, 0])
                    neptuneEntity.transform.rotation = rotationY
                }
            }
        }
        .frame(height: 300)
        .padding()
    }
}

#Preview {
    Saturn3DView()
}
