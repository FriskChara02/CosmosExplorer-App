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
            ValueTransformer.registerIfNeeded()
            
            let schema = Schema([PlanetModel.self, UserModel.self, GalaxyModel.self, NebulaModel.self, StarModel.self, BlackholeModel.self, ConstellationModel.self, PlanetsModel.self, Quiz.self, Card.self, Attempt.self, Favorite.self, UserProgress.self, FriendRequestModel.self, FriendshipModel.self, ChatModel.self, MessageModel.self, GroupModel.self, GroupMemberModel.self, GroupMessageModel.self, GroupWordFilterModel.self, GalaxyComment.self, BlackholeComment.self, StarComment.self, NebulaComment.self, PlanetsComment.self, ConstellationComment.self, PlanetComment.self])
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
        
        init(inMemory: Bool = false) {
            ValueTransformer.registerIfNeeded()
            let schema = Schema([PlanetModel.self, UserModel.self, GalaxyModel.self, NebulaModel.self, StarModel.self, BlackholeModel.self, ConstellationModel.self, PlanetsModel.self, Quiz.self, Card.self, Attempt.self, Favorite.self, UserProgress.self, FriendRequestModel.self, FriendshipModel.self, ChatModel.self, MessageModel.self, GroupModel.self, GroupMemberModel.self, GroupMessageModel.self, GroupWordFilterModel.self, GalaxyComment.self, BlackholeComment.self, StarComment.self, NebulaComment.self, PlanetsComment.self, ConstellationComment.self, PlanetComment.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            self.container = try! ModelContainer(for: schema, configurations: config)
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
                    INSERT INTO users (id, email, username, created_at, avatar, user_description, date_of_birth, 
                                     location, gender, hobbies, bio, rank, score, token, status, role)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
                    ON CONFLICT (id) DO UPDATE
                    SET email = $2, username = $3, created_at = $4, avatar = $5, user_description = $6,
                        date_of_birth = $7, location = $8, gender = $9, hobbies = $10, bio = $11,
                        rank = $12, score = $13, token = $14, status = $15, role = $16
                """)
                defer { statement.close() }
                
                let dateOfBirthString = user.dateOfBirth != nil ? ISO8601DateFormatter().string(from: user.dateOfBirth!) : nil
                
                try statement.execute(parameterValues: [
                    pg(user.id),
                    pg(user.email),
                    pg(user.username),
                    pg(ISO8601DateFormatter().string(from: user.createdAt)),
                    pg(user.avatar),
                    pg(user.userDescription),
                    pg(dateOfBirthString),
                    pg(user.location),
                    pg(user.gender),
                    pg(user.hobbies),
                    pg(user.bio),
                    pg(user.rank),
                    pg(user.score),
                    pg(user.token),
                    pg(user.status),
                    pg(user.role)
                ])
                print("✅ User synced to PostgreSQL")
            } catch {
                print("❌ Error syncing user to PostgreSQL: \(error)")
            }
        }

        // MARK: - Update User
        func updateUser(_ user: UserModel) {
            let context = container.mainContext
            do {
                try context.save()
                print("✅ User updated in SwiftData")
            } catch {
                print("❌ Error updating user in SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: """
                    UPDATE users
                    SET email = $2, username = $3, avatar = $4, user_description = $5, date_of_birth = $6,
                        location = $7, gender = $8, hobbies = $9, bio = $10, rank = $11, score = $12,
                        token = $13, status = $14, role = $15
                    WHERE id = $1
                """)
                defer { statement.close() }
                
                let dateOfBirthString = user.dateOfBirth != nil ? ISO8601DateFormatter().string(from: user.dateOfBirth!) : nil
                
                try statement.execute(parameterValues: [
                    pg(user.id),
                    pg(user.email),
                    pg(user.username),
                    pg(user.avatar),
                    pg(user.userDescription),
                    pg(dateOfBirthString),
                    pg(user.location),
                    pg(user.gender),
                    pg(user.hobbies),
                    pg(user.bio),
                    pg(user.rank),
                    pg(user.score),
                    pg(user.token),
                    pg(user.status),
                    pg(user.role)
                ])
                print("✅ User updated in PostgreSQL")
            } catch {
                print("❌ Error updating user in PostgreSQL: \(error)")
            }
        }

        // MARK: - Delete User
        func deleteUser(_ user: UserModel) {
            let context = container.mainContext
            context.delete(user)
            do {
                try context.save()
                print("✅ User deleted from SwiftData")
            } catch {
                print("❌ Error deleting user from SwiftData: \(error)")
            }
            
            guard let connection = try? DatabaseConfig.createConnection() else {
                print("❌ Failed to connect to PostgreSQL")
                return
            }
            defer { connection.close() }
            
            do {
                let statement = try connection.prepareStatement(text: "DELETE FROM users WHERE id = $1")
                defer { statement.close() }
                try statement.execute(parameterValues: [pg(user.id)])
                print("✅ User deleted from PostgreSQL")
            } catch {
                print("❌ Error deleting user from PostgreSQL: \(error)")
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
        
    func updateUserScoreAndRank(userId: UUID, score: Int, rank: Int) async {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let stmt = try connection.prepareStatement(text: "UPDATE users SET score = $1, rank = $2 WHERE id = $3")
            defer { stmt.close() }
            try stmt.execute(parameterValues: [score, rank, userId.uuidString])
        } catch {
            print("Lỗi cập nhật score/rank lên server: \(error)")
        }
    }
        
    private func syncQuizToPostgreSQL(_ quiz: Quiz) {
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO quizzes (
                    id, title, description, is_public, created_by, created_at, updated_at, categories
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (id) DO UPDATE
                SET title = $2, description = $3, is_public = $4, created_by = $5,
                    created_at = $6, updated_at = $7, categories = $8
            """)
            defer { statement.close() }
            
            let parameters: [PostgresValueConvertible?] = [
                pg(Int64(quiz.id)),
                pg(quiz.title),
                pg(quiz.quizDescription),
                pg(quiz.isPublic),
                pg(quiz.createdBy?.uuidString),
                pg(quiz.createdAt),
                pg(quiz.updatedAt),
                pgArray(quiz.categories)
            ]
            
            try statement.execute(parameterValues: parameters.compactMap { $0 })
            
            let deleteCards = try connection.prepareStatement(text: "DELETE FROM cards WHERE quiz_id = $1")
            try deleteCards.execute(parameterValues: [pg(Int64(quiz.id))])
            deleteCards.close()
            
            for card in quiz.cards {
                let cardStmt = try connection.prepareStatement(text: """
                    INSERT INTO cards (
                        id, quiz_id, term, definition, hint, image_data,
                        term_formatting, definition_formatting
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                """)
                defer { cardStmt.close() }
                
                let cardParams: [PostgresValueConvertible?] = [
                    pg(Int64(card.id)),
                    pg(Int64(quiz.id)),
                    pg(card.term),
                    pg(card.definition),
                    pg(card.hint),
                    pg(card.imageData),
                    pg(card.termFormatting),
                    pg(card.definitionFormatting)
                ]
                
                try cardStmt.execute(parameterValues: cardParams.compactMap { $0 })
            }
            
            print("Quiz synced to PostgreSQL: \(quiz.title) (id: \(quiz.id))")
        } catch {
            print("Error syncing quiz to PostgreSQL: \(error)")
        }
    }
    
    // MARK: Save Quiz
    func saveQuiz(_ quiz: Quiz) {
        let context = container.mainContext
        
        context.insert(quiz)
            if quiz.id == 0 {
                quiz.id = Int64(Date().timeIntervalSince1970 * 1000)
            }
        do {
            try context.save()
            print("Quiz saved to SwiftData: \(quiz.title)")
        } catch {
            print("Error saving quiz to SwiftData: \(error)")
        }

        guard let connection = try? DatabaseConfig.createConnection() else {
            print("Failed to connect to PostgreSQL")
            return
        }
        defer { connection.close() }

        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO quizzes (
                    id, title, description, is_public, created_by, created_at, updated_at, categories
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (id) DO UPDATE
                SET title = $2, description = $3, is_public = $4, created_by = $5,
                    created_at = $6, updated_at = $7, categories = $8
            """)
            defer { statement.close() }

            let parameters: [PostgresValueConvertible?] = [
                pg(Int64(quiz.id)),
                pg(quiz.title),
                pg(quiz.quizDescription),
                pg(quiz.isPublic),
                pg(quiz.createdBy?.uuidString),
                pg(quiz.createdAt),
                pg(quiz.updatedAt),
                pgArray(quiz.categories)
            ]

            try statement.execute(parameterValues: parameters.compactMap { $0 })

            let deleteCards = try connection.prepareStatement(text: "DELETE FROM cards WHERE quiz_id = $1")
            defer { deleteCards.close() }
            try deleteCards.execute(parameterValues: [pg(Int64(quiz.id))].compactMap { $0 })

            for card in quiz.cards {
                let cardStmt = try connection.prepareStatement(text: """
                    INSERT INTO cards (
                        id, quiz_id, term, definition, hint, image_data,
                        term_formatting, definition_formatting
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                """)
                defer { cardStmt.close() }

                let cardParams: [PostgresValueConvertible?] = [
                    pg(Int64(card.id)),
                    pg(Int64(quiz.id)),
                    pg(card.term),
                    pg(card.definition),
                    pg(card.hint),
                    pg(card.imageData),
                    pg(card.termFormatting),
                    pg(card.definitionFormatting)
                ]

                try cardStmt.execute(parameterValues: cardParams.compactMap { $0 })
            }

            print("Quiz synced to PostgreSQL: \(quiz.title)")
        } catch {
            print("Error syncing quiz to PostgreSQL: \(error)")
        }
    }

    // MARK: Fetch Quizzes
    func fetchQuizzes() -> [Quiz] {
        let context = container.mainContext
        var quizzes: [Quiz] = []

        // SwiftData
        do {
            let descriptor = FetchDescriptor<Quiz>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            quizzes = try context.fetch(descriptor)
            if !quizzes.isEmpty { return quizzes }
        } catch {
            print("Error fetching from SwiftData: \(error)")
        }

        // PostgreSQL
        guard let connection = try? DatabaseConfig.createConnection() else { return quizzes }
        defer { connection.close() }

        do {
            let stmt = try connection.prepareStatement(text: """
                SELECT id, title, description, is_public, created_by, created_at, updated_at, categories
                FROM quizzes ORDER BY created_at DESC
            """)
            defer { stmt.close() }

            let cursor = try stmt.execute()
            for row in cursor {
                let cols = try row.get().columns
                let quizId: Int64 = try Int64(cols[0].int())
                
                let rawCategories = try cols[7].optionalString() ?? "{}"

                let categories: [String] = {
                    let str = rawCategories
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard !str.isEmpty, str != "{}" else { return [] }
                    
                    return str
                        .replacingOccurrences(of: "{", with: "")
                        .replacingOccurrences(of: "}", with: "")
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                }()

                let quiz = Quiz(
                    id: quizId,
                    title: try cols[1].string(),
                    quizDescription: try cols[2].string(),
                    isPublic: try cols[3].bool(),
                    createdBy: UUID(uuidString: try cols[4].optionalString() ?? ""),
                    categories: categories
                )
                quiz.createdAt = try cols[5].timestamp().date(in: .gmt)
                quiz.updatedAt = try cols[6].timestamp().date(in: .gmt)
                quiz.cards = try fetchRelatedCards(connection: connection, quizId: quizId)

                if let existing = quizzes.first(where: { $0.id == quiz.id }) {
                    existing.update(
                        updatedTitle: quiz.title,
                        updatedDescription: quiz.quizDescription,
                        updatedIsPublic: quiz.isPublic,
                        updatedCategories: quiz.categories
                    )
                    existing.cards = quiz.cards
                    existing.createdAt = quiz.createdAt
                    existing.updatedAt = quiz.updatedAt
                    existing.createdBy = quiz.createdBy
                } else {
                    context.insert(quiz)
                    quizzes.append(quiz)
                }
            }
            try context.save()
        } catch {
            print("Error fetching from PostgreSQL: \(error)")
        }
        return quizzes
    }

    private func fetchRelatedCards(connection: Connection, quizId: Int64) throws -> [Card] {
        let stmt = try connection.prepareStatement(text: """
            SELECT id, term, definition, hint, image_data, term_formatting, definition_formatting
            FROM cards WHERE quiz_id = $1
        """)
        defer { stmt.close() }

        let cursor = try stmt.execute(parameterValues: [pg(quizId)].compactMap { $0 })
        var cards: [Card] = []
        for row in cursor {
            let cols = try row.get().columns
            let card = Card(
                id: try Int64(cols[0].int()),
                term: try cols[1].string(),
                definition: try cols[2].string(),
                hint: try cols[3].optionalString(),
                imageData: try cols[4].optionalByteA()?.data,
                termFormatting: try cols[5].optionalByteA()?.data,
                definitionFormatting: try cols[6].optionalByteA()?.data
            )
            cards.append(card)
        }
        return cards
    }

    // MARK: Update Quiz
    func updateQuiz(_ quiz: Quiz) {
        let context = container.mainContext
        do { try context.save() } catch { print("SwiftData update error: \(error)") }

        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let stmt = try connection.prepareStatement(text: """
                UPDATE quizzes SET title = $2, description = $3, is_public = $4, created_by = $5,
                    created_at = $6, updated_at = $7, categories = $8 WHERE id = $1
            """)
            defer { stmt.close() }

            try stmt.execute(parameterValues: [
                pg(Int64(quiz.id)),
                pg(quiz.title),
                pg(quiz.quizDescription),
                pg(quiz.isPublic),
                pg(quiz.createdBy?.uuidString),
                pg(quiz.createdAt),
                pg(quiz.updatedAt),
                pgArray(quiz.categories)
            ].compactMap { $0 })

            let del = try connection.prepareStatement(text: "DELETE FROM cards WHERE quiz_id = $1")
            defer { del.close() }
            try del.execute(parameterValues: [pg(Int64(quiz.id))].compactMap { $0 })

            for card in quiz.cards {
                let cardStmt = try connection.prepareStatement(text: """
                    INSERT INTO cards (id, quiz_id, term, definition, hint, image_data, term_formatting, definition_formatting)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                """)
                defer { cardStmt.close() }

                try cardStmt.execute(parameterValues: [
                    pg(Int64(card.id)),
                    pg(Int64(quiz.id)),
                    pg(card.term),
                    pg(card.definition),
                    pg(card.hint),
                    pg(card.imageData),
                    pg(card.termFormatting),
                    pg(card.definitionFormatting)
                ].compactMap { $0 })
            }
        } catch {
            print("PostgreSQL update error: \(error)")
        }
    }

    // MARK: Delete Quiz
        func deleteQuiz(_ quiz: Quiz) {
            let context = container.mainContext
            
            let quizId = quiz.id
            let attemptPredicate = #Predicate<Attempt> { $0.quizId == quizId }
            if let attempts = try? context.fetch(FetchDescriptor<Attempt>(predicate: attemptPredicate)) {
                attempts.forEach { context.delete($0) }
            }
            
            context.delete(quiz)
            
            do { try context.save() } catch { print("Delete SwiftData error: \(error)") }
            
            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }
            
            do {
                let deleteAttempts = try connection.prepareStatement(text: "DELETE FROM attempts WHERE quiz_id = $1")
                defer { deleteAttempts.close() }
                try deleteAttempts.execute(parameterValues: [pg(Int64(quiz.id))].compactMap { $0 })
                
                let deleteQuiz = try connection.prepareStatement(text: "DELETE FROM quizzes WHERE id = $1")
                defer { deleteQuiz.close() }
                try deleteQuiz.execute(parameterValues: [pg(Int64(quiz.id))].compactMap { $0 })
            } catch {
                print("PostgreSQL delete error: \(error)")
            }
        }

    // MARK: - Attempt Methods
    func loadOrCreateAttempt(for quizId: Int64, mode: String, userId: UUID) -> Attempt {
        let context = container.mainContext
        let userIdCaptured = userId
        let quizIdCaptured = quizId
        let modeCaptured = mode
        
        let predicate = #Predicate<Attempt> {
            $0.userId == userIdCaptured && $0.quizId == quizIdCaptured && $0.mode == modeCaptured
        }
        
        if let existing = try? context.fetch(FetchDescriptor<Attempt>(predicate: predicate)).first {
            return existing
        }

        guard quizId != 0 else {
            fatalError("quizId không hợp lệ (0) – không thể tạo Attempt")
        }
        
        let newAttempt = Attempt(userId: userId, quizId: quizId, mode: mode)
        if newAttempt.id == 0 {
            newAttempt.id = Int64(Date().timeIntervalSince1970 * 1000) + Int64.random(in: 0..<1000)
        }
        
        context.insert(newAttempt)
        
        do {
            try context.save()
        } catch {
            print("❌ Error saving new attempt: \(error)")
        }
        
        saveOrUpdateAttempt(newAttempt, isUpdate: false)
        return newAttempt
    }

        func updateAttempt(_ attempt: Attempt) {
        guard let context = attempt.modelContext else {
            print("❌ Attempt không có modelContext - object bị detached!")
            container.mainContext.insert(attempt)
            try? container.mainContext.save()
            saveOrUpdateAttempt(attempt, isUpdate: true)
            return
        }
        
        print("🔍 Updating attempt: id=\(attempt.id), userId=\(attempt.userId), mode=\(attempt.mode), correct=\(attempt.correctCount), incorrect=\(attempt.incorrectCount)")
        
        do {
            try context.save()
            print("💾 Attempt saved to SwiftData")
        } catch {
            print("❌ Error saving attempt: \(error)")
        }
        saveOrUpdateAttempt(attempt, isUpdate: true)
    }
        
    func fetchAttemptsFromPostgreSQL(userId: UUID, mode: String? = nil) -> [Attempt] {
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Không thể kết nối PostgreSQL")
            return []
        }
        defer { connection.close() }
        
        do {
            let query: String
            let params: [PostgresValueConvertible?]
            
            if let mode = mode {
                query = """
                SELECT id, user_id, quiz_id, mode, 
                       started_at::text, last_updated::text,
                       is_completed, current_index, correct_count, incorrect_count
                FROM attempts 
                WHERE user_id = $1 AND mode = $2 
                ORDER BY last_updated DESC
                """
                params = [pg(userId.uuidString), pg(mode)]
            } else {
                query = """
                SELECT id, user_id, quiz_id, mode, 
                       started_at::text, last_updated::text,
                       is_completed, current_index, correct_count, incorrect_count
                FROM attempts 
                WHERE user_id = $1 
                ORDER BY last_updated DESC
                """
                params = [pg(userId.uuidString)]
            }
            
            let stmt = try connection.prepareStatement(text: query)
            let cursor = try stmt.execute(parameterValues: params.compactMap { $0 })
            
            var attempts: [Attempt] = []
            let dateFormatter = ISO8601DateFormatter()
            
            for row in cursor {
                let columns = try row.get().columns
                
                let id = try columns[0].int()
                let userIdStr = try columns[1].string()
                let quizId = try columns[2].int()
                let mode = try columns[3].string()
                let startedAtStr = try columns[4].string()
                let lastUpdatedStr = try columns[5].string()
                let isCompleted = try columns[6].bool()
                let currentIndex = try columns[7].int()
                let correctCount = try columns[8].int()
                let incorrectCount = try columns[9].int()
                
                let attempt = Attempt(
                    id: Int64(id),
                    userId: UUID(uuidString: userIdStr) ?? userId,
                    quizId: Int64(quizId),
                    mode: mode
                )
                attempt.startedAt = dateFormatter.date(from: startedAtStr) ?? Date()
                attempt.lastUpdated = dateFormatter.date(from: lastUpdatedStr) ?? Date()
                attempt.isCompleted = isCompleted
                attempt.currentIndex = currentIndex
                attempt.correctCount = correctCount
                attempt.incorrectCount = incorrectCount
                
                attempts.append(attempt)
            }
            
            return attempts
            
        } catch {
            print("❌ Error fetching attempts: \(error)")
            return []
        }
    }

    public func saveOrUpdateAttempt(_ attempt: Attempt, isUpdate: Bool) {
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let userAnswersJSON = String(data: try JSONEncoder().encode(attempt.userAnswers), encoding: .utf8)!

            let correctCardsPG = attempt.correctCardsPG

            let sql = isUpdate ? """
                UPDATE attempts 
                SET user_id = $2, quiz_id = $3, mode = $4, started_at = $5, last_updated = $6,
                    is_completed = $7, current_index = $8, correct_count = $9, incorrect_count = $10,
                    user_answers = $11::jsonb, 
                    correct_cards = $12::bigint[]
                WHERE id = $1
                """ : """
                INSERT INTO attempts (
                    id, user_id, quiz_id, mode, started_at, last_updated,
                    is_completed, current_index, correct_count, incorrect_count,
                    user_answers, correct_cards
                )
                VALUES (
                    $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,
                    $11::jsonb, $12
                )
                ON CONFLICT (id) DO UPDATE SET
                    user_id=EXCLUDED.user_id,
                    quiz_id=EXCLUDED.quiz_id,
                    mode=EXCLUDED.mode,
                    started_at=EXCLUDED.started_at,
                    last_updated=EXCLUDED.last_updated,
                    is_completed=EXCLUDED.is_completed,
                    current_index=EXCLUDED.current_index,
                    correct_count=EXCLUDED.correct_count,
                    incorrect_count=EXCLUDED.incorrect_count,
                    user_answers=EXCLUDED.user_answers,
                    correct_cards=EXCLUDED.correct_cards
                """

            let stmt = try connection.prepareStatement(text: sql)
            defer { stmt.close() }

            try stmt.execute(parameterValues: [
                pg(attempt.id),
                pg(attempt.userId.uuidString),
                pg(attempt.quizId),
                pg(attempt.mode),
                pg(attempt.startedAt),
                pg(attempt.lastUpdated),
                pg(attempt.isCompleted),
                pg(attempt.currentIndex),
                pg(attempt.correctCount),
                pg(attempt.incorrectCount),
                pg(userAnswersJSON),
                correctCardsPG
            ].compactMap { $0 })

        } catch {
            print("Attempt sync error: \(error)")
        }
    }
        
    func syncAttemptToPostgreSQL(_ attempt: Attempt) async {
        print("🔄 Bắt đầu sync attempt: id=\(attempt.id), completed=\(attempt.isCompleted), correct=\(attempt.correctCount), incorrect=\(attempt.incorrectCount)")
        
        guard let connection = try? DatabaseConfig.createConnection() else {
            print("❌ Không thể tạo kết nối database")
            return
        }
        defer { connection.close() }
        
        do {
            let checkQuery = "SELECT is_completed, correct_count, incorrect_count FROM attempts WHERE id = $1"
            let existsStmt = try connection.prepareStatement(text: checkQuery)
            if let existingRow = try existsStmt.execute(parameterValues: [pg(attempt.id)]).next() {
                let existingCompleted = try existingRow.get().columns[0].bool()
                print("📋 Attempt đã tồn tại trong database: completed=\(existingCompleted)")
            } else {
                print("➕ Attempt chưa tồn tại trong database")
            }
            
            let userAnswersJSON = String(data: try JSONEncoder().encode(attempt.userAnswers), encoding: .utf8) ?? "{}"
            
            if attempt.isCompleted {
                let upsertQuery = """
                INSERT INTO attempts (
                    id, user_id, quiz_id, mode, started_at, last_updated,
                    is_completed, current_index, correct_count, incorrect_count,
                    user_answers, correct_cards
                ) VALUES (
                    $1, $2::uuid, $3, $4, $5, NOW(),
                    $6, $7, $8, $9, $10::jsonb, $11::bigint[]
                )
                ON CONFLICT (id) DO UPDATE SET
                    is_completed = $6,
                    correct_count = $8,
                    incorrect_count = $9,
                    last_updated = NOW(),
                    user_answers = $10::jsonb,
                    correct_cards = $11::bigint[]
                """
                
                try connection.prepareStatement(text: upsertQuery).execute(parameterValues: [
                    pg(attempt.id),
                    pg(attempt.userId.uuidString),
                    pg(attempt.quizId),
                    pg(attempt.mode),
                    pg(attempt.startedAt),
                    pg(attempt.isCompleted),
                    pg(attempt.currentIndex),
                    pg(attempt.correctCount),
                    pg(attempt.incorrectCount),
                    pg(userAnswersJSON),
                    attempt.correctCardsPG
                ].compactMap { $0 })
                
                print("✅ Đã đồng bộ attempt vào database: id=\(attempt.id), completed=\(attempt.isCompleted)")
            } else {
                print("⏳ Attempt chưa hoàn thành, không đồng bộ đầy đủ")
            }
            
        } catch {
            print("❌ Lỗi sync attempt \(attempt.id): \(error)")
        }
    }
    

    // MARK: - Favorite Methods

    func addFavorite(cardId: Int64, quizId: Int64, userId: UUID) {
        let context = container.mainContext
        let favorite = Favorite(userId: userId, cardId: cardId, quizId: quizId)
        context.insert(favorite)
        try? context.save()

        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let stmt = try connection.prepareStatement(text: """
                INSERT INTO favorites (id, user_id, card_id, quiz_id, added_at)
                VALUES ($1, $2, $3, $4, $5)
            """)
            defer { stmt.close() }
            try stmt.execute(parameterValues: [
                pg(favorite.id),
                pg(userId.uuidString),
                pg(cardId),
                pg(quizId),
                pg(favorite.addedAt)
            ].compactMap { $0 })
        } catch {
            print("Add favorite error: \(error)")
        }
    }

    func removeFavorite(cardId: Int64, userId: UUID) {
        let context = container.mainContext
        let predicate = #Predicate<Favorite> { $0.userId == userId && $0.cardId == cardId }
        let favorites = try? context.fetch(FetchDescriptor<Favorite>(predicate: predicate))
        favorites?.forEach { context.delete($0) }
        try? context.save()

        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }

        do {
            let stmt = try connection.prepareStatement(text: "DELETE FROM favorites WHERE user_id = $1 AND card_id = $2")
            defer { stmt.close() }
            try stmt.execute(parameterValues: [
                pg(userId.uuidString),
                pg(cardId)
            ].compactMap { $0 })
        } catch {
            print("Remove favorite error: \(error)")
        }
    }

    func isFavorite(cardId: Int64, userId: UUID) -> Bool {
        let context = container.mainContext
        let predicate = #Predicate<Favorite> { $0.userId == userId && $0.cardId == cardId }
        return (try? context.fetchCount(FetchDescriptor<Favorite>(predicate: predicate))) ?? 0 > 0
    }

    // MARK: - UserProgress
        func updateUserProgress(_ progress: UserProgress) {
            let context = container.mainContext
            try? context.save()

            guard let connection = try? DatabaseConfig.createConnection() else { return }
            defer { connection.close() }

            do {
                let stmt = try connection.prepareStatement(text: """
                    INSERT INTO user_progress (
                        user_id, streak_days, last_completed_date, 
                        weekly_completions, total_completions
                    )
                    VALUES ($1, $2, $3, $4::text[], $5)
                    ON CONFLICT (user_id) DO UPDATE SET
                        streak_days = EXCLUDED.streak_days,
                        last_completed_date = EXCLUDED.last_completed_date,
                        weekly_completions = EXCLUDED.weekly_completions,
                        total_completions = EXCLUDED.total_completions
                    """)
                defer { stmt.close() }

                try stmt.execute(parameterValues: [
                    pg(progress.userId.uuidString),
                    pg(progress.streakDays),
                    pg(progress.lastCompletedDate),
                    pg(progress.weeklyCompletionsPG),
                    pg(progress.totalCompletions)
                ].compactMap { $0 })

                print("UserProgress synced thành công!")
            } catch {
                print("UserProgress sync error: \(error)")
            }
        }

    // MARK: - Friend Requests
    func saveFriendRequest(_ request: FriendRequestModel) {
        let context = container.mainContext
        context.insert(request)
        do {
            try context.save()
            print("✅ Friend request saved to SwiftData")
        } catch {
            print("❌ Error saving friend request: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO friend_requests (id, sender_id, receiver_id, status, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6)
                ON CONFLICT (id) DO UPDATE
                SET status = $3, updated_at = $6
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(request.id),
                pgg(request.senderId),
                pgg(request.receiverId),
                pgg(request.status),
                pgg(request.createdAt),
                pgg(request.updatedAt)
            ])
            print("✅ Friend request synced to PostgreSQL")
        } catch {
            print("❌ Error syncing friend request: \(error)")
        }
    }
    
    // MARK: - Friendships
    func saveFriendship(_ friendship: FriendshipModel) {
        let context = container.mainContext
        context.insert(friendship)
        do {
            try context.save()
            print("✅ Friendship saved to SwiftData")
        } catch {
            print("❌ Error saving friendship: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO friendships (id, user_id1, user_id2, created_at)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (id) DO NOTHING
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(friendship.id),
                pgg(friendship.userId1),
                pgg(friendship.userId2),
                pgg(friendship.createdAt)
            ])
            print("✅ Friendship synced to PostgreSQL")
        } catch {
            print("❌ Error syncing friendship: \(error)")
        }
    }

    func deleteFriendship(_ friendship: FriendshipModel) {
        let context = container.mainContext
        context.delete(friendship)
        do {
            try context.save()
            print("✅ Friendship deleted from SwiftData")
        } catch {
            print("❌ Error deleting friendship: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM friendships WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(friendship.id)])
            print("✅ Friendship deleted from PostgreSQL")
        } catch {
            print("❌ Error deleting friendship from PostgreSQL: \(error)")
        }
    }

    // MARK: - Chats
    func saveChat(_ chat: ChatModel) {
        let context = container.mainContext
        context.insert(chat)
        do {
            try context.save()
            print("✅ Chat saved to SwiftData")
        } catch {
            print("❌ Error saving chat: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO chats (id, participant1_id, participant2_id, created_at, updated_at,
                                 last_message_content, last_message_time, is_blocked, blocked_by,
                                 custom_nickname1, custom_nickname2, theme_color, quick_reaction_emoji, background_name)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                ON CONFLICT (id) DO UPDATE
                SET last_message_content = $6, last_message_time = $7, is_blocked = $8,
                    blocked_by = $9, custom_nickname1 = $10, custom_nickname2 = $11,
                    theme_color = $12, quick_reaction_emoji = $13, background_name = $14, updated_at = $5
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(chat.id),
                pgg(chat.participant1Id),
                pgg(chat.participant2Id),
                pgg(chat.createdAt),
                pgg(chat.updatedAt),
                pgg(chat.lastMessageContent),
                pgg(chat.lastMessageTime),
                pgg(chat.isBlocked),
                pgg(chat.blockedBy),
                pgg(chat.customNickname1),
                pgg(chat.customNickname2),
                pgg(chat.themeColor),
                pgg(chat.quickReactionEmoji),
                pgg(chat.backgroundName)
            ])
            print("✅ Chat synced to PostgreSQL")
        } catch {
            print("❌ Error syncing chat: \(error)")
        }
    }

    func deleteChat(_ chat: ChatModel) {
        let context = container.mainContext
        context.delete(chat)
        do {
            try context.save()
            print("✅ Chat deleted from SwiftData")
        } catch {
            print("❌ Error deleting chat: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM chats WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(chat.id)])
            print("✅ Chat deleted from PostgreSQL")
        } catch {
            print("❌ Error deleting chat from PostgreSQL: \(error)")
        }
    }

    // MARK: - Messages
    func saveMessage(_ message: MessageModel) {
        let context = container.mainContext
        context.insert(message)
        do {
            try context.save()
            print("✅ Message saved to SwiftData")
        } catch {
            print("❌ Error saving message: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO messages (id, chat_id, sender_id, content, message_type, reactions,
                                    created_at, is_read, reply_to_message_id)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                ON CONFLICT (id) DO UPDATE
                SET is_read = $8, reactions = $6
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(message.id),
                pgg(message.chatId),
                pgg(message.senderId),
                pgg(message.content),
                pgg(message.messageType),
                pgg(message.reactions),
                pgg(message.createdAt),
                pgg(message.isRead),
                pgg(message.replyToMessageId)
            ])
            print("✅ Message synced to PostgreSQL")
        } catch {
            print("❌ Error syncing message: \(error)")
        }
    }

    // MARK: - Groups
    func saveGroup(_ group: GroupModel) {
        let context = container.mainContext
        context.insert(group)
        do {
            try context.save()
            print("✅ Group saved to SwiftData")
        } catch {
            print("❌ Error saving group: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO groups (id, title, avatar, created_at, updated_at, created_by,
                                  last_message_content, last_message_time)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (id) DO UPDATE
                SET title = $2, avatar = $3, last_message_content = $7,
                    last_message_time = $8, updated_at = $5
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(group.id),
                pgg(group.title),
                pgg(group.avatar),
                pgg(group.createdAt),
                pgg(group.updatedAt),
                pgg(group.createdBy),
                pgg(group.lastMessageContent),
                pgg(group.lastMessageTime)
            ])
            print("✅ Group synced to PostgreSQL")
        } catch {
            print("❌ Error syncing group: \(error)")
        }
    }

    func deleteGroup(_ group: GroupModel) {
        let context = container.mainContext
        context.delete(group)
        do {
            try context.save()
            print("✅ Group deleted from SwiftData")
        } catch {
            print("❌ Error deleting group: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM groups WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(group.id)])
            print("✅ Group deleted from PostgreSQL")
        } catch {
            print("❌ Error deleting group from PostgreSQL: \(error)")
        }
    }

    // MARK: - Group Members
    func saveGroupMember(_ member: GroupMemberModel) {
        let context = container.mainContext
        context.insert(member)
        do {
            try context.save()
            print("✅ Group member saved to SwiftData")
        } catch {
            print("❌ Error saving group member: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO group_members (id, group_id, user_id, role, joined_at)
                VALUES ($1, $2, $3, $4, $5)
                ON CONFLICT (id) DO UPDATE
                SET role = $4
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(member.id),
                pgg(member.groupId),
                pgg(member.userId),
                pgg(member.role),
                pgg(member.joinedAt)
            ])
            print("✅ Group member synced to PostgreSQL")
        } catch {
            print("❌ Error syncing group member: \(error)")
        }
    }

    // MARK: - Group Messages
    func saveGroupMessage(_ message: GroupMessageModel) {
        let context = container.mainContext
        context.insert(message)
        do {
            try context.save()
            print("✅ Group message saved to SwiftData")
        } catch {
            print("❌ Error saving group message: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO group_messages (id, group_id, sender_id, content, message_type,
                                          reactions, created_at, reply_to_message_id)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (id) DO UPDATE
                SET reactions = $6
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(message.id),
                pgg(message.groupId),
                pgg(message.senderId),
                pgg(message.content),
                pgg(message.messageType),
                pgg(message.reactions),
                pgg(message.createdAt),
                pgg(message.replyToMessageId)
            ])
            print("✅ Group message synced to PostgreSQL")
        } catch {
            print("❌ Error syncing group message: \(error)")
        }
    }

    // MARK: - Group Word Filters
    func saveGroupWordFilter(_ filter: GroupWordFilterModel) {
        let context = container.mainContext
        context.insert(filter)
        do {
            try context.save()
            print("✅ Word filter saved to SwiftData")
        } catch {
            print("❌ Error saving word filter: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO group_word_filters (id, group_id, banned_word, replacement, created_at)
                VALUES ($1, $2, $3, $4, $5)
                ON CONFLICT (id) DO UPDATE
                SET banned_word = $3, replacement = $4
            """)
            defer { statement.close() }
            
            try statement.execute(parameterValues: [
                pgg(filter.id),
                pgg(filter.groupId),
                pgg(filter.bannedWord),
                pgg(filter.replacement),
                pgg(filter.createdAt)
            ])
            print("✅ Word filter synced to PostgreSQL")
        } catch {
            print("❌ Error syncing word filter: \(error)")
        }
    }

    func deleteGroupWordFilter(_ filter: GroupWordFilterModel) {
        let context = container.mainContext
        context.delete(filter)
        do {
            try context.save()
            print("✅ Word filter deleted from SwiftData")
        } catch {
            print("❌ Error deleting word filter: \(error)")
        }
        
        guard let connection = try? DatabaseConfig.createConnection() else { return }
        defer { connection.close() }
        
        do {
            let statement = try connection.prepareStatement(text: "DELETE FROM group_word_filters WHERE id = $1")
            defer { statement.close() }
            try statement.execute(parameterValues: [pg(filter.id)])
            print("✅ Word filter deleted from PostgreSQL")
        } catch {
            print("❌ Error deleting word filter from PostgreSQL: \(error)")
        }
    }
        
    // MARK: - Helper Function
    private func pgg(_ value: Any?) -> PostgresValueConvertible? {
        guard let value = value else { return nil }
        
        if let uuid = value as? UUID {
            return uuid.uuidString
        } else if let string = value as? String {
            return string
        } else if let int = value as? Int {
            return int
        } else if let bool = value as? Bool {
            return bool
        } else if let date = value as? Date {
            return ISO8601DateFormatter().string(from: date)
        } else if let data = value as? Data {
            return PostgresByteA(data: data)
        } else if let array = value as? [String] {
            let escaped = array.map { "\"\($0.replacingOccurrences(of: "\"", with: "\\\""))\"" }
            return "{\(escaped.joined(separator: ","))}"
        }
        
        print("⚠️ Unsupported type for pgg(): \(type(of: value))")
        return nil
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

    private func pg(_ value: Any?) -> PostgresValueConvertible? {
        switch value {
        case let v as String:
            if v.hasPrefix("{") && v.hasSuffix("}") {
                return v
            }
            return v
        case let v as Int:
            return v
        case let v as Int64:
            return Int(v)
        case let v as Bool:
            return v
        case let v as UUID:
            return v.uuidString
        case let v as Data:
            return PostgresByteA(data: v)
        case let v as Date:
            return PostgresTimestamp(date: v, in: .gmt)
        case let v as [String]:
            guard !v.isEmpty else { return "{}" }
            let escaped = v.map { value in
                "\"" + value.replacingOccurrences(of: "\"", with: "\\\"") + "\""
            }
            return "{" + escaped.joined(separator: ",") + "}"
        case let v as [Data]:
            let encoded = v.map { PostgresByteA(data: $0).description }
            return encoded.isEmpty ? "{}" : "{\(encoded.joined(separator: ","))}"
        case nil:
            return nil
        default:
            print("Unsupported type for pg(): \(type(of: value))")
            return nil
        }
    }
        
    private func pgArray(_ array: [String]) -> String {
        guard !array.isEmpty else { return "{}" }
        let escaped = array.map { component in
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            return "\"\(trimmed.replacingOccurrences(of: "\"", with: "\\\""))\""
        }
        return "{\(escaped.joined(separator: ","))}"
    }
    
    private func parseTextArray(_ rawString: String) -> [String] {
        var cleanString = rawString.trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
        
        cleanString = cleanString.replacingOccurrences(of: "\\\"", with: "\"")
        
        guard !cleanString.isEmpty else { return [] }
        
        let components = cleanString.components(separatedBy: ",")
        
        let result = components.compactMap { component -> String? in
            let trimmed = component
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            return trimmed.isEmpty ? nil : trimmed
        }
        return result
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

extension SwiftDataService {
    static let shared = SwiftDataService()
}
