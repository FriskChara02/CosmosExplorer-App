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
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    init() {
        let schema = Schema([PlanetModel.self, UserModel.self, GalaxyModel.self, NebulaModel.self, StarModel.self, BlackholeModel.self, ConstellationModel.self, PlanetsModel.self])
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
    
    // MARK: - Delete Planet
    func deletePlanet(_ planet: PlanetModel) {
        let context = container.mainContext
        
        context.delete(planet)
        do {
            try context.save()
            print("✅ Planet deleted from SwiftData: \(planet.name)")
        } catch {
            print("❌ Error deleting planet from SwiftData: \(error)")
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL for delete")
            return
        }
        defer { connection.close() }
        
        do {
            for table in ["PlanetMyths", "PlanetLayers", "PlanetInfoCards", "PlanetMissions"] {
                let deleteRelatedStatement = try connection.prepareStatement(text: "DELETE FROM \(table) WHERE planet_id = $1")
                defer { deleteRelatedStatement.close() }
                try deleteRelatedStatement.execute(parameterValues: [pg(planet.id)])
                print("🗑️ Deleted related data from \(table) for planet \(planet.name)")
            }
            
            let deleteStatement = try connection.prepareStatement(text: "DELETE FROM planets WHERE id = $1")
            defer { deleteStatement.close() }
            try deleteStatement.execute(parameterValues: [pg(planet.id)])
            
            print("✅ Planet deleted from PostgreSQL: \(planet.name)")
        } catch {
            print("❌ Error deleting planet from PostgreSQL: \(error)")
        }
    }
        
        // MARK: - Save Galaxy
        func saveGalaxy(_ galaxy: GalaxyModel) {
            let context = container.mainContext
            context.insert(galaxy)
            do {
                try context.save()
                print("✅ Galaxy saved to SwiftData: \(galaxy.name)")
            } catch {
                print("❌ Error saving galaxy to SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    INSERT INTO galaxies (
                        id, name, galaxy_description, view_count, is_favorite, galaxy_order,
                        image_data, random_infos, about_description, video_urls,
                        radius, distance_from_sun, age, gallery_image_data, wiki_link
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
                    ON CONFLICT (id) DO UPDATE
                    SET name = $2, galaxy_description = $3, view_count = $4, is_favorite = $5, galaxy_order = $6,
                        image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                        radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                """)
                defer { statement.close() }
                
                try statement.execute(parameterValues: [
                    pg(galaxy.id),
                    pg(galaxy.name),
                    pg(galaxy.galaxyDescription),
                    pg(galaxy.viewCount),
                    pg(galaxy.isFavorite),
                    pg(galaxy.galaxy_order),
                    pg(galaxy.imageData),
                    pg(galaxy.randomInfosData),
                    pg(galaxy.aboutDescription),
                    pg(galaxy.videoURLsData),
                    pg(galaxy.radius),
                    pg(galaxy.distanceFromSun),
                    pg(galaxy.age),
                    pg(galaxy.galleryImageData),
                    pg(galaxy.wikiLink)
                ])
                
                print("✅ Galaxy synced to PostgreSQL: \(galaxy.name)")
            } catch {
                print("❌ Error syncing galaxy to PostgreSQL: \(error)")
            }
        }
        
    // MARK: - Fetch Galaxies
    func fetchGalaxies() -> [GalaxyModel] {
        let context = container.mainContext
        var galaxies: [GalaxyModel] = []
        
        // Fetch from SwiftData
        do {
            let descriptor = FetchDescriptor<GalaxyModel>()
            galaxies = try context.fetch(descriptor)
            print("📱 Fetched \(galaxies.count) galaxies from SwiftData: \(galaxies.map { $0.name })")
            if !galaxies.isEmpty {
                return galaxies
            }
        } catch {
            print("❌ Error fetching galaxies from SwiftData: \(error)")
        }
        
        // Fetch from PostgreSQL if SwiftData is empty
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return galaxies
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, name, galaxy_description, view_count, is_favorite, galaxy_order,
                       image_data, random_infos, about_description, video_urls,
                       radius, distance_from_sun, age, gallery_image_data, wiki_link
                FROM galaxies
                ORDER BY galaxy_order ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            for row in cursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                
                let galaxy = GalaxyModel(
                    id: id,
                    name: try columns[1].optionalString() ?? "",
                    galaxyDescription: try columns[2].optionalString() ?? "",
                    viewCount: try columns[3].optionalInt() ?? 0,
                    isFavorite: try columns[4].optionalBool() ?? false,
                    galaxy_order: try columns[5].optionalInt() ?? 0,
                    imageData: try columns[6].dataFromBytea() ?? Data(),
                    randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                    aboutDescription: try columns[8].optionalString() ?? "",
                    videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                    radius: try columns[10].optionalString() ?? "",
                    distanceFromSun: try columns[11].optionalString() ?? "",
                    age: try columns[12].optionalString() ?? "",
                    galleryImageData: parseByteaArray(try columns[13].optionalString() ?? "{}"),
                    wikiLink: try columns[14].optionalString() ?? ""
                )
                
                // Insert or update in SwiftData
                if galaxies.contains(where: { $0.id == galaxy.id }) {
                    galaxies.first(where: { $0.id == galaxy.id })?.update(from: galaxy)
                } else {
                    context.insert(galaxy)
                    galaxies.append(galaxy)
                }
            }
            
            try context.save()
            print("✅ Synced \(galaxies.count) galaxies from PostgreSQL to SwiftData")
        } catch {
            print("❌ Error fetching galaxies from PostgreSQL: \(error)")
        }
        
        return galaxies
    }

    // MARK: - Update Galaxy
    func updateGalaxy(_ galaxy: GalaxyModel) {
        let context = container.mainContext
        do {
            try context.save()
            print("✅ Galaxy updated in SwiftData: \(galaxy.name)")
        } catch {
            print("❌ Error updating galaxy in SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE galaxies
                SET name = $2, galaxy_description = $3, view_count = $4, is_favorite = $5, galaxy_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                WHERE id = $1
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(galaxy.id),
                pg(galaxy.name),
                pg(galaxy.galaxyDescription),
                pg(galaxy.viewCount),
                pg(galaxy.isFavorite),
                pg(galaxy.galaxy_order),
                pg(galaxy.imageData),
                pg(galaxy.randomInfosData),
                pg(galaxy.aboutDescription),
                pg(galaxy.videoURLsData),
                pg(galaxy.radius),
                pg(galaxy.distanceFromSun),
                pg(galaxy.age),
                pg(galaxy.galleryImageData),
                pg(galaxy.wikiLink)
            ])
            
            print("✅ Galaxy updated in PostgreSQL: \(galaxy.name)")
        } catch {
            print("❌ Error updating galaxy in PostgreSQL: \(error)")
        }
    }
        
        // MARK: - Delete Galaxy
        func deleteGalaxy(_ galaxy: GalaxyModel) {
            let context = container.mainContext
            
            context.delete(galaxy)
            do {
                try context.save()
                print("✅ Galaxy deleted from SwiftData: \(galaxy.name)")
            } catch {
                print("❌ Error deleting galaxy from SwiftData: \(error)")
                return
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL for delete")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: "DELETE FROM galaxies WHERE id = $1")
                defer { statement.close() }
                try statement.execute(parameterValues: [pg(galaxy.id)])
                
                print("✅ Galaxy deleted from PostgreSQL: \(galaxy.name)")
            } catch {
                print("❌ Error deleting galaxy from PostgreSQL: \(error)")
            }
        }
    
    func pg(_ value: [String]) -> String {
        do {
            let jsonData = try JSONEncoder().encode(value)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("Error encoding JSON: \(error)")
            return "{}"
        }
    }
    
    // MARK: - Save Nebula
    func saveNebula(_ nebula: NebulaModel) {
        let context = container.mainContext
        context.insert(nebula)
        do {
            try context.save()
            print("✅ Nebula saved to SwiftData: \(nebula.name)")
        } catch {
            print("❌ Error saving nebula to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO nebulas (
                    id, name, nebula_description, view_count, is_favorite, nebula_order,
                    image_data, random_infos, about_description, video_urls,
                    radius, distance_from_sun, age, gallery_image_data, wiki_link
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, nebula_description = $3, view_count = $4, is_favorite = $5, nebula_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(nebula.id),
                pg(nebula.name),
                pg(nebula.nebulaDescription),
                pg(nebula.viewCount),
                pg(nebula.isFavorite),
                pg(nebula.nebula_order),
                pg(nebula.imageData),
                pg(nebula.randomInfosData),
                pg(nebula.aboutDescription),
                pg(nebula.videoURLsData),
                pg(nebula.radius),
                pg(nebula.distanceFromSun),
                pg(nebula.age),
                pg(nebula.galleryImageData),
                pg(nebula.wikiLink)
            ])
            
            print("✅ Nebula synced to PostgreSQL: \(nebula.name)")
        } catch {
            print("❌ Error syncing nebula to PostgreSQL: \(error)")
        }
    }

    // MARK: - Fetch Nebulas
    func fetchNebulas() -> [NebulaModel] {
        let context = container.mainContext
        var nebulas: [NebulaModel] = []
        
        // Fetch from SwiftData
        do {
            let descriptor = FetchDescriptor<NebulaModel>()
            nebulas = try context.fetch(descriptor)
            print("📱 Fetched \(nebulas.count) nebulas from SwiftData: \(nebulas.map { $0.name })")
            if !nebulas.isEmpty {
                return nebulas
            }
        } catch {
            print("❌ Error fetching nebulas from SwiftData: \(error)")
        }
        
        // Fetch from PostgreSQL if SwiftData is empty
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return nebulas
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, name, nebula_description, view_count, is_favorite, nebula_order,
                       image_data, random_infos, about_description, video_urls,
                       radius, distance_from_sun, age, gallery_image_data, wiki_link
                FROM nebulas
                ORDER BY nebula_order ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            for row in cursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                
                let nebula = NebulaModel(
                    id: id,
                    name: try columns[1].optionalString() ?? "",
                    nebulaDescription: try columns[2].optionalString() ?? "",
                    viewCount: try columns[3].optionalInt() ?? 0,
                    isFavorite: try columns[4].optionalBool() ?? false,
                    nebula_order: try columns[5].optionalInt() ?? 0,
                    imageData: try columns[6].dataFromBytea() ?? Data(),
                    randomInfos: try JSONDecoder().decode([String].self, from: try columns[7].dataFromBytea() ?? Data()),
                    aboutDescription: try columns[8].optionalString() ?? "",
                    videoURLs: try JSONDecoder().decode([String].self, from: try columns[9].dataFromBytea() ?? Data()),
                    radius: try columns[10].optionalString() ?? "",
                    distanceFromSun: try columns[11].optionalString() ?? "",
                    age: try columns[12].optionalString() ?? "",
                    galleryImageData: parseByteaArray(try columns[13].optionalString() ?? "{}"),
                    wikiLink: try columns[14].optionalString() ?? ""
                )
                
                // Insert or update in SwiftData
                if nebulas.contains(where: { $0.id == nebula.id }) {
                    nebulas.first(where: { $0.id == nebula.id })?.update(from: nebula)
                } else {
                    context.insert(nebula)
                    nebulas.append(nebula)
                }
            }
            
            try context.save()
            print("✅ Synced \(nebulas.count) nebulas from PostgreSQL to SwiftData")
        } catch {
            print("❌ Error fetching nebulas from PostgreSQL: \(error)")
        }
        
        return nebulas
    }

    // MARK: - Update Nebula
    func updateNebula(_ nebula: NebulaModel) {
        let context = container.mainContext
        do {
            try context.save()
            print("✅ Nebula updated in SwiftData: \(nebula.name)")
        } catch {
            print("❌ Error updating nebula in SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE nebulas
                SET name = $2, nebula_description = $3, view_count = $4, is_favorite = $5, nebula_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                WHERE id = $1
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(nebula.id),
                pg(nebula.name),
                pg(nebula.nebulaDescription),
                pg(nebula.viewCount),
                pg(nebula.isFavorite),
                pg(nebula.nebula_order),
                pg(nebula.imageData),
                pg(nebula.randomInfosData),
                pg(nebula.aboutDescription),
                pg(nebula.videoURLsData),
                pg(nebula.radius),
                pg(nebula.distanceFromSun),
                pg(nebula.age),
                pg(nebula.galleryImageData),
                pg(nebula.wikiLink)
            ])
            
            print("✅ Nebula updated in PostgreSQL: \(nebula.name)")
        } catch {
            print("❌ Error updating nebula in PostgreSQL: \(error)")
        }
    }

    // MARK: - Delete Nebula
    func deleteNebula(_ nebula: NebulaModel) {
        let context = container.mainContext
        
        context.delete(nebula)
        do {
            try context.save()
            print("✅ Nebula deleted from SwiftData: \(nebula.name)")
        } catch {
            print("❌ Error deleting nebula from SwiftData: \(error)")
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL for delete")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM nebulas WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(nebula.id)])
            
            print("✅ Nebula deleted from PostgreSQL: \(nebula.name)")
        } catch {
            print("❌ Error deleting nebula from PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Save Star
        func saveStar(_ star: StarModel) {
            let context = container.mainContext
            context.insert(star)
            do {
                try context.save()
                print("✅ Star saved to SwiftData: \(star.name)")
            } catch {
                print("❌ Error saving star to SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    INSERT INTO stars (
                        id, name, star_description, view_count, is_favorite, star_order,
                        image_data, random_infos, about_description, video_urls,
                        radius, distance_from_sun, age, gallery_image_data, wiki_link
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
                    ON CONFLICT (id) DO UPDATE
                    SET name = $2, star_description = $3, view_count = $4, is_favorite = $5, star_order = $6,
                        image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                        radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                """)
                defer { statement.close() }
                
                try statement.execute(parameterValues: [
                    pg(star.id),
                    pg(star.name),
                    pg(star.starDescription),
                    pg(star.viewCount),
                    pg(star.isFavorite),
                    pg(star.star_order),
                    pg(star.imageData),
                    pg(star.randomInfosData),
                    pg(star.aboutDescription),
                    pg(star.videoURLsData),
                    pg(star.radius),
                    pg(star.distanceFromSun),
                    pg(star.age),
                    pg(star.galleryImageData),
                    pg(star.wikiLink)
                ])
                
                print("✅ Star synced to PostgreSQL: \(star.name)")
            } catch {
                print("❌ Error syncing star to PostgreSQL: \(error)")
            }
        }

        // MARK: - Fetch Stars
        func fetchStars() -> [StarModel] {
            let context = container.mainContext
            var stars: [StarModel] = []
            
            // Fetch from SwiftData
            do {
                let descriptor = FetchDescriptor<StarModel>()
                stars = try context.fetch(descriptor)
                print("📱 Fetched \(stars.count) stars from SwiftData: \(stars.map { $0.name })")
                if !stars.isEmpty {
                    return stars
                }
            } catch {
                print("❌ Error fetching stars from SwiftData: \(error)")
            }
            
            // Fetch from PostgreSQL if SwiftData is empty
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return stars
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    SELECT id, name, star_description, view_count, is_favorite, star_order,
                           image_data, random_infos, about_description, video_urls,
                           radius, distance_from_sun, age, gallery_image_data, wiki_link
                    FROM stars
                    ORDER BY star_order ASC
                """)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                for row in cursor {
                    let columns = try row.get().columns
                    let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                    
                    let star = StarModel(
                        id: id,
                        name: try columns[1].optionalString() ?? "",
                        starDescription: try columns[2].optionalString() ?? "",
                        viewCount: try columns[3].optionalInt() ?? 0,
                        isFavorite: try columns[4].optionalBool() ?? false,
                        star_order: try columns[5].optionalInt() ?? 0,
                        imageData: try columns[6].dataFromBytea() ?? Data(),
                        randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                        aboutDescription: try columns[8].optionalString() ?? "",
                        videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                        radius: try columns[10].optionalString() ?? "",
                        distanceFromSun: try columns[11].optionalString() ?? "",
                        age: try columns[12].optionalString() ?? "",
                        galleryImageData: parseByteaArray(try columns[13].optionalString() ?? "{}"),
                        wikiLink: try columns[14].optionalString() ?? ""
                    )
                    
                    // Insert or update in SwiftData
                    if stars.contains(where: { $0.id == star.id }) {
                        stars.first(where: { $0.id == star.id })?.update(from: star)
                    } else {
                        context.insert(star)
                        stars.append(star)
                    }
                }
                
                try context.save()
                print("✅ Synced \(stars.count) stars from PostgreSQL to SwiftData")
            } catch {
                print("❌ Error fetching stars from PostgreSQL: \(error)")
            }
            
            return stars
        }

        // MARK: - Update Star
        func updateStar(_ star: StarModel) {
            let context = container.mainContext
            do {
                try context.save()
                print("✅ Star updated in SwiftData: \(star.name)")
            } catch {
                print("❌ Error updating star in SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    UPDATE stars
                    SET name = $2, star_description = $3, view_count = $4, is_favorite = $5, star_order = $6,
                        image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                        radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                    WHERE id = $1
                """)
                defer { statement.close() }
                
                try statement.execute(parameterValues: [
                    pg(star.id),
                    pg(star.name),
                    pg(star.starDescription),
                    pg(star.viewCount),
                    pg(star.isFavorite),
                    pg(star.star_order),
                    pg(star.imageData),
                    pg(star.randomInfosData),
                    pg(star.aboutDescription),
                    pg(star.videoURLsData),
                    pg(star.radius),
                    pg(star.distanceFromSun),
                    pg(star.age),
                    pg(star.galleryImageData),
                    pg(star.wikiLink)
                ])
                
                print("✅ Star updated in PostgreSQL: \(star.name)")
            } catch {
                print("❌ Error updating star in PostgreSQL: \(error)")
            }
        }

        // MARK: - Delete Star
        func deleteStar(_ star: StarModel) {
            let context = container.mainContext
            
            context.delete(star)
            do {
                try context.save()
                print("✅ Star deleted from SwiftData: \(star.name)")
            } catch {
                print("❌ Error deleting star from SwiftData: \(error)")
                return
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL for delete")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: "DELETE FROM stars WHERE id = $1")
                defer { statement.close() }
                try statement.execute(parameterValues: [pg(star.id)])
                
                print("✅ Star deleted from PostgreSQL: \(star.name)")
            } catch {
                print("❌ Error deleting star from PostgreSQL: \(error)")
            }
        }
    
    // MARK: - Save Blackhole
    func saveBlackhole(_ blackhole: BlackholeModel) {
        let context = container.mainContext
        context.insert(blackhole)
        do {
            try context.save()
            print("✅ Blackhole saved to SwiftData: \(blackhole.name)")
        } catch {
            print("❌ Error saving blackhole to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO blackholes (
                    id, name, blackhole_description, view_count, is_favorite, blackhole_order,
                    image_data, random_infos, about_description, video_urls,
                    radius, distance_from_sun, age, gallery_image_data, wiki_link
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, blackhole_description = $3, view_count = $4, is_favorite = $5, blackhole_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(blackhole.id),
                pg(blackhole.name),
                pg(blackhole.blackholeDescription),
                pg(blackhole.viewCount),
                pg(blackhole.isFavorite),
                pg(blackhole.blackhole_order),
                pg(blackhole.imageData),
                pg(blackhole.randomInfosData),
                pg(blackhole.aboutDescription),
                pg(blackhole.videoURLsData),
                pg(blackhole.radius),
                pg(blackhole.distanceFromSun),
                pg(blackhole.age),
                pg(blackhole.galleryImageData),
                pg(blackhole.wikiLink)
            ])
            
            print("✅ Blackhole synced to PostgreSQL: \(blackhole.name)")
        } catch {
            print("❌ Error syncing blackhole to PostgreSQL: \(error)")
        }
    }

    // MARK: - Fetch Blackholes
    func fetchBlackholes() -> [BlackholeModel] {
        let context = container.mainContext
        var blackholes: [BlackholeModel] = []
        
        // Fetch from SwiftData
        do {
            let descriptor = FetchDescriptor<BlackholeModel>()
            blackholes = try context.fetch(descriptor)
            print("📱 Fetched \(blackholes.count) blackholes from SwiftData: \(blackholes.map { $0.name })")
            if !blackholes.isEmpty {
                return blackholes
            }
        } catch {
            print("❌ Error fetching blackholes from SwiftData: \(error)")
        }
        
        // Fetch from PostgreSQL if SwiftData is empty
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return blackholes
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT id, name, blackhole_description, view_count, is_favorite, blackhole_order,
                       image_data, random_infos, about_description, video_urls,
                       radius, distance_from_sun, age, gallery_image_data, wiki_link
                FROM blackholes
                ORDER BY blackhole_order ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            for row in cursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                
                let blackhole = BlackholeModel(
                    id: id,
                    name: try columns[1].optionalString() ?? "",
                    blackholeDescription: try columns[2].optionalString() ?? "",
                    viewCount: try columns[3].optionalInt() ?? 0,
                    isFavorite: try columns[4].optionalBool() ?? false,
                    blackhole_order: try columns[5].optionalInt() ?? 0,
                    imageData: try columns[6].dataFromBytea() ?? Data(),
                    randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                    aboutDescription: try columns[8].optionalString() ?? "",
                    videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                    radius: try columns[10].optionalString() ?? "",
                    distanceFromSun: try columns[11].optionalString() ?? "",
                    age: try columns[12].optionalString() ?? "",
                    galleryImageData: parseByteaArray(try columns[13].optionalString() ?? "{}"),
                    wikiLink: try columns[14].optionalString() ?? ""
                )
                
                // Insert or update in SwiftData
                if blackholes.contains(where: { $0.id == blackhole.id }) {
                    blackholes.first(where: { $0.id == blackhole.id })?.update(from: blackhole)
                } else {
                    context.insert(blackhole)
                    blackholes.append(blackhole)
                }
            }
            
            try context.save()
            print("✅ Synced \(blackholes.count) blackholes from PostgreSQL to SwiftData")
        } catch {
            print("❌ Error fetching blackholes from PostgreSQL: \(error)")
        }
        
        return blackholes
    }

    // MARK: - Update Blackhole
    func updateBlackhole(_ blackhole: BlackholeModel) {
        let context = container.mainContext
        do {
            try context.save()
            print("✅ Blackhole updated in SwiftData: \(blackhole.name)")
        } catch {
            print("❌ Error updating blackhole in SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE blackholes
                SET name = $2, blackhole_description = $3, view_count = $4, is_favorite = $5, blackhole_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                WHERE id = $1
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(blackhole.id),
                pg(blackhole.name),
                pg(blackhole.blackholeDescription),
                pg(blackhole.viewCount),
                pg(blackhole.isFavorite),
                pg(blackhole.blackhole_order),
                pg(blackhole.imageData),
                pg(blackhole.randomInfosData),
                pg(blackhole.aboutDescription),
                pg(blackhole.videoURLsData),
                pg(blackhole.radius),
                pg(blackhole.distanceFromSun),
                pg(blackhole.age),
                pg(blackhole.galleryImageData),
                pg(blackhole.wikiLink)
            ])
            
            print("✅ Blackhole updated in PostgreSQL: \(blackhole.name)")
        } catch {
            print("❌ Error updating blackhole in PostgreSQL: \(error)")
        }
    }
        
    // MARK: - Delete Blackhole
    func deleteBlackhole(_ blackhole: BlackholeModel) {
        let context = container.mainContext
        
        context.delete(blackhole)
        do {
            try context.save()
            print("✅ Blackhole deleted from SwiftData: \(blackhole.name)")
        } catch {
            print("❌ Error deleting blackhole from SwiftData: \(error)")
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL for delete")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM blackholes WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(blackhole.id)])
            
            print("✅ Blackhole deleted from PostgreSQL: \(blackhole.name)")
        } catch {
            print("❌ Error deleting blackhole from PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Save Constellation
    func saveConstellation(_ constellation: ConstellationModel) {
        let context = container.mainContext
        context.insert(constellation)
        do {
            try context.save()
            print("✅ Constellation saved to SwiftData: \(constellation.name)")
        } catch {
            print("❌ Error saving constellation to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO constellations (
                    id, name, constellation_description, view_count, is_favorite, constellation_order,
                    image_data, random_infos, about_description, video_urls,
                    main_stars, named_stars, gallery_image_data, wiki_link
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, constellation_description = $3, view_count = $4, is_favorite = $5, constellation_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    main_stars = $11, named_stars = $12, gallery_image_data = $13, wiki_link = $14
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(constellation.id),
                pg(constellation.name),
                pg(constellation.constellationDescription),
                pg(constellation.viewCount),
                pg(constellation.isFavorite),
                pg(constellation.constellation_order),
                pg(constellation.imageData),
                pg(constellation.randomInfosData),
                pg(constellation.aboutDescription),
                pg(constellation.videoURLsData),
                pg(constellation.mainStars),
                pg(constellation.namedStarsData),
                pg(constellation.galleryImageData),
                pg(constellation.wikiLink)
            ])
            
            print("✅ Constellation synced to PostgreSQL: \(constellation.name)")
        } catch {
            print("❌ Error syncing constellation to PostgreSQL: \(error)")
        }
    }
    
    // MARK: - Fetch Constellations
        func fetchConstellations() -> [ConstellationModel] {
            let context = container.mainContext
            var constellations: [ConstellationModel] = []
            
            // Fetch from SwiftData
            do {
                let descriptor = FetchDescriptor<ConstellationModel>()
                constellations = try context.fetch(descriptor)
                print("📱 Fetched \(constellations.count) constellations from SwiftData: \(constellations.map { $0.name })")
                if !constellations.isEmpty {
                    return constellations
                }
            } catch {
                print("❌ Error fetching constellations from SwiftData: \(error)")
            }
            
            // Fetch from PostgreSQL if SwiftData is empty
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return constellations
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    SELECT id, name, constellation_description, view_count, is_favorite, constellation_order,
                           image_data, random_infos, about_description, video_urls,
                           main_stars, named_stars, gallery_image_data, wiki_link
                    FROM constellations
                    ORDER BY constellation_order ASC
                """)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                for row in cursor {
                    let columns = try row.get().columns
                    let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                    
                    let constellation = ConstellationModel(
                        id: id,
                        name: try columns[1].optionalString() ?? "",
                        constellationDescription: try columns[2].optionalString() ?? "",
                        viewCount: try columns[3].optionalInt() ?? 0,
                        isFavorite: try columns[4].optionalBool() ?? false,
                        constellation_order: try columns[5].optionalInt() ?? 0,
                        imageData: try columns[6].dataFromBytea() ?? Data(),
                        randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                        aboutDescription: try columns[8].optionalString() ?? "",
                        videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                        mainStars: try columns[10].optionalInt() ?? 0,
                        namedStars: parseTextArray(try columns[11].optionalString() ?? "{}"),
                        galleryImageData: parseByteaArray(try columns[12].optionalString() ?? "{}"),
                        wikiLink: try columns[13].optionalString() ?? ""
                    )
                    
                    // Insert or update in SwiftData
                    if constellations.contains(where: { $0.id == constellation.id }) {
                        constellations.first(where: { $0.id == constellation.id })?.update(from: constellation)
                    } else {
                        context.insert(constellation)
                        constellations.append(constellation)
                    }
                }
                
                try context.save()
                print("✅ Synced \(constellations.count) constellations from PostgreSQL to SwiftData")
            } catch {
                print("❌ Error fetching constellations from PostgreSQL: \(error)")
            }
            
            return constellations
        }

        // MARK: - Update Constellation
        func updateConstellation(_ constellation: ConstellationModel) {
            let context = container.mainContext
            do {
                try context.save()
                print("✅ Constellation updated in SwiftData: \(constellation.name)")
            } catch {
                print("❌ Error updating constellation in SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    UPDATE constellations
                    SET name = $2, constellation_description = $3, view_count = $4, is_favorite = $5, constellation_order = $6,
                        image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                        main_stars = $11, named_stars = $12, gallery_image_data = $13, wiki_link = $14
                    WHERE id = $1
                """)
                defer { statement.close() }
                
                try statement.execute(parameterValues: [
                    pg(constellation.id),
                    pg(constellation.name),
                    pg(constellation.constellationDescription),
                    pg(constellation.viewCount),
                    pg(constellation.isFavorite),
                    pg(constellation.constellation_order),
                    pg(constellation.imageData),
                    pg(constellation.randomInfosData),
                    pg(constellation.aboutDescription),
                    pg(constellation.videoURLsData),
                    pg(constellation.mainStars),
                    pg(constellation.namedStarsData),
                    pg(constellation.galleryImageData),
                    pg(constellation.wikiLink)
                ])
                
                print("✅ Constellation updated in PostgreSQL: \(constellation.name)")
            } catch {
                print("❌ Error updating constellation in PostgreSQL: \(error)")
            }
        }

        // MARK: - Delete Constellation
        func deleteConstellation(_ constellation: ConstellationModel) {
            let context = container.mainContext
            
            context.delete(constellation)
            do {
                try context.save()
                print("✅ Constellation deleted from SwiftData: \(constellation.name)")
            } catch {
                print("❌ Error deleting constellation from SwiftData: \(error)")
                return
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL for delete")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: "DELETE FROM constellations WHERE id = $1")
                defer { statement.close() }
                try statement.execute(parameterValues: [pg(constellation.id)])
                
                print("✅ Constellation deleted from PostgreSQL: \(constellation.name)")
            } catch {
                print("❌ Error deleting constellation from PostgreSQL: \(error)")
            }
        }
    
    // MARK: - Save Planets
    func savePlanets(_ planets: PlanetsModel) {
        let context = container.mainContext
        context.insert(planets)
        do {
            try context.save()
            print("✅ Planets saved to SwiftData: \(planets.name)")
        } catch {
            print("❌ Error saving planets to SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO planetss (
                    id, name, planets_description, view_count, is_favorite, planets_order,
                    image_data, random_infos, about_description, video_urls,
                    radius, distance_from_sun, age, gallery_image_data, wiki_link
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
                ON CONFLICT (id) DO UPDATE
                SET name = $2, planets_description = $3, view_count = $4, is_favorite = $5, planets_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(planets.id),
                pg(planets.name),
                pg(planets.planetsDescription),
                pg(planets.viewCount),
                pg(planets.isFavorite),
                pg(planets.planets_order),
                pg(planets.imageData),
                pg(planets.randomInfosData),
                pg(planets.aboutDescription),
                pg(planets.videoURLsData),
                pg(planets.radius),
                pg(planets.distanceFromSun),
                pg(planets.age),
                pg(planets.galleryImageData),
                pg(planets.wikiLink)
            ])
            
            print("✅ Planets synced to PostgreSQL: \(planets.name)")
        } catch {
            print("❌ Error syncing planets to PostgreSQL: \(error)")
        }
    }

    // MARK: - Fetch Planets
    func fetchPlanets() -> [PlanetsModel] {
        let context = container.mainContext
        var planets: [PlanetsModel] = []
        
        // Fetch from SwiftData
        do {
            let descriptor = FetchDescriptor<PlanetsModel>()
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
            let statement = try connection.prepareStatement(text: """
                SELECT id, name, planets_description, view_count, is_favorite, planets_order,
                       image_data, random_infos, about_description, video_urls,
                       radius, distance_from_sun, age, gallery_image_data, wiki_link
                FROM planetss
                ORDER BY planets_order ASC
            """)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            for row in cursor {
                let columns = try row.get().columns
                let id = UUID(uuidString: try columns[0].optionalString() ?? "") ?? UUID()
                
                let planet = PlanetsModel(
                    id: id,
                    name: try columns[1].optionalString() ?? "",
                    planetsDescription: try columns[2].optionalString() ?? "",
                    viewCount: try columns[3].optionalInt() ?? 0,
                    isFavorite: try columns[4].optionalBool() ?? false,
                    planets_order: try columns[5].optionalInt() ?? 0,
                    imageData: try columns[6].dataFromBytea() ?? Data(),
                    randomInfos: parseTextArray(try columns[7].optionalString() ?? "{}"),
                    aboutDescription: try columns[8].optionalString() ?? "",
                    videoURLs: parseTextArray(try columns[9].optionalString() ?? "{}"),
                    radius: try columns[10].optionalString() ?? "",
                    distanceFromSun: try columns[11].optionalString() ?? "",
                    age: try columns[12].optionalString() ?? "",
                    galleryImageData: parseByteaArray(try columns[13].optionalString() ?? "{}"),
                    wikiLink: try columns[14].optionalString() ?? ""
                )
                
                // Insert or update in SwiftData
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

    // MARK: - Update Planets
    func updatePlanets(_ planets: PlanetsModel) {
        let context = container.mainContext
        do {
            try context.save()
            print("✅ Planets updated in SwiftData: \(planets.name)")
        } catch {
            print("❌ Error updating planets in SwiftData: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE planetss
                SET name = $2, planets_description = $3, view_count = $4, is_favorite = $5, planets_order = $6,
                    image_data = $7, random_infos = $8, about_description = $9, video_urls = $10,
                    radius = $11, distance_from_sun = $12, age = $13, gallery_image_data = $14, wiki_link = $15
                WHERE id = $1
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pg(planets.id),
                pg(planets.name),
                pg(planets.planetsDescription),
                pg(planets.viewCount),
                pg(planets.isFavorite),
                pg(planets.planets_order),
                pg(planets.imageData),
                pg(planets.randomInfosData),
                pg(planets.aboutDescription),
                pg(planets.videoURLsData),
                pg(planets.radius),
                pg(planets.distanceFromSun),
                pg(planets.age),
                pg(planets.galleryImageData),
                pg(planets.wikiLink)
            ])
            
            print("✅ Planets updated in PostgreSQL: \(planets.name)")
        } catch {
            print("❌ Error updating planets in PostgreSQL: \(error)")
        }
    }
        
    // MARK: - Delete Planets
    func deletePlanets(_ planets: PlanetsModel) {
        let context = container.mainContext
        
        context.delete(planets)
        do {
            try context.save()
            print("✅ Planets deleted from SwiftData: \(planets.name)")
        } catch {
            print("❌ Error deleting planets from SwiftData: \(error)")
            return
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Failed to connect to PostgreSQL for delete")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM planets WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(planets.id)])
            
            print("✅ Planets deleted from PostgreSQL: \(planets.name)")
        } catch {
            print("❌ Error deleting planets from PostgreSQL: \(error)")
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
