//
//  ContentView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 27/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isSignedIn {
                    WelcomeView()
                } else {
                    LoginView()
                }
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserModel.self], inMemory: true)
}
