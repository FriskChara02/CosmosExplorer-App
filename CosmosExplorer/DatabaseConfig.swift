//
//  DatabaseConfig.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 12/9/25.
//

import PostgresClientKit
import Foundation

struct DatabaseConfig {
    static func createConnection() throws -> PostgresClientKit.Connection {
        var configuration = ConnectionConfiguration()
        configuration.host = "localhost"
        configuration.port = 5432
        configuration.database = "CosmosExplorer"
        configuration.user = "postgres"
        configuration.credential = .scramSHA256(password: "123456")
        configuration.ssl = false

        do {
            return try Connection(configuration: configuration)
        } catch {
            print("❌ Database connection error: \(error)")
            throw error
        }
    }
}

