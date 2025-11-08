//
//  HomeEducationView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 11/10/25.
//

import SwiftUI
import SwiftData

struct HomeEducationView: View {
    @StateObject private var viewModel: HomeEducationViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedBannerIndex = 0
    @State private var showMenu = false
    @State private var showUserMenu = false
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation

    init(authViewModel: AuthViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: HomeEducationViewModel(authViewModel: authViewModel))
    }
    
    private let bannerItems = [
        NavItem(id: UUID(), title: LanguageManager.current.string("Flashcards"), icon: "rectangle.stack.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Learn"), icon: "book.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Test"), icon: "pencil.and.list.clipboard"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Blocks"), icon: "cube.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Blast"), icon: "bolt.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Match"), icon: "puzzlepiece.fill")
    ]
    
    private let backgroundImages = [
        "Flashcards_background", "Learn_background", "Test_background",
        "Blocks_background", "Blast_background", "Match_background"
    ]
    
    private let gridItemsLeft = [
        LanguageManager.current.string("Flashcards"),
        LanguageManager.current.string("Learn"),
        LanguageManager.current.string("Test")
    ]
    
    private let gridItemsRight = [
        LanguageManager.current.string("Blocks"),
        LanguageManager.current.string("Blast"),
        LanguageManager.current.string("Match")
    ]
    
    private let gridBackgroundImagesLeft = [
        "Flashcards_background",
        "Learn_background",
        "Test_background"
    ]

    private let gridBackgroundImagesRight = [
        "Blocks_background",
        "Blast_background",
        "Match_background"
    ]
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Bar: Hamburger, Welcome Text, Avatar
                        HStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Text(LanguageManager.current.string("Welcome back") + ", \(viewModel.userName)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .offset(y: 1)
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showUserMenu.toggle()
                                }
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                ZStack {
                                    if showUserMenu {
                                        VStack(spacing: 8) {
                                            NavigationLink(destination: ProfileView().environmentObject(authViewModel)) {
                                                HStack {
                                                    Image(systemName: "person.fill")
                                                        .foregroundColor(.white)
                                                    Text(LanguageManager.current.string("Profile"))
                                                        .foregroundColor(.white)
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .padding(6)
                                                .frame(width: 120)
                                                .background(Color.purple.opacity(0.6))
                                                .cornerRadius(25)
                                            }
                                            NavigationLink(destination: HomeView().navigationBarBackButtonHidden(true)) {
                                                HStack {
                                                    Image(systemName: "book.fill")
                                                        .foregroundColor(.white)
                                                    Text(LanguageManager.current.string("Cosmos"))
                                                        .foregroundColor(.white)
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .padding(6)
                                                .frame(width: 120)
                                                .background(Color.green.opacity(0.6))
                                                .cornerRadius(25)
                                            }
                                            Button(action: {
                                                authViewModel.signOut()
                                                withAnimation {
                                                    showUserMenu = false
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "arrow.right.circle.fill")
                                                        .foregroundColor(.white)
                                                    Text(LanguageManager.current.string("Logout"))
                                                        .foregroundColor(.white)
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .padding(6)
                                                .frame(width: 120)
                                                .background(Color.red.opacity(0.6))
                                                .cornerRadius(25)
                                            }
                                        }
                                        .padding(8)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(25)
                                        .shadow(radius: 5)
                                        .offset(x: -100, y: 40)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 15)
                        .padding(.top)
                        .zIndex(1)
                        
                        // App Title & Underline
                        VStack(alignment: .leading) {
                            Text(LanguageManager.current.string("Cosmos Education"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "title", in: animation)
                                .offset(x: -50)
                                .offset(y: -15)
                            
                            Rectangle()
                                .frame(width: 130, height: 1.5)
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "underline", in: animation)
                                .offset(x: -50)
                                .offset(y: -35)
                            
                            Text(viewModel.randomCosmosQuote)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .italic()
                                .padding(.top, 4)
                                .offset(x: -50)
                                .offset(y: -35)
                        }
                        .padding(.leading, 15)
                        .padding(.vertical)
                        
                        // Banner with Arrows
                        ZStack {
                            TabView(selection: $selectedBannerIndex) {
                                ForEach(0..<bannerItems.count, id: \.self) { index in
                                    NavigationLink(destination: destinationForBanner(at: index)) {
                                        ZStack {
                                            Image(backgroundImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 200)
                                                .clipped()
                                                .cornerRadius(25)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 25)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                )
                                            Text(bannerItems[index].title)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.black.opacity(0.2))
                                                .cornerRadius(25)
                                                .padding(.bottom, 20)
                                        }
                                        .tag(index)
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal, 16)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .animation(.easeInOut, value: selectedBannerIndex)
                            .offset(y: -30)
                            
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedBannerIndex = max(0, selectedBannerIndex - 1)
                                    }
                                }) {
                                    Image(systemName: "arrow.left.circle.fill")
                                        .font(.title)
                                        .foregroundColor(Color.white.opacity(0.3))
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        selectedBannerIndex = min(bannerItems.count - 1, selectedBannerIndex + 1)
                                    }
                                }) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title)
                                        .foregroundColor(Color.white.opacity(0.3))
                                }
                            }
                            .padding(.horizontal, 20)
                            .offset(y: -35)
                        }
                        .onReceive(timer) { _ in
                            withAnimation {
                                selectedBannerIndex = (selectedBannerIndex + 1) % bannerItems.count
                            }
                        }
                        
                        // Cosmos is Now Section
                        HStack {
                            Text(LanguageManager.current.string("Cosmos is Now"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text(viewModel.currentDate)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 18)
                        .offset(y: -20)
                        .zIndex(1)
                        
                        // Grid Section
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 100, maximum: 200)),
                            GridItem(.flexible(minimum: 100, maximum: 200))
                        ], spacing: 10) {
                            ForEach(0..<gridItemsLeft.count, id: \.self) { index in
                                Group {
                                    // Left Column
                                    if gridItemsLeft[index] == LanguageManager.current.string("Flashcards") {
                                        NavigationLink(destination: viewForMode("Flashcards")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesLeft[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsLeft[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "left_\(gridItemsLeft[index])", in: animation)
                                        }
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Learn") {
                                        NavigationLink(destination: viewForMode("Learn")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesLeft[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsLeft[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "left_\(gridItemsLeft[index])", in: animation)
                                        }
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Test") {
                                        NavigationLink(destination: viewForMode("Test")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesLeft[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsLeft[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "left_\(gridItemsLeft[index])", in: animation)
                                        }
                                    }
                                    
                                    // Right Column
                                    if gridItemsRight[index] == LanguageManager.current.string("Blocks") {
                                        NavigationLink(destination: viewForMode("Blocks")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesRight[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsRight[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "right_\(gridItemsRight[index])", in: animation)
                                        }
                                    } else if gridItemsRight[index] == LanguageManager.current.string("Blast") {
                                        NavigationLink(destination: viewForMode("Blast")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesRight[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsRight[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "right_\(gridItemsRight[index])", in: animation)
                                        }
                                    } else if gridItemsRight[index] == LanguageManager.current.string("Match") {
                                        NavigationLink(destination: viewForMode("Match")) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image(gridBackgroundImagesRight[index])
                                                    .resizable()
                                                    .frame(height: 115)
                                                    .clipped()
                                                    .cornerRadius(25)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.2)
                                                    )
                                                Text(gridItemsRight[index])
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.black.opacity(0.5))
                                                    .cornerRadius(25)
                                                    .padding([.leading, .bottom], 10)
                                            }
                                            .padding(8)
                                            .matchedGeometryEffect(id: "right_\(gridItemsRight[index])", in: animation)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .offset(y: -40)
                        
                        // Learn Streaks Section
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text(LanguageManager.current.string("Learn Streaks") + " - \(viewModel.streakDays) days")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 15)
                            .offset(y: -40)
                            
                            HStack(spacing: 8) {
                                ForEach(0..<7) { index in
                                    ZStack {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray.opacity(0.3))
                                        if viewModel.isDayCompleted(index: index) {
                                            Circle()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.green)
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .offset(y: -40)
                        }
                        
                        // Charts Section
                        VStack(alignment: .leading) {
                            Text(LanguageManager.current.string("Charts"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.leading, 15)
                                .offset(y: -40)
                            
                            HStack {
                                Image("cosmos_background")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading) {
                                    Text(LanguageManager.current.string("Your Learning Progress"))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Sep 11/2025")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal, 15)
                            .offset(y: -40)
                        }
                        Spacer(minLength: 100)
                    }
                }
                .background(
                    Image("BlackBG")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                
                // Bottom Navigation Bar
                VStack {
                    Spacer()
                    HStack {
                        ForEach(viewModel.navItems) { item in
                            NavigationLink(destination: destinationView(for: item)) {
                                VStack {
                                    Image(systemName: item.icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                        .matchedGeometryEffect(id: item.id, in: animation)
                                    if viewModel.selectedNavItem == item.id {
                                        Text(item.title)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .transition(.opacity)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded {
                                withAnimation {
                                    viewModel.selectedNavItem = item.id
                                }
                            })
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                // Hamburger Menu
                if showMenu {
                    HamburgerMenuView(isPresented: $showMenu)
                        .environmentObject(authViewModel)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .scale(scale: 0.98, anchor: .leading)).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .scale(scale: 0.98, anchor: .leading)).combined(with: .opacity)
                            )
                        )
                        .zIndex(2)
                }
            }
            .onTapGesture {
                withAnimation {
                    showUserMenu = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: NavItem) -> some View {
        switch item.title {
        case LanguageManager.current.string("Home"):
            EmptyView()
        case LanguageManager.current.string("Quest"):
            EmptyView()
        case LanguageManager.current.string("Ranks"):
            EmptyView()
        case LanguageManager.current.string("Feed"):
            EmptyView()
        case LanguageManager.current.string("Settings"):
            SettingsView()
                .navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Profile"):
            ProfileView()
                .environmentObject(authViewModel)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func viewForMode(_ mode: String) -> some View {
        switch mode {
        case "Flashcards":
            FlashcardsCatalogView()
                .navigationBarBackButtonHidden(true)
        case "Learn":
            LearnCatalogView()
                .navigationBarBackButtonHidden(true)
        case "Test":
            TestCatalogView()
                .navigationBarBackButtonHidden(true)
        case "Blocks":
            BlocksCatalogView()
                .navigationBarBackButtonHidden(true)
        case "Blast":
            BlastCatalogView()
                .navigationBarBackButtonHidden(true)
        case "Match":
            MatchCatalogView()
                .navigationBarBackButtonHidden(true)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func destinationForBanner(at index: Int) -> some View {
        let title = bannerItems[index].title
        let mode = title
        viewForMode(mode)
    }
}

// MARK: - ViewModel
@MainActor
class HomeEducationViewModel: ObservableObject {
    @Published var userName: String = "User"
    @Published var randomCosmosQuote: String = ""
    @Published var selectedNavItem: UUID?
    @Published var streakDays: Int = 7
    
    let service = SwiftDataService()
    
    var currentUserId: UUID {
        if let context = authViewModel?.modelContext,
           let user = try? context.fetch(FetchDescriptor<UserModel>()).first {
            return user.id
        }
        return UUID()
    }
    
    private var authViewModel: AuthViewModel?
    
    let navItems: [NavItem] = [
        NavItem(id: UUID(), title: LanguageManager.current.string("Home"), icon: "house.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Quest"), icon: "sparkles.rectangle.stack.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Ranks"), icon: "books.vertical.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Feed"), icon: "book.pages.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Settings"), icon: "gearshape.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Profile"), icon: "person.fill")
    ]
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
    
    private let cosmosQuotes = [
        LanguageManager.current.string("Love Cosmos"),
        LanguageManager.current.string("The stars are calling"),
        LanguageManager.current.string("Discover the mysteries"),
        LanguageManager.current.string("Falling Star")
    ]
    
    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
        self.userName = authViewModel?.username ?? "User"
        self.randomCosmosQuote = cosmosQuotes.randomElement() ?? "Explore the universe!"
    }
    
    func isDayCompleted(index: Int) -> Bool {
        let today = Calendar.current.component(.weekday, from: Date()) - 2
        return index == today
    }
    
    func demoQuiz(for mode: String) -> Quiz {
        return Quiz(
            title: "Demo \(mode)",
            quizDescription: "This is a demo quiz for \(mode) mode.",
            isPublic: true,
            createdBy: nil,
            categories: [mode]
        )
    }
}

struct HomeEducationView_Previews: PreviewProvider {
    static var previews: some View {
        HomeEducationView()
            .environmentObject(AuthViewModel())
    }
}
