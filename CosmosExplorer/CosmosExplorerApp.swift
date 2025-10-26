//
//  CosmosExplorerApp.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 27/7/25.
//

import SwiftUI
import SwiftData

@main
struct CosmosExplorerApp: App {
    let swiftDataService = SwiftDataService()
    
    // MARK: - SwiftData ModelContainer
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .modelContainer(for: [UserModel.self])
        .modelContainer(for: [PlanetModel.self])
        .modelContainer(for: [GalaxyModel.self])
        .modelContainer(for: [NebulaModel.self])
        .modelContainer(for: [StarModel.self])
        .modelContainer(for: [BlackholeModel.self])
        .modelContainer(for: [ConstellationModel.self])
        .modelContainer(for: [PlanetsModel.self])
        .modelContainer(swiftDataService.container)
    }
}
