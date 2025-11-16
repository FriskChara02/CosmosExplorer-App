//
//  LogoVideoView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 11/11/25.
//

import SwiftUI
import AVKit
import Combine

// MARK: - FullScreenVideoPlayer (UIViewControllerRepresentable)
struct FullScreenVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    let onFinish: () -> Void
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.view.backgroundColor = .black
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.exitsFullScreenWhenPlaybackEnds = false
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            onFinish()
            return controller
        }
        
        let player = AVPlayer(url: url)
        controller.player = player
        
        // Tắt tiếng
        player.isMuted = true
        
        // Bắt đầu phát
        player.play()
        
        // Lắng nghe khi video kết thúc
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            onFinish()
        }
        
        // Dự phòng: chuyển sau 7 giây dù video có kết thúc hay không
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            onFinish()
        }
        
        // Full màn hình, fill hết (cắt cạnh nếu cần)
        controller.videoGravity = .resizeAspectFill
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Không cần update gì thêm
    }
}

// MARK: - LogoVideoView
struct LogoVideoView: View {
    @State private var isFinished = false
    @EnvironmentObject private var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if !isFinished {
                FullScreenVideoPlayer(videoName: "CosmosExplorerLogo") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isFinished = true
                    }
                }
                .ignoresSafeArea()
                .statusBar(hidden: true) // Ẩn status bar
            } else {
                HomeView()
                    .environmentObject(viewModel)
                    .navigationBarBackButtonHidden(true)
                    .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
struct LogoVideoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoVideoView()
            .environmentObject(AuthViewModel())
    }
}
