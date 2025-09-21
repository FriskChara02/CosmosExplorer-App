//
//  SwiftDataService.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import Foundation
import SwiftData
import PostgresClientKit
import UIKit

@MainActor
class SwiftDataService {
    public let container: ModelContainer
    
    init() {
        let schema = Schema([PlanetModel.self, UserModel.self])
        let containerURL = URL.applicationSupportDirectory.appendingPathComponent("CosmosDB.sqlite")
        
        let configuration = ModelConfiguration(
            schema: schema,
            url: containerURL,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
            print("✅ ModelContainer created successfully with entities: \(schema.entities.map { $0.name })")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Save Planet
    func savePlanet(_ planet: PlanetModel) {
        let context = container.mainContext
        context.insert(planet)
        do {
            try context.save()
            print("✅ Planet saved to SwiftData: \(planet.name)")
        } catch {
            print("❌ Error saving planet to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO planets (
                    id, name, planet_description, view_count, is_favorite, planet_order,
                    image_data, random_infos, about_description, video_urls, planet_type,
                    radius, distance_from_sun, moons, gravity, tilt_of_axis,
                    length_of_year, length_of_day, temperature, age, gallery_image_data,
                    myth_title, myth_description, internal_title, internal_image,
                    in_depth_title, header_image_in_depth_data, exploration_title,
                    header_image_exploration_data, highlight_quote, showcase_image_data,
                    wiki_link
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, planet_description = $3, view_count = $4, is_favorite = $5, planet_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    planet_type = $11, radius = $12, distance_from_sun = $13, moons = $14,
                    gravity = $15, tilt_of_axis = $16, length_of_year = $17, length_of_day = $18,
                    temperature = $19, age = $20, gallery_image_data = $21, myth_title = $22,
                    myth_description = $23, internal_title = $24, internal_image = $25,
                    in_depth_title = $26, header_image_in_depth_data = $27, exploration_title = $28,
                    header_image_exploration_data = $29, highlight_quote = $30, showcase_image_data = $31,
                    wiki_link = $32
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(planet.id),
                pg(planet.name),
                pg(planet.planetDescription),
                pg(planet.viewCount),
                pg(planet.isFavorite),
                pg(planet.planet_order),
                pg(planet.imageData),
                pg(planet.randomInfos),
                pg(planet.aboutDescription),
                pg(planet.videoURLs),
                pg(planet.planetType),
                pg(planet.radius),
                pg(planet.distanceFromSun),
                pg(planet.moons),
                pg(planet.gravity),
                pg(planet.tiltOfAxis),
                pg(planet.lengthOfYear),
                pg(planet.lengthOfDay),
                pg(planet.temperature),
                pg(planet.age),
                pg(planet.galleryImageData),
                pg(planet.mythTitle),
                pg(planet.mythDescription),
                pg(planet.internalTitle),
                pg(planet.internalImage),
                pg(planet.inDepthTitle),
                pg(planet.headerImageInDepthData),
                pg(planet.explorationTitle),
                pg(planet.headerImageExplorationData),
                pg(planet.highlightQuote),
                pg(planet.showcaseImageData),
                pg(planet.wikiLink)
            ])
            
            // Delete related data
            for table in ["PlanetMyths", "PlanetLayers", "PlanetInfoCards", "PlanetMissions"] {
                let deleteStatement = try connection.prepareStatement(text: "DELETE FROM \(table) WHERE planet_id = $1")
                defer { deleteStatement.close() }
                try deleteStatement.execute(parameterValues: [pg(planet.id)])
            }
            
            // Save PlanetMyths
            for myth in planet.myths {
                let mythStatement = try connection.prepareStatement(text: """
                    INSERT INTO PlanetMyths (id, planet_id, culture, god_name, myth_description, image_data)
                    VALUES ($1, $2, $3, $4, $5, $6)
                """)
                defer { mythStatement.close() }
                try mythStatement.execute(parameterValues: [
                    pg(myth.id),
                    pg(planet.id),
                    pg(myth.culture),
                    pg(myth.godName),
                    pg(myth.mythDescription),
                    pg(myth.imageData)
                ])
            }
            
            // Save PlanetLayers
            for layer in planet.layers {
                let layerStatement = try connection.prepareStatement(text: """
                    INSERT INTO PlanetLayers (id, planet_id, name, layer_description, color_start, color_end, icon)
                    VALUES ($1, $2, $3, $4, $5, $6, $7)
                """)
                defer { layerStatement.close() }
                try layerStatement.execute(parameterValues: [
                    pg(layer.id),
                    pg(planet.id),
                    pg(layer.name),
                    pg(layer.layerDescription),
                    pg(layer.colorStart),
                    pg(layer.colorEnd),
                    pg(layer.icon)
                ])
            }
            
            // Save PlanetInfoCards
            for card in planet.infoCards {
                let cardStatement = try connection.prepareStatement(text: """
                    INSERT INTO PlanetInfoCards (id, planet_id, icon, title, info_card_description, icon_color)
                    VALUES ($1, $2, $3, $4, $5, $6)
                """)
                defer { cardStatement.close() }
                try cardStatement.execute(parameterValues: [
                    pg(card.id),
                    pg(planet.id),
                    pg(card.icon),
                    pg(card.title),
                    pg(card.infoCardDescription),
                    pg(card.iconColor)
                ])
            }
            
            // Save PlanetMissions
            for mission in planet.missions {
                let missionStatement = try connection.prepareStatement(text: """
                    INSERT INTO PlanetMissions (id, planet_id, title, mission_description, icon, mission_id)
                    VALUES ($1, $2, $3, $4, $5, $6)
                """)
                defer { missionStatement.close() }
                try missionStatement.execute(parameterValues: [
                    pg(mission.id),
                    pg(planet.id),
                    pg(mission.title),
                    pg(mission.missionDescription),
                    pg(mission.icon),
                    pg(mission.missionId)
                ])
            }
            
            print("✅ Planet synced to PostgreSQL: \(planet.name)")
        } catch {
            print("❌ Error syncing planet to PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Fetch Planets
    func fetchPlanets() -> [PlanetModel] {
        let context = container.mainContext
        var planets: [PlanetModel] = []
        
        // Fetch from SwiftData
        do {
            let descriptor = FetchDescriptor<PlanetModel>()
            planets = try context.fetch(descriptor)
            print("📱 Fetched \(planets.count) planets from SwiftData: \(planets.map { $0.name })")
            if !planets.isEmpty {
                return planets
            }
        } catch {
            print("❌ Error fetching planets from SwiftData: \(error)")
        }
        
        // Fetch from PostgreSQL if SwiftData is empty
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return planets
        }
        defer { connection.close() }
        
        do {
            let planetStatement = try connection.prepareStatement(text: """
                SELECT id, name, planet_description, view_count, is_favorite, planet_order,
                       image_data, random_infos, about_description, video_urls, planet_type,
                       radius, distance_from_sun, moons, gravity, tilt_of_axis,
                       length_of_year, length_of_day, temperature, age, gallery_image_data,
                       myth_title, myth_description, internal_title, internal_image,
                       in_depth_title, header_image_in_depth_data, exploration_title,
                       header_image_exploration_data, highlight_quote, showcase_image_data,
                       wiki_link
                FROM planets
                ORDER BY planet_order ASC
            """)
            defer { planetStatement.close() }
            
            let planetCursor = try planetStatement.execute()
            for row in planetCursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                
                let planet = PlanetModel(
                    id: id,
                    name: try columns[1].optionalString() ?? "",
                    planetDescription: try columns[2].optionalString() ?? "",
                    viewCount: try columns[3].optionalInt() ?? 0,
                    isFavorite: try columns[4].optionalBool() ?? false,
                    planet_order: try columns[5].optionalInt() ?? 0,
                    imageData: try columns[6].dataFromBytea() ?? Data(),
                    randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                    aboutDescription: try columns[8].optionalString() ?? "",
                    videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                    planetType: try columns[10].optionalString() ?? "",
                    radius: try columns[11].optionalString() ?? "",
                    distanceFromSun: try columns[12].optionalString() ?? "",
                    moons: try columns[13].optionalString() ?? "",
                    gravity: try columns[14].optionalString() ?? "",
                    tiltOfAxis: try columns[15].optionalString() ?? "",
                    lengthOfYear: try columns[16].optionalString() ?? "",
                    lengthOfDay: try columns[17].optionalString() ?? "",
                    temperature: try columns[18].optionalString() ?? "",
                    age: try columns[19].optionalString() ?? "",
                    galleryImageData: parseByteaArray(try columns[20].optionalString() ?? "{}"),
                    mythTitle: try columns[21].optionalString() ?? "",
                    mythDescription: try columns[22].optionalString() ?? "",
                    internalTitle: try columns[23].optionalString() ?? "",
                    internalImage: try columns[24].dataFromBytea(),
                    inDepthTitle: try columns[25].optionalString() ?? "",
                    headerImageInDepthData: try columns[26].dataFromBytea() ?? Data(),
                    explorationTitle: try columns[27].optionalString() ?? "",
                    headerImageExplorationData: try columns[28].dataFromBytea() ?? Data(),
                    highlightQuote: try columns[29].optionalString() ?? "",
                    showcaseImageData: try columns[30].dataFromBytea() ?? Data(),
                    wikiLink: try columns[31].optionalString() ?? ""
                )
                
                // Fetch related data
                planet.myths = try fetchRelatedData(connection, table: "PlanetMyths", planetId: id) { cols in
                    PlanetMyth(
                        id: UUID(uuidString: try cols[0].optionalString() ?? "") ?? UUID(),
                        culture: try cols[2].optionalString() ?? "",
                        godName: try cols[3].optionalString() ?? "",
                        mythDescription: try cols[4].optionalString() ?? "",
                        imageData: try cols[5].dataFromBytea() ?? Data()
                    )
                }
                
                planet.layers = try fetchRelatedData(connection, table: "PlanetLayers", planetId: id) { cols in
                    PlanetLayer(
                        id: UUID(uuidString: try cols[0].optionalString() ?? "") ?? UUID(),
                        name: try cols[2].optionalString() ?? "",
                        layerDescription: try cols[3].optionalString() ?? "",
                        colorStart: try cols[4].optionalString() ?? "",
                        colorEnd: try cols[5].optionalString() ?? "",
                        icon: try cols[6].optionalString() ?? ""
                    )
                }
                
                planet.infoCards = try fetchRelatedData(connection, table: "PlanetInfoCards", planetId: id) { cols in
                    PlanetInfoCard(
                        id: UUID(uuidString: try cols[0].optionalString() ?? "") ?? UUID(),
                        icon: try cols[2].optionalString() ?? "",
                        title: try cols[3].optionalString() ?? "",
                        infoCardDescription: try cols[4].optionalString() ?? "",
                        iconColor: try cols[5].optionalString() ?? ""
                    )
                }
                
                planet.missions = try fetchRelatedData(connection, table: "PlanetMissions", planetId: id) { cols in
                    PlanetMission(
                        id: UUID(uuidString: try cols[0].optionalString() ?? "") ?? UUID(),
                        title: try cols[2].optionalString() ?? "",
                        missionDescription: try cols[3].optionalString() ?? "",
                        icon: try cols[4].optionalString() ?? "",
                        missionId: try cols[5].optionalString() ?? ""
                    )
                }
                
                // Insert - update in SwiftData
                if planets.contains(where: { $0.id == planet.id }) {
                    planets.first(where: { $0.id == planet.id })?.update(from: planet)
                } else {
                    context.insert(planet)
                    planets.append(planet)
                }
            }
            
            try context.save()
            print("✅ Synced \(planets.count) planets from PostgreSQL to SwiftData")
        } catch {
            print("❌ Error fetching planets from PostgreSQL: \(error)")
        }
        
        return planets
    }
    
    // MARK: - Update Planet
    func updatePlanet(_ planet: PlanetModel) {
        let context = container.mainContext
        do {
            try context.save()
            print("✅ Planet updated in SwiftData: \(planet.name)")
        } catch {
            print("❌ Error updating planet in SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE planets
                SET name = $2, planet_description = $3, view_count = $4, is_favorite = $5, planet_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    planet_type = $11, radius = $12, distance_from_sun = $13, moons = $14,
                    gravity = $15, tilt_of_axis = $16, length_of_year = $17, length_of_day = $18,
                    temperature = $19, age = $20, gallery_image_data = $21, myth_title = $22,
                    myth_description = $23, internal_title = $24, internal_image = $25,
                    in_depth_title = $26, header_image_in_depth_data = $27, exploration_title = $28,
                    header_image_exploration_data = $29, highlight_quote = $30, showcase_image_data = $31,
                    wiki_link = $32
                WHERE id = $1
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(planet.id),
                pg(planet.name),
                pg(planet.planetDescription),
                pg(planet.viewCount),
                pg(planet.isFavorite),
                pg(planet.planet_order),
                pg(planet.imageData),
                pg(planet.randomInfos),
                pg(planet.aboutDescription),
                pg(planet.videoURLs),
                pg(planet.planetType),
                pg(planet.radius),
                pg(planet.distanceFromSun),
                pg(planet.moons),
                pg(planet.gravity),
                pg(planet.tiltOfAxis),
                pg(planet.lengthOfYear),
                pg(planet.lengthOfDay),
                pg(planet.temperature),
                pg(planet.age),
                pg(planet.galleryImageData),
                pg(planet.mythTitle),
                pg(planet.mythDescription),
                pg(planet.internalTitle),
                pg(planet.internalImage),
                pg(planet.inDepthTitle),
                pg(planet.headerImageInDepthData),
                pg(planet.explorationTitle),
                pg(planet.headerImageExplorationData),
                pg(planet.highlightQuote),
                pg(planet.showcaseImageData),
                pg(planet.wikiLink)
            ])
            
            print("✅ Planet updated in PostgreSQL: \(planet.name)")
        } catch {
            print("❌ Error updating planet in PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Save User
    func saveUser(_ user: UserModel) {
        let context = container.mainContext
        context.insert(user)
        do {
            try context.save()
            print("✅ User saved to SwiftData")
        } catch {
            print("❌ Error saving user to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
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
            defer { statement.close() }
            try statement.execute(parameterValues: [
                pg(user.id),
                pg(user.email),
                pg(user.username),
                pg(ISO8601DateFormatter().string(from: user.createdAt))
            ])
            print("✅ User synced to PostgreSQL")
        } catch {
            print("❌ Error syncing user to PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Fetch Users
    func fetchUsers() -> [UserModel] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<UserModel>()
        do {
            let users = try context.fetch(descriptor)
            print("✅ Fetched \(users.count) users from SwiftData")
            return users
        } catch {
            print("❌ Error fetching users: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    private func pg(_ value: Any?) -> PostgresValue {
        switch value {
        case let v as String: return PostgresValue(v)
        case let v as Int: return PostgresValue(String(v))
        case let v as Bool: return PostgresValue(String(v))
        case let v as UUID: return PostgresValue(v.uuidString)
        case let v as Data: return PostgresValue(v.base64EncodedString())
        case let v as [String]:
            let escapedStrings = v.map { "\"\(String($0).replacingOccurrences(of: "\"", with: "\\\""))\"" }
            let arrayString = "{" + escapedStrings.joined(separator: ",") + "}"
            return PostgresValue(arrayString)
        case let v as [Data]:
            let encoded = v.map { "\"" + $0.base64EncodedString() + "\"" }
            return PostgresValue(encoded.isEmpty ? "{}" : "{\(encoded.joined(separator: ","))}")
        default: return PostgresValue(nil)
        }
    }
    
    private func parseTextArray(_ rawString: String) -> [String] {
        let cleanString = rawString
            .trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
            .replacingOccurrences(of: "\\\"", with: "\"")
        
        if cleanString.isEmpty {
            return []
        }
        
        let components = cleanString.components(separatedBy: ",")
        return components.compactMap { component in
            let trimmed = component.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            return trimmed.isEmpty ? nil : trimmed
        }
    }
    
    private func parseByteaArray(_ rawString: String) -> [Data] {
        let base64Strings = rawString
            .trimmingCharacters(in: ["{", "}"])
            .split(separator: ",")
            .map { String($0.trimmingCharacters(in: ["\""])) }
            .filter { !$0.isEmpty }
        return base64Strings.compactMap { Data(base64Encoded: $0) }
    }
    
    private func fetchRelatedData<T>(_ connection: Connection, table: String, planetId: UUID, transform: @escaping ([PostgresValue]) throws -> T) throws -> [T]{
    let statement = try connection.prepareStatement(text: "SELECT * FROM \(table) WHERE planet_id = $1")
        defer { statement.close() }
        let cursor = try statement.execute(parameterValues: [pg(planetId)])
        return try cursor.map { row in
            try transform(try row.get().columns)
        }
    }
}

extension PostgresValue {
    func dataFromBytea() throws -> Data? {
        guard let raw = try? string(), raw.hasPrefix("\\x") else { return nil }
        let hexString = String(raw.dropFirst(2))
        var data = Data()
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
            let byteString = hexString[index..<nextIndex]
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
            index = nextIndex
        }
        return data
    }
    
    func optionalString() throws -> String? {
        isNull ? nil : try string()
    }
    
    func optionalInt() throws -> Int? {
        isNull ? nil : try int()
    }
    
    func optionalBool() throws -> Bool? {
        isNull ? nil : try bool()
    }
}

extension PlanetModel {
    func update(from other: PlanetModel) {
        name = other.name
        planetDescription = other.planetDescription
        viewCount = other.viewCount
        isFavorite = other.isFavorite
        planet_order = other.planet_order
        imageData = other.imageData
        randomInfos = other.randomInfos
        aboutDescription = other.aboutDescription
        videoURLs = other.videoURLs
        planetType = other.planetType
        radius = other.radius
        distanceFromSun = other.distanceFromSun
        moons = other.moons
        gravity = other.gravity
        tiltOfAxis = other.tiltOfAxis
        lengthOfYear = other.lengthOfYear
        lengthOfDay = other.lengthOfDay
        temperature = other.temperature
        age = other.age
        galleryImageData = other.galleryImageData
        mythTitle = other.mythTitle
        mythDescription = other.mythDescription
        internalTitle = other.internalTitle
        internalImage = other.internalImage
        inDepthTitle = other.inDepthTitle
        headerImageInDepthData = other.headerImageInDepthData
        explorationTitle = other.explorationTitle
        headerImageExplorationData = other.headerImageExplorationData
        highlightQuote = other.highlightQuote
        showcaseImageData = other.showcaseImageData
        wikiLink = other.wikiLink
        myths = other.myths
        layers = other.layers
        infoCards = other.infoCards
        missions = other.missions
    }
}
