import SwiftUI

// MARK: - ViewModel for Hamburger Menu
class HamburgerMenuViewModel: ObservableObject {
    @Published var isMusicMenuOpen: Bool = false
    @Published var isMusicPlaying: Bool = false
    @Published var musicRepeatMode: MusicRepeatMode = .none
    
    enum MusicRepeatMode {
        case none, repeatOne, repeatAll, shuffle
    }
    
    // Sample user data
    let userName: String = "Cosmos User"
    let currentSong: String = "Stellar Vibes"
    let songDuration: String = "3:45"
    
    // Sample music list
    let musicList: [(title: String, duration: String)] = [
        ("Galactic Journey", "4:12"),
        ("Nebula Dreams", "3:58"),
        ("Starlight Sonata", "5:20"),
        ("Cosmic Waves", "4:45"),
        ("Orbiting Echoes", "3:30")
    ]
}

// MARK: - Hamburger Menu View
struct HamburgerMenuView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = HamburgerMenuViewModel()
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Backdrop
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // Hamburger Menu
            if isPresented {
                HStack {
                    // Menu content
                    VStack(alignment: .leading, spacing: 20) {
                        // User Section
                        userSection
                        
                        // Music Section
                        musicSection
                        
                        // Section 01: Cosmos Explorer
                        cosmosExplorerSection
                        
                        // Section 02: Other
                        otherSection
                        
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    .frame(width: 300)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 25)
                    )
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                    
                    // Close Button (half in, half out)
                    closeButton
                        .offset(x: -115)
                        .zIndex(2)
                    
                    Spacer()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPresented)
    }
    
    // MARK: - User Section
    private var userSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
            
            // User Name and View Profile
            NavigationLink(destination: ProfileView()) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(LanguageManager.current.string("Username"))
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(LanguageManager.current.string("View Profile"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.2))
                )
            }
        }
    }
    
    // MARK: - Music Section
    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    viewModel.isMusicMenuOpen.toggle()
                }
            }) {
                HStack {
                    // Music Image
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(25)
                    
                    // Music Info
                    VStack(alignment: .leading) {
                        Text(LanguageManager.current.string("Current Song"))
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(viewModel.songDuration)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    // Music Toggle
                    Image(systemName: viewModel.isMusicPlaying ? "pause.circle" : "play.circle")
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation {
                                viewModel.isMusicPlaying.toggle()
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.2))
                )
            }
            
            // Music Menu
            if viewModel.isMusicMenuOpen {
                VStack(alignment: .leading, spacing: 10) {
                    musicMenuItem(icon: "repeat", title: LanguageManager.current.string("Repeat All"), mode: .repeatAll)
                    musicMenuItem(icon: "repeat.1", title: LanguageManager.current.string("Repeat One"), mode: .repeatOne)
                    musicMenuItem(icon: "shuffle", title: LanguageManager.current.string("Shuffle"), mode: .shuffle)
                    musicMenuItem(icon: "backward.fill", title: LanguageManager.current.string("Previous Track"), mode: .none)
                    musicMenuItem(icon: "forward.fill", title: LanguageManager.current.string("Next Track"), mode: .none)
                    musicListSection
                }
                .padding(.leading, 10)
                .transition(.opacity.combined(with: .offset(y: 10)))
            }
        }
    }
    
    // MARK: - Music List Section
    private var musicListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LanguageManager.current.string("Music List"))
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(viewModel.musicList, id: \.title) { song in
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text(song.duration)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 5)
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial.opacity(0.8))
        )
    }
    
    // Helper for Music Menu Items
    private func musicMenuItem(icon: String, title: String, mode: HamburgerMenuViewModel.MusicRepeatMode) -> some View {
        Button(action: {
            withAnimation {
                viewModel.musicRepeatMode = mode
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
    
    // MARK: - Cosmos Explorer Section
    private var cosmosExplorerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LanguageManager.current.string("Cosmos Explorer"))
                .font(.caption)
                .foregroundColor(.gray)
            
            menuItem(icon: "message.fill", title: LanguageManager.current.string("My Chats"))
            menuItem(icon: "person.2.fill", title: LanguageManager.current.string("Friends"))
            
            Divider()
                .background(Color.gray)
        }
    }
    
    // MARK: - Other Section
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LanguageManager.current.string("Other"))
                .font(.caption)
                .foregroundColor(.gray)
            
            menuItem(icon: "gearshape.fill", title: LanguageManager.current.string("Settings"))
            menuItem(icon: "questionmark.circle.fill", title: LanguageManager.current.string("Help and Settings"))
        }
    }
    
    // Helper for Menu Items
    private func menuItem(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            
            Text(title)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 5)
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 7)
                        .background(Color.gray.opacity(1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 20)
                        .foregroundColor(.white)
                }
                .offset(x: 20)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            }
            .padding(.top, 60)
            .padding(.trailing, -20)
            Spacer()
        }
    }
}

// MARK: - Preview
struct HamburgerMenuView_Previews: PreviewProvider {
    static var previews: some View {
        HamburgerMenuView(isPresented: .constant(true))
    }
}
