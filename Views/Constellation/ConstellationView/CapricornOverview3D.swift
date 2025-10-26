//
//  Capricorn3D.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 23/10/25.
//

import SwiftUI
import RealityKit

struct CapricornOverview3D: View {
    @State private var dragRotationY: Float = 0
    @State private var dragRotationX: Float = 0
    @State private var isDragging: Bool = false
    @State private var constellationEntity = Entity()
    var body: some View {
        RealityView { content in
            // ✨ VỊ TRÍ CÁC NGÔI SAO
            let starOffsets: [CGPoint] = [
                CGPoint(x: -0.5, y: 0.0),   // Deneb Algedi (δ Cap)
                CGPoint(x: -0.37, y: -0.02),   // Dabih (β Cap)
                CGPoint(x: -0.25, y: -0.4),    // Nashira (γ Cap)
                CGPoint(x: -0.2, y: -0.04),    // Algedi (α Cap)
                CGPoint(x: -0.05, y: -0.06),   // Alshat (ν Cap)
                CGPoint(x: -0.05, y: -0.55),
                CGPoint(x: 0.1, y: -0.6),
                CGPoint(x: 0.2, y: -0.5),
                CGPoint(x: 0.33, y: -0.2),
                CGPoint(x: 0.4, y: 0.0),
                CGPoint(x: 0.5, y: 0.2)
            ]
            var starMaterial = UnlitMaterial()
            starMaterial.color = .init(tint: .white)
            var glowMaterial = UnlitMaterial()
            glowMaterial.color = .init(tint: UIColor(white: 1.0, alpha: 0.5))
            constellationEntity = Entity()
            // 🌟 TẠO NGÔI SAO + GLOW
            for offset in starOffsets {
                // Ngôi sao chính
                let starMesh = MeshResource.generateSphere(radius: 0.02)
                let starEntity = ModelEntity(mesh: starMesh, materials: [starMaterial])
                starEntity.position = SIMD3(Float(offset.x), Float(offset.y), 0.0)
                constellationEntity.addChild(starEntity)
                // Glow 1
                let glowMesh = MeshResource.generateSphere(radius: 0.025)
                let glowEntity = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
                glowEntity.position = SIMD3(Float(offset.x), Float(offset.y), 0.0)
                constellationEntity.addChild(glowEntity)
                // Glow 2
                var outerGlowMaterial = UnlitMaterial()
                outerGlowMaterial.color = .init(tint: UIColor(white: 1.0, alpha: 0.2))
                let outerGlowMesh = MeshResource.generateSphere(radius: 0.04)
                let outerGlowEntity = ModelEntity(mesh: outerGlowMesh, materials: [outerGlowMaterial])
                outerGlowEntity.position = SIMD3(Float(offset.x), Float(offset.y), 0.0)
                constellationEntity.addChild(outerGlowEntity)
            }
            // 🌌 KẾT NỐI
            let connections: [(Int, Int)] = [
                (0, 1), (0, 2), (1, 3), (3, 4), (2, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10), (4, 9)
            ]
            let lineMaterial = UnlitMaterial(color: .white)
            for (startIndex, endIndex) in connections {
                let start = SIMD3<Float>(Float(starOffsets[startIndex].x), Float(starOffsets[startIndex].y), 0.0)
                let end = SIMD3<Float>(Float(starOffsets[endIndex].x), Float(starOffsets[endIndex].y), 0.0)
                let direction = end - start
                let lineLength = simd_length(direction)
                let midpoint = (start + end) / 2
                let lineMesh = MeshResource.generateCylinder(height: lineLength, radius: 0.005)
                let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
                lineEntity.position = midpoint
                let normalizedDirection = normalize(direction)
                let upVector = SIMD3<Float>(0, 1, 0)
                let rotationAxis = cross(upVector, normalizedDirection)
                let rotationAngle = acos(dot(upVector, normalizedDirection))
                if rotationAngle.isFinite && simd_length(rotationAxis) > 0 {
                    let rotation = simd_quatf(angle: rotationAngle, axis: normalize(rotationAxis))
                    lineEntity.transform.rotation = rotation
                }
                constellationEntity.addChild(lineEntity)
            }
            // 🌠 NGÔI SAO NỀN
            for _ in 0..<35 {
                let randomPosition = SIMD3<Float>(
                    Float.random(in: -1.2...1.2),
                    Float.random(in: -1.2...1.2),
                    Float.random(in: -1.2...1.2)
                )
                let bgStarMesh = MeshResource.generateSphere(radius: 0.008)
                let bgStarEntity = ModelEntity(mesh: bgStarMesh, materials: [starMaterial])
                bgStarEntity.position = randomPosition * 1.8
                constellationEntity.addChild(bgStarEntity)
            }
            constellationEntity.position = [0, 0, 0]
            content.add(constellationEntity)
            // 💡 ÁNH SÁNG
            let pointLight = PointLight()
            pointLight.light.intensity = 2500
            pointLight.position = [1, 1, 1]
            content.add(pointLight)
            let spotLight = SpotLight()
            spotLight.light.intensity = 1800
            spotLight.position = [2, 1.5, 1.5]
            content.add(spotLight)
            let ambientLight = PointLight()
            ambientLight.light.intensity = 600
            ambientLight.position = [0, 0, 0]
            content.add(ambientLight)
        }
        .onAppear {
            Task { @MainActor in
                var angle: Float = 0
                while true {
                    if !isDragging {
                        angle += 0.01
                    }
                    let rotationY = simd_quatf(angle: angle + dragRotationY, axis: [0, 1, 0])
                    let rotationX = simd_quatf(angle: angle + dragRotationX, axis: [1, 0, 0])
                    constellationEntity.transform.rotation = rotationY * rotationX
                    try? await Task.sleep(nanoseconds: 16_666_666)
                }
            }
        }
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
    }
}

struct CapricornInformation3D: View {
    @State private var constellationEntity = Entity()
    var body: some View {
        RealityView { content in
            // ✨ VỊ TRÍ SAO THỰC TẾ CAPRICORN
            let starOffsets: [CGPoint] = [
                CGPoint(x: -0.5, y: 0.0),   // Deneb Algedi (δ Cap)
                CGPoint(x: -0.37, y: -0.02),   // Dabih (β Cap)
                CGPoint(x: -0.25, y: -0.4),    // Nashira (γ Cap)
                CGPoint(x: -0.2, y: -0.04),    // Algedi (α Cap)
                CGPoint(x: -0.05, y: -0.06),   // Alshat (ν Cap)
                CGPoint(x: -0.05, y: -0.55),
                CGPoint(x: 0.1, y: -0.6),
                CGPoint(x: 0.2, y: -0.5),
                CGPoint(x: 0.33, y: -0.2),
                CGPoint(x: 0.4, y: 0.0),
                CGPoint(x: 0.5, y: 0.2)
            ]
            var starMaterial = UnlitMaterial()
            starMaterial.color = .init(tint: .white)
            var glowMaterial = UnlitMaterial()
            glowMaterial.color = .init(tint: UIColor(white: 1.0, alpha: 0.4))
            constellationEntity = Entity()
            // 🌟 TẠO NGÔI SAO + GLOW
            for offset in starOffsets {
                let position = SIMD3<Float>(Float(offset.x), Float(offset.y), 0.0)
                // Ngôi sao chính
                let starMesh = MeshResource.generateSphere(radius: 0.015)
                let starEntity = ModelEntity(mesh: starMesh, materials: [starMaterial])
                starEntity.position = position
                constellationEntity.addChild(starEntity)
                // Glow effect
                let glowMesh = MeshResource.generateSphere(radius: 0.02)
                let glowEntity = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
                glowEntity.position = position
                constellationEntity.addChild(glowEntity)
                // Outer glow
                var outerGlowMaterial = UnlitMaterial()
                outerGlowMaterial.color = .init(tint: UIColor(white: 1.0, alpha: 0.15))
                let outerGlowMesh = MeshResource.generateSphere(radius: 0.03)
                let outerGlowEntity = ModelEntity(mesh: outerGlowMesh, materials: [outerGlowMaterial])
                outerGlowEntity.position = position
                constellationEntity.addChild(outerGlowEntity)
            }
            // 🌌 KẾT NỐI
            let connections: [(Int, Int)] = [
                (0, 1), (0, 2), (1, 3), (3, 4), (2, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10), (4, 9)
            ]
            let lineMaterial = UnlitMaterial(color: .white)
            for (startIndex, endIndex) in connections {
                let start = SIMD3<Float>(Float(starOffsets[startIndex].x), Float(starOffsets[startIndex].y), 0.0)
                let end = SIMD3<Float>(Float(starOffsets[endIndex].x), Float(starOffsets[endIndex].y), 0.0)
                let direction = end - start
                let length = simd_length(direction)
                let midpoint = (start + end) / 2
                let lineMesh = MeshResource.generateCylinder(height: length, radius: 0.003)
                let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
                lineEntity.position = midpoint
                let normalizedDirection = normalize(direction)
                let upVector = SIMD3<Float>(0, 1, 0)
                let rotationAxis = cross(upVector, normalizedDirection)
                let rotationAngle = acos(dot(upVector, normalizedDirection))
                if rotationAngle.isFinite && simd_length(rotationAxis) > 0 {
                    let rotation = simd_quatf(angle: rotationAngle, axis: normalize(rotationAxis))
                    lineEntity.transform.rotation = rotation
                }
                constellationEntity.addChild(lineEntity)
            }
            // 🌠 NGÔI SAO NỀN MỜ
            for _ in 0..<15 {
                let randomPosition = SIMD3<Float>(
                    Float.random(in: -0.8...0.8),
                    Float.random(in: -0.8...0.8),
                    Float.random(in: -0.8...0.8)
                )
                let bgStarMesh = MeshResource.generateSphere(radius: 0.006)
                let bgStarEntity = ModelEntity(mesh: bgStarMesh, materials: [starMaterial])
                bgStarEntity.position = randomPosition * 1.5
                constellationEntity.addChild(bgStarEntity)
            }
            constellationEntity.position = [0, 0, 0]
            content.add(constellationEntity)
            // 💡 ÁNH SÁNG MỀM
            let ambientLight = PointLight()
            ambientLight.light.intensity = 800
            ambientLight.light.color = .white
            ambientLight.position = [0, 0, 0]
            content.add(ambientLight)
        }
        .onAppear {
            Task { @MainActor in
                var angle: Float = 0
                while true {
                    angle += 0.008
                    let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                    constellationEntity.transform.rotation = rotation
                    try? await Task.sleep(nanoseconds: 33_333_333)
                }
            }
        }
    }
}

#Preview {
    CapricornOverview3D()
}
