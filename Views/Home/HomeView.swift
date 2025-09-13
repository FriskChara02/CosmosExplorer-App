import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedBannerIndex = 0
    @State private var showMenu = false
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(authViewModel: nil))
    }
    
    private let bannerItems = [
        "Map Galaxy", "Solar System", "Planets", "Stars", "Universe",
        "Galaxy", "Cosmos", "Nebula", "Astronomical News", "Constellation",
        "12 Zodiac Signs", "Sky Live"
    ]
    
    private let backgroundImages = [
        "cosmos_background", "cosmos_background1", "cosmos_background2",
        "cosmos_background", "cosmos_background1", "cosmos_background2",
        "cosmos_background", "cosmos_background1", "cosmos_background2",
        "cosmos_background", "cosmos_background1", "cosmos_background2"
    ]
    
    private let gridItemsLeft = [
        "Cosmos", "Galaxy", "Constellation", "Nebula", "Stars"
    ]
    
    private let gridItemsRight = [
        "Universe", "Map Galaxy", "12 Zodiac Signs", "Solar System", "Planets"
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
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1)) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Text("Welcome back, \(viewModel.userName)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .offset(y: 1)
                            Spacer()
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 15)
                        .padding(.top)
                        .zIndex(1)
                        
                        // App Title & Underline
                        VStack(alignment: .leading) {
                            Text("Cosmos Explorer")
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
                                        Text(bannerItems[index])
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
                        
                        // Cosme is Now Section
                        HStack {
                            Text("Cosme is Now")
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
                                    ZStack(alignment: .bottomLeading) {
                                        Image("cosmos_background")
                                            .resizable()
                                            .scaledToFill()
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
                                    .matchedGeometryEffect(id: gridItemsLeft[index], in: animation)
                                    
                                    // Right Column
                                    if gridItemsRight[index] == "Solar System" {
                                        NavigationLink(destination: SolarSystemView().navigationBarBackButtonHidden(true)) {
                                            ZStack(alignment: .bottomLeading) {
                                                Image("cosmos_background")
                                                    .resizable()
                                                    .scaledToFill()
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
                                    } else {
                                        ZStack(alignment: .bottomLeading) {
                                            Image("cosmos_background")
                                                .resizable()
                                                .scaledToFill()
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
                            Text("Astronomical News")
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
                                    Text("Latest Space Discovery")
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
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.selectedNavItem = item.id
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
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
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: NavItem) -> some View {
        switch item.title {
        case "Home":
            HomeView()
        case "Astronomical News":
            EmptyView()
        case "Map":
            EmptyView()
        case "Settings":
            EmptyView()
        case "Profile":
            ProfileView()
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
        NavItem(id: UUID(), title: "Home", icon: "house.fill"),
        NavItem(id: UUID(), title: "Astronomical News", icon: "newspaper.fill"),
        NavItem(id: UUID(), title: "Map", icon: "map.fill"),
        NavItem(id: UUID(), title: "Settings", icon: "gearshape.fill"),
        NavItem(id: UUID(), title: "Profile", icon: "person.fill")
    ]
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
    
    private let cosmosQuotes = [
        "Love Cosmos.",
        "The stars are calling, let's answer.",
        "Discover the mysteries of the cosmos.",
        "Falling Star♪"
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
