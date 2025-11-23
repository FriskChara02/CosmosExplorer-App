import SwiftUI
import AVFoundation
import Combine
import SwiftData

enum MusicRepeatMode {
    case none, repeatOne, repeatAll, shuffle
}

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    private var timer: AnyCancellable?
    
    @Published var isPlaying: Bool = false
    @Published var currentSongIndex: Int = 0
    @Published var volume: Float = 0.5
    @Published var repeatMode: MusicRepeatMode = .none
    @Published var isShuffle: Bool = false
    
    // Progress
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private let songs: [Song] = [
        Song(title: "Peaceful Galaxy", author: "By BackgroundMusic", duration: "3:33", fileName: "space-galaxy-universe-music-301239-ByBackgroundMusicForVideos"),
        Song(title: "Floating into space", author: "By Giu1978", duration: "14:59", fileName: "floating-into-space-189706-ByGiu1978"),
        Song(title: "Melancholy", author: "By Universfield", duration: "1:17", fileName: "melancholy-background-165921-byUniversfield"),
        Song(title: "Piano Galaxy", author: "By HitsLab", duration: "1:32", fileName: "space-galaxy-universe-music-335733-ByHitsLab")
    ]
    
    private init() {
        setupAudioSession()
        playCurrentSong()
        startTimer()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let player = self.player else { return }
                self.currentTime = player.currentTime
                self.duration = player.duration
            }
    }
    
    func playCurrentSong() {
        let song = songs[currentSongIndex]
        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3") else {
            print("Không tìm thấy file: \(song.fileName).mp3")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.numberOfLoops = repeatMode == .repeatOne ? -1 : 0
            player?.enableRate = true
            let delegate = AudioDelegate(onFinish: { [weak self] in
                self?.handleSongFinished()
            })
            player?.delegate = delegate
            player?.play()
            isPlaying = true
            currentTime = 0
            duration = player?.duration ?? 0
        } catch {
            print("Lỗi phát nhạc: \(error)")
        }
    }
    
    func togglePlayPause() {
        if player?.isPlaying == true {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    func playNext() {
        if isShuffle {
            currentSongIndex = Int.random(in: 0..<songs.count)
        } else {
            currentSongIndex = (currentSongIndex + 1) % songs.count
        }
        playCurrentSong()
    }
    
    func playPrevious() {
        if isShuffle {
            currentSongIndex = Int.random(in: 0..<songs.count)
        } else {
            currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
        }
        playCurrentSong()
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
    }
    
    func setRepeatMode(_ mode: MusicRepeatMode) {
        repeatMode = mode
        player?.numberOfLoops = mode == .repeatOne ? -1 : 0
    }
    
    private func handleSongFinished() {
        if repeatMode == .repeatAll {
            playNext()
        } else if repeatMode != .repeatOne {
            if currentSongIndex < songs.count - 1 {
                playNext()
            } else {
                isPlaying = false
            }
        }
    }
    
    func currentSong() -> Song {
        return songs[currentSongIndex]
    }
    
    func allSongs() -> [Song] {
        return songs
    }
}

class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: () -> Void
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

struct Song {
    let title: String
    let author: String
    let duration: String
    let fileName: String
}

// MARK: - ViewModel
class HamburgerMenuViewModel: ObservableObject {
    @Published var isMusicMenuOpen: Bool = false
    
    private let audioManager = AudioManager.shared
    
    var isMusicPlaying: Bool { audioManager.isPlaying }
    var currentSong: Song { audioManager.currentSong() }
    var musicList: [Song] { audioManager.allSongs() }
    var volume: Float {
        get { audioManager.volume }
        set { audioManager.setVolume(newValue) }
    }
    var currentTime: TimeInterval { audioManager.currentTime }
    var duration: TimeInterval { audioManager.duration }
    
    var musicRepeatMode: MusicRepeatMode {
        get { audioManager.repeatMode }
        set { audioManager.setRepeatMode(newValue) }
    }
    
    func togglePlayPause() { audioManager.togglePlayPause() }
    func playNext() { audioManager.playNext() }
    func playPrevious() { audioManager.playPrevious() }
    func toggleShuffle() { audioManager.isShuffle.toggle() }
    func seek(to time: TimeInterval) { audioManager.seek(to: time) }
}

// MARK: - Hamburger Menu View
struct HamburgerMenuView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HamburgerMenuViewModel()
    @ObservedObject private var audioManager = AudioManager.shared
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            if isPresented {
                HStack {
                    // Menu content
                    VStack(alignment: .leading, spacing: 20) {
                        userSection
                        musicSection
                        cosmosExplorerSection
                        otherSection
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    .frame(width: 300)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                    
                    closeButton
                        .offset(x: -115)
                        .zIndex(2)
                    
                    Spacer()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPresented)
        .onAppear {
            if !AudioManager.shared.isPlaying {
                AudioManager.shared.playCurrentSong()
            }
        }
    }
    
    private var userSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            UserAvatarView(authViewModel: authViewModel)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
            
            NavigationLink(destination: ProfileView().environmentObject(authViewModel)) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cosmos \(authViewModel.username ?? "User")")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("View Profile")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "lasso.badge.sparkles")
                        .foregroundColor(.white.opacity(0.6))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .onAppear {
                authViewModel.loadCurrentUserIfNeeded { _ in }
            }
        }
    }
    
    // MARK: - MUSIC SECTION
    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Player
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewModel.isMusicMenuOpen.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.currentSong.title)
                            .font(.system(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 110, height: 22, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Text(viewModel.currentSong.author)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 110, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Text(" ❀ \(viewModel.currentSong.duration)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 110, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: viewModel.isMusicPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            withAnimation { viewModel.togglePlayPause() }
                        }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Controls
            if viewModel.isMusicMenuOpen {
                VStack(spacing: 18) {
                    // Progress Bar
                    VStack(spacing: 6) {
                        CustomSlider(
                            value: Binding(
                                get: { audioManager.currentTime },
                                set: { audioManager.seek(to: $0) }
                            ),
                            range: 0...max(1, audioManager.duration),
                            onEditingChanged: { _ in }
                        )
                        .frame(height: 20)

                        HStack {
                            Text(formatTime(audioManager.currentTime))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(formatTime(audioManager.duration))
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Volume
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Volume")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(Int(viewModel.volume * 100))%")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .animation(.easeInOut, value: viewModel.volume)
                        }
                        
                        CustomSlider(
                            value: Binding(
                                get: { Double(audioManager.volume) },
                                set: { audioManager.setVolume(Float($0)) }
                            ),
                            range: 0...1,
                            onEditingChanged: { _ in }
                        )
                        .frame(height: 20)
                    }
                    .padding(.horizontal, 4)
                    
                    // Control Buttons
                    HStack(spacing: 20) {
                        controlButton(icon: "shuffle", isActive: AudioManager.shared.isShuffle) { viewModel.toggleShuffle() }
                        controlButton(icon: "backward.fill") { viewModel.playPrevious() }
                        controlButton(icon: "repeat", isActive: viewModel.musicRepeatMode == .repeatAll) {
                            viewModel.musicRepeatMode = viewModel.musicRepeatMode == .repeatAll ? .none : .repeatAll
                        }
                        controlButton(icon: "repeat.1", isActive: viewModel.musicRepeatMode == .repeatOne) {
                            viewModel.musicRepeatMode = viewModel.musicRepeatMode == .repeatOne ? .none : .repeatOne
                        }
                        controlButton(icon: "forward.fill") { viewModel.playNext() }
                    }
                    .font(.title2)
                    
                    musicListSection
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)).combined(with: .offset(y: -10)))
            }
        }
        .padding(.vertical, 8)
    }
    
    private func controlButton(icon: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .green : .white.opacity(0.8))
                .frame(width: 40, height: 44)
                .background(Circle().fill(isActive ? Color.white.opacity(0.15) : Color.clear))
                .overlay(Circle().stroke(isActive ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2))
                .scaleEffect(isActive ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var musicListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Playlist")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 4)
            
            ForEach(viewModel.musicList.indices, id: \.self) { index in
                let song = viewModel.musicList[index]
                let isCurrent = index == AudioManager.shared.currentSongIndex
                
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(isCurrent ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.caption)
                                .foregroundColor(isCurrent ? .green : .white.opacity(0.7))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.subheadline)
                            .foregroundColor(isCurrent ? .white : .white.opacity(0.9))
                            .frame(height: 20)
                        
                        Text("\(song.author) • \(song.duration)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if isCurrent {
                        Image(systemName: "waveform")
                            .foregroundColor(.blue)
                            .font(.title3)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isCurrent)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(isCurrent ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(12)
                .onTapGesture {
                    withAnimation {
                        AudioManager.shared.currentSongIndex = index
                        AudioManager.shared.playCurrentSong()
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Các phần khác
    private var cosmosExplorerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cosmos Explorer")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            NavigationLink(destination: ChatsView().environmentObject(authViewModel).navigationBarBackButtonHidden(true)) {
                menuItem(icon: "message.fill", title: "My Chats")
            }
            
            NavigationLink(destination: FriendsView().environmentObject(authViewModel).navigationBarBackButtonHidden(true)) {
                menuItem(icon: "person.2.fill", title: "Friends")
            }
            
            Divider().background(Color.gray)
        }
    }
    
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Other")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            menuItem(icon: "gearshape.fill", title: "Settings")
            menuItem(icon: "questionmark.circle.fill", title: "Help and Settings")
        }
    }
    
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
    
    // Helper
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
struct HamburgerMenuView_Previews: PreviewProvider {
    static var previews: some View {
        HamburgerMenuView(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

struct CustomSlider: View {
    @Binding var value: TimeInterval
    let range: ClosedRange<TimeInterval>
    let onEditingChanged: (Bool) -> Void
    
    @State private var isDragging = false
    @State private var thumbSize: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track nền
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 6)
                
                // Progress track
                Capsule()
                    .fill(Color.blue)
                    .frame(width: progressWidth(in: geometry), height: 6)
                
                // Thumb tùy chỉnh
                Image(systemName: "moon.stars")
                    .font(.system(size: thumbSize - 8))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: thumbSize + 1, height: thumbSize + 1)
                    )
                    .offset(x: thumbOffset(in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let newValue = valueFrom(drag.location.x, in: geometry)
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                                onEditingChanged(true)
                            }
                            .onEnded { _ in
                                onEditingChanged(false)
                            }
                    )
            }
            .frame(height: thumbSize)
            .drawingGroup()
        }
        .frame(height: thumbSize)
    }
    
    private func progressWidth(in geometry: GeometryProxy) -> CGFloat {
        let total = range.upperBound - range.lowerBound
        let progress = total > 0 ? (value - range.lowerBound) / total : 0
        return geometry.size.width * progress
    }
    
    private func thumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let total = range.upperBound - range.lowerBound
        let progress = total > 0 ? (value - range.lowerBound) / total : 0
        let offset = geometry.size.width * progress - thumbSize / 2
        return max(0, min(offset, geometry.size.width - thumbSize))
    }
    
    private func valueFrom(_ x: CGFloat, in geometry: GeometryProxy) -> TimeInterval {
        let percent = x / geometry.size.width
        return range.lowerBound + percent * (range.upperBound - range.lowerBound)
    }
}
