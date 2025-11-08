import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedBannerIndex = 0
    @State private var showMenu = false
    @State private var showUserMenu = false
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    init(authViewModel: AuthViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(authViewModel: authViewModel))
    }
    
    private let bannerItems = [
        NavItem(id: UUID(), title: LanguageManager.current.string("Galaxy"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Black Hole"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Nebula"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Map Galaxy"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Solar System"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Planets"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Stars"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Astronomical News"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Constellation"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("12 Zodiac Signs"), icon: ""),
        NavItem(id: UUID(), title: LanguageManager.current.string("Sky Live"), icon: "")
    ]

    private let backgroundImages = [
        "galaxy_background",
        "BlackHole_background",
        "nebula_background",
        "mapgalaxy_background",
        "solarsystem_background",
        "planets_background",
        "Stars_background01",
        "cosmos_background2",
        "constellation_background",
        "zodiac_background",
        "skylive_background"
    ]
    
    private let gridItemsLeft = [
        LanguageManager.current.string("Galaxy"),
        LanguageManager.current.string("Constellation"),
        LanguageManager.current.string("Nebula"),
        LanguageManager.current.string("Stars"),
        LanguageManager.current.string("Black Hole")
    ]
    
    private let gridItemsRight = [
        LanguageManager.current.string("Map Galaxy"),
        LanguageManager.current.string("12 Zodiac Signs"),
        LanguageManager.current.string("Solar System"),
        LanguageManager.current.string("Planets"),
        LanguageManager.current.string("Sky Live")
    ]
    
    private let gridBackgroundImagesLeft = [
        "galaxy_background",
        "constellation_background",
        "nebula_background",
        "Stars_background01",
        "BlackHole_background"
    ]

    private let gridBackgroundImagesRight = [
        "mapgalaxy_background",
        "zodiac_background",
        "solarsystem_background",
        "planets_background",
        "skylive_background"
    ]
    
    // Timer for auto-scrolling banner
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
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
                                        // Menu pop-up
                                        VStack(spacing: 8) {
                                            // Profile
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
                                            
                                            // Education
                                            NavigationLink(destination: WelcomeEducationView().navigationBarBackButtonHidden(true)) {
                                                HStack {
                                                    Image(systemName: "book.fill")
                                                        .foregroundColor(.white)
                                                    Text(LanguageManager.current.string("Education"))
                                                        .foregroundColor(.white)
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .padding(6)
                                                .frame(width: 120)
                                                .background(Color.green.opacity(0.6))
                                                .cornerRadius(25)
                                            }
                                            
                                            // Logout
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
                                        .offset(x: -100, y: 40) // Vị trí menu
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
                            Text(LanguageManager.current.string("Cosmos Explorer"))
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
                                    if gridItemsLeft[index] == LanguageManager.current.string("Galaxy") {
                                        NavigationLink(destination: GalaxyCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Nebula") {
                                        NavigationLink(destination: NebulaCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Stars") {
                                        NavigationLink(destination: StarCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Black Hole") {
                                        NavigationLink(destination: BlackholeCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsLeft[index] == LanguageManager.current.string("Constellation") {
                                        NavigationLink(destination: ConstellationCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else {
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
                                    
                                    // Right Column
                                    if gridItemsRight[index] == LanguageManager.current.string("Solar System") {
                                        NavigationLink(destination: SolarSystemView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsRight[index] == LanguageManager.current.string("Planets") {
                                        NavigationLink(destination: PlanetsCatalogView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsRight[index] == LanguageManager.current.string("Sky Live") {
                                        NavigationLink(destination: SkyLiveListView().navigationBarBackButtonHidden(true)) {
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
                                    } else if gridItemsRight[index] == LanguageManager.current.string("12 Zodiac Signs") {
                                        NavigationLink(destination: ZodiacHomeView().navigationBarBackButtonHidden(true)) {
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
                                    } else {
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
                                        .matchedGeometryEffect(id: gridItemsRight[index], in: animation)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .offset(y: -40)
                        
                        // Astronomical News Section
                        VStack(alignment: .leading) {
                            Text(LanguageManager.current.string("Astronomical News"))
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
                                    Text(LanguageManager.current.string("Latest Space Discovery"))
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
                // Background
                .background(
                    Image("cosmos_background")
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
        case LanguageManager.current.string("Astronomical News"):
            EmptyView()
        case LanguageManager.current.string("Map"):
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
    private func destinationForBanner(at index: Int) -> some View {
        let title = bannerItems[index].title
        switch title {
        case LanguageManager.current.string("Galaxy"):
            GalaxyCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Black Hole"):
            BlackholeCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Nebula"):
            NebulaCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Map Galaxy"):
            EmptyView()
        case LanguageManager.current.string("Solar System"):
            SolarSystemView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Planets"):
            PlanetsCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Stars"):
            StarCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Astronomical News"):
            EmptyView()
        case LanguageManager.current.string("Constellation"):
            ConstellationCatalogView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("12 Zodiac Signs"):
            ZodiacHomeView().navigationBarBackButtonHidden(true)
        case LanguageManager.current.string("Sky Live"):
            SkyLiveListView().navigationBarBackButtonHidden(true)
        default:
            EmptyView()
        }
    }
}

// ViewModel
class HomeViewModel: ObservableObject {
    @Published var userName: String = "User"
    @Published var randomCosmosQuote: String = ""
    @Published var selectedNavItem: UUID?
    
    let navItems: [NavItem] = [
        NavItem(id: UUID(), title: LanguageManager.current.string("Home"), icon: "house.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Astronomical News"), icon: "newspaper.fill"),
        NavItem(id: UUID(), title: LanguageManager.current.string("Map"), icon: "map.fill"),
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
    
    private var authViewModel: AuthViewModel?
    
    init(authViewModel: AuthViewModel? = nil) {
        self.authViewModel = authViewModel
        self.userName = authViewModel?.username ?? "User"
        self.randomCosmosQuote = cosmosQuotes.randomElement() ?? "Explore the universe!"
    }
}

// NavItem Model
struct NavItem: Identifiable {
    let id: UUID
    let title: String
    let icon: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
