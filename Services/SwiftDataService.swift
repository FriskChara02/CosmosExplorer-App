//
//  SwiftDataService.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData
import PostgresClientKit

@MainActor
class SwiftDataService {
    let container: ModelContainer
    
    init() {
        let schema = Schema([PlanetModel.self, UserModel.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            print("Failed to create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func savePlanet(_ planet: PlanetModel) {
        let context = container.mainContext
        context.insert(planet)
        do {
            try context.save()
            print("Planet saved to SwiftData")
        } catch {
            print("Error saving planet to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO planets (id, name, description, view_count, is_favorite, planet_order)
                VALUES ($1, $2, $3, $4, $5, $6)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, description = $3, view_count = $4, is_favorite = $5, planet_order = $6
            """)
            try statement.execute(parameterValues: [
                planet.id.uuidString,
                planet.name,
                planet.planetDescription,
                planet.viewCount,
                planet.isFavorite,
                planet.planet_order
            ])
            print("Planet synced to PostgreSQL")
        } catch {
            print("Lỗi khi lưu planet vào PostgreSQL: \(error)")
        }
    }
    
    func fetchPlanets() -> [PlanetModel] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<PlanetModel>()
        do {
            let planets = try context.fetch(descriptor)
            print("Fetched \(planets.count) planets from SwiftData")
            return planets
        } catch {
            print("Error fetching planets: \(error)")
            return []
        }
    }
    
    func saveUser(_ user: UserModel) {
        let context = container.mainContext
        context.insert(user)
        do {
            try context.save()
            print("User saved to SwiftData")
        } catch {
            print("Error saving user to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO users (id, email, username, created_at)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (id) DO UPDATE
                SET email = $2, username = $3, created_at = $4
            """)
            try statement.execute(parameterValues: [
                user.id.uuidString,
                user.email,
                user.username,
                ISO8601DateFormatter().string(from: user.createdAt)
            ])
            print("User synced to PostgreSQL")
        } catch {
            print("Lỗi khi lưu user vào PostgreSQL: \(error)")
        }
    }
    
    func fetchUsers() -> [UserModel] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<UserModel>()
        do {
            let users = try context.fetch(descriptor)
            print("Fetched \(users.count) users from SwiftData")
            return users
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
}
