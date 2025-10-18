//
//  AndromedaView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 16/10/25.
//

import SwiftUI
import WebKit
import UIKit

struct AndromedaView: View {
    let galaxy: GalaxyModel
    @ObservedObject var viewModel: GalaxyViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = "Overview"
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]
    
    private let infoItems: [String] = [
        LanguageManager.current.string("Andromeda Random Info 1"),
        LanguageManager.current.string("Andromeda Random Info 2"),
        LanguageManager.current.string("Andromeda Random Info 3"),
        LanguageManager.current.string("Andromeda Random Info 4"),
        LanguageManager.current.string("Andromeda Random Info 5")
    ]
    
    init(galaxy: GalaxyModel, viewModel: GalaxyViewModel) {
        self.galaxy = galaxy
        self._isFavorite = State(initialValue: galaxy.isFavorite)
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(LanguageManager.current.string(selectedTab)) Galaxy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == "Wiki" {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Andromeda_Galaxy"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                galaxy.isFavorite = isFavorite
                                viewModel.toggleFavorite(galaxy: galaxy)
                            }
                        }
                    }) {
                        Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabBarAndromedaView(selectedTab: $selectedTab)
                
                // Nội dung tab
                VStack {
                    if selectedTab == "Overview" {
                        OverviewAndromedaView(
                            galaxy: galaxy,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == "Information" {
                        InformationAndromedaView(
                            galaxy: galaxy,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == "Galleries" {
                        GalleriesAndromedaView(animation: animation)
                    } else if selectedTab == "Comment" {
                        CommentAndromedaView()
                    } else if selectedTab == "Wiki" {
                        VStack {
                            Text(LanguageManager.current.string("Wikipedia: Andromeda Galaxy"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Andromeda_Galaxy")!)
                                .frame(maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom))
                        }
                    } else {
                        Text(LanguageManager.current.string("Content for tab coming soon").replacingOccurrences(of: "{tab}", with: selectedTab))
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: selectedTab)
                .animation(.easeInOut(duration: 1.0), value: glowIntensity)
                .animation(.easeInOut(duration: 1.0), value: randomInfo)
                
                Spacer()
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .background(Image("Andromeda_background").resizable().scaledToFill().ignoresSafeArea())
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(galaxy: galaxy)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func updateRandomInfo() {
        randomInfo = infoItems.randomElement() ?? ""
    }
}

struct TabBarAndromedaView: View {
    @Binding var selectedTab: String
    let tabsLine1 = [
        LanguageManager.current.string("Overview"),
        LanguageManager.current.string("Information"),
        LanguageManager.current.string("Galleries")
    ]
    let tabsLine2 = [
        LanguageManager.current.string("Comment"),
        LanguageManager.current.string("Wiki")
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(tabsLine1, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Capsule())
                    }
                }
            }
            HStack(spacing: 8) {
                ForEach(tabsLine2, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

struct OverviewAndromedaView: View {
    let galaxy: GalaxyModel
    @Binding var glowIntensity: Float
    @Binding var randomInfo: String
    let animation: Namespace.ID
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center
    
    var body: some View {
        ZStack {
            Image("Andromeda")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .scaleEffect(scale, anchor: anchorPoint)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(0.5, min(value, 10.0))
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                scale = 1.0
                                anchorPoint = .center
                            }
                        }
                        .simultaneously(with: TapGesture(count: 2).onEnded {
                            withAnimation(.spring()) {
                                scale = 1.0
                                anchorPoint = .center
                            }
                        })
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let location = value.location
                            let imageSize = CGSize(width: 300, height: 300)
                            let normalizedX = location.x / imageSize.width
                            let normalizedY = location.y / imageSize.height
                            anchorPoint = UnitPoint(x: normalizedX, y: normalizedY)
                        }
                )
                .padding()
                .matchedGeometryEffect(id: "andromeda-\(galaxy.id)", in: animation)
            
            VStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -220)
                Text(LanguageManager.current.string("Pinch to Zoom"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -215)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Text(galaxy.name)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .offset(x: 0, y: -100)
        Text(randomInfo)
            .font(.body)
            .foregroundColor(.white.opacity(0.8))
            .padding()
            .transition(.opacity)
            .offset(x: 0, y: -130)
    }
}

struct InformationAndromedaView: View {
    let galaxy: GalaxyModel
    @Binding var glowIntensity: Float
    @Binding var isFavorite: Bool
    @Binding var selectedTab: String
    let animation: Namespace.ID
    let viewModel: GalaxyViewModel
    @State private var scale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("Andromeda_background")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .scaleEffect(scale, anchor: anchorPoint)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = max(0.5, min(value, 10.0))
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    anchorPoint = .center
                                }
                            }
                            .simultaneously(with: TapGesture(count: 2).onEnded {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    anchorPoint = .center
                                }
                            })
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                let imageSize = CGSize(width: geometry.size.width, height: 150)
                                let normalizedX = location.x / imageSize.width
                                let normalizedY = location.y / imageSize.height
                                anchorPoint = UnitPoint(x: normalizedX, y: normalizedY)
                            }
                    )
                    .matchedGeometryEffect(id: "andromeda-\(galaxy.id)", in: animation)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text(LanguageManager.current.string("About"))
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                if selectedTab == "Wiki" {
                                    UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Andromeda_Galaxy"
                                } else {
                                    withAnimation(.spring()) {
                                        isFavorite.toggle()
                                        galaxy.isFavorite = isFavorite
                                        viewModel.toggleFavorite(galaxy: galaxy)
                                    }
                                }
                            }) {
                                Image(systemName: selectedTab == "Wiki" ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(galaxy.aboutDescription.isEmpty ? LanguageManager.current.string("Andromeda About Description") : galaxy.aboutDescription)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .transition(.opacity)
                        
                        Divider()
                            .background(.white)
                        
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text(LanguageManager.current.string("Video"))
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            NavigationLink(destination: VideoListAndromedaView()) {
                                Text(LanguageManager.current.string("See more           "))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .overlay(alignment: .trailing) {
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach([
                                "https://www.youtube.com/embed/udAL48P5NJU",
                                "https://www.youtube.com/embed/TijClV4uHIk"
                            ], id: \.self) { url in
                                if let validURL = URL(string: url) {
                                    WebView(url: validURL)
                                        .frame(height: 120)
                                        .aspectRatio(16/9, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .zIndex(1)
                                } else {
                                    Text("Invalid URL")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow(icon: "circle.fill", color: .orange, text: "\(LanguageManager.current.string("Radius")): \(galaxy.radius.isEmpty ? "Unknown" : galaxy.radius)")
                            infoRow(icon: "sun.max.fill", color: .red, text: "\(LanguageManager.current.string("Distance from Sun")): \(galaxy.distanceFromSun.isEmpty ? "Unknown" : galaxy.distanceFromSun)")
                            infoRow(icon: "hourglass", color: .teal, text: "\(LanguageManager.current.string("Age")): \(galaxy.age.isEmpty ? "Unknown" : galaxy.age)")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(25)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isFavorite)
    }
    
    @ViewBuilder
    private func infoRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .shadow(color: color.opacity(0.6), radius: 4, x: 0, y: 2)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.05))
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
        )
    }
}

struct VideoListAndromedaView: View {
    let videoURLs = [
        "https://www.youtube.com/embed/udAL48P5NJU",
        "https://www.youtube.com/embed/TijClV4uHIk",
        "https://www.youtube.com/embed/cO_zmJWVaY0",
        "https://www.youtube.com/embed/-ybiXR2WCFQ",
        "https://www.youtube.com/embed/Gs8iGuyocCs"
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(videoURLs, id: \.self) { url in
                    if let validURL = URL(string: url) {
                        WebView(url: validURL)
                            .frame(height: 120)
                            .aspectRatio(16/9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Text("Invalid URL")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
        .background(Image("BlackBG").resizable().scaledToFill().ignoresSafeArea())
        .navigationTitle("Videos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleriesAndromedaView: View {
    let animation: Namespace.ID
    let images = ["Andromeda", "Andromeda01", "Andromeda02", "Andromeda03", "Andromeda04", "Andromeda05"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(images, id: \.self) { image in
                        ZStack(alignment: .bottom) {
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .blue.opacity(0.6), radius: 10, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(LinearGradient(
                                            gradient: Gradient(colors: [.blue, .purple, .clear]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ), lineWidth: 2)
                                )
                                .matchedGeometryEffect(id: "gallery-\(image)", in: animation)
                            
                            Text(image)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                )
                        }
                    }
                }
                .padding()
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

struct CommentAndromedaView: View {
    var body: some View {
        Text("Phần Comment đang phát triển...")
            .font(.title2)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    AndromedaView(
        galaxy: GalaxyModel(name: "Andromeda Galaxy", galaxyDescription: "The nearest spiral galaxy.", galaxy_order: 0),
        viewModel: GalaxyViewModel()
    )
}
