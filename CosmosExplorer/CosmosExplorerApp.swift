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
    
        init() {
            ValueTransformer.registerIfNeeded()
        }
    
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
                .onOpenURL { url in
                    GoogleService.shared.handleURL(url)
            }
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
        .modelContainer(for: [Quiz.self])
        .modelContainer(for: [Card.self])
        .modelContainer(for: [Attempt.self])
        .modelContainer(for: [Favorite.self])
        .modelContainer(for: [UserProgress.self])
        .modelContainer(for: [FriendRequestModel.self])
        .modelContainer(for: [FriendshipModel.self])
        .modelContainer(for: [ChatModel.self])
        .modelContainer(for: [MessageModel.self])
        .modelContainer(for: [GroupModel.self])
        .modelContainer(for: [GroupMemberModel.self])
        .modelContainer(for: [GroupMessageModel.self])
        .modelContainer(for: [GroupWordFilterModel.self])
        .modelContainer(for: [GalaxyComment.self])
        .modelContainer(for: [BlackholeComment.self])
        .modelContainer(for: [StarComment.self])
        .modelContainer(for: [NebulaComment.self])
        .modelContainer(for: [PlanetsComment.self])
        .modelContainer(for: [ConstellationComment.self])
        .modelContainer(for: [PlanetComment.self])
        .modelContainer(swiftDataService.container)
    }
}
