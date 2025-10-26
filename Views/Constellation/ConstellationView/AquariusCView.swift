//
//  AquariusCView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 21/10/25.
//

import SwiftUI
import WebKit
import UIKit
import RealityKit

struct AquariusCView: View {
    let constellation: ConstellationModel
    @ObservedObject var viewModel: ConstellationViewModel
    @State private var glowIntensity: Float = 1.0
    @State private var isFavorite: Bool
    @Namespace private var animation
    @State private var selectedTab: String = LanguageManager.current.string("Overview")
    @State private var randomInfo: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hoverEffect: [String: CGFloat] = [:]
    
    private let infoItems: [String] = [
        LanguageManager.current.string("Aquarius Random Info 1"),
        LanguageManager.current.string("Aquarius Random Info 2"),
        LanguageManager.current.string("Aquarius Random Info 3"),
        LanguageManager.current.string("Aquarius Random Info 4"),
        LanguageManager.current.string("Aquarius Random Info 5")
    ]
    
    init(constellation: ConstellationModel, viewModel: ConstellationViewModel) {
        self.constellation = constellation
        self._isFavorite = State(initialValue: constellation.isFavorite)
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
                    Text("\(LanguageManager.current.string(selectedTab)) Aquarius")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        if selectedTab == LanguageManager.current.string("Wiki") {
                            UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Aquarius_(constellation)"
                        } else {
                            withAnimation(.spring()) {
                                isFavorite.toggle()
                                viewModel.toggleFavorite(constellation: constellation)
                            }
                        }
                    }) {
                        Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                TabBarAquariusView(selectedTab: $selectedTab)
                // Nội dung tab
                VStack {
                    if selectedTab == LanguageManager.current.string("Overview") {
                        OverviewAquariusView(
                            constellation: constellation,
                            glowIntensity: $glowIntensity,
                            randomInfo: $randomInfo,
                            animation: animation
                        )
                    } else if selectedTab == LanguageManager.current.string("Information") {
                        InformationAquariusView(
                            constellation: constellation,
                            glowIntensity: $glowIntensity,
                            isFavorite: $isFavorite,
                            selectedTab: $selectedTab,
                            animation: animation,
                            viewModel: viewModel
                        )
                    } else if selectedTab == LanguageManager.current.string("Galleries") {
                        GalleriesAquariusView(animation: animation)
                    } else if selectedTab == LanguageManager.current.string("Comment") {
                        CommentAquariusView()
                    } else if selectedTab == LanguageManager.current.string("Wiki") {
                        VStack {
                            Text(LanguageManager.current.string("Wikipedia: Aquarius Constellation"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            WebView(url: URL(string: "https://en.wikipedia.org/wiki/Aquarius_(constellation)")!)
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
            .background(Image("BlackBG").resizable().scaledToFill().ignoresSafeArea().overlay(Color.black.opacity(0.4)))
            .animation(.easeInOut(duration: 1.0), value: glowIntensity)
            .onAppear {
                updateRandomInfo()
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut) {
                        updateRandomInfo()
                    }
                }
                viewModel.incrementViewCount(constellation: constellation)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    private func updateRandomInfo() {
        randomInfo = infoItems.randomElement() ?? ""
    }
}

struct TabBarAquariusView: View {
    @Binding var selectedTab: String
    let tabs: [(String, String)] = [
        (LanguageManager.current.string("Overview"), "photo"),
        (LanguageManager.current.string("Information"), "info.circle"),
        (LanguageManager.current.string("Galleries"), "photo.stack"),
        (LanguageManager.current.string("Comment"), "bubble.left"),
        (LanguageManager.current.string("Wiki"), "book")
    ]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.0) { tab, icon in
                Button(action: {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }) {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.top, 4)
    }
}

struct OverviewAquariusView: View {
    let constellation: ConstellationModel
    @Binding var glowIntensity: Float
    @Binding var randomInfo: String
    let animation: Namespace.ID
    
    @ViewBuilder func infoCard(icon: String, color: Color, title: String, value: String) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.15),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                            .blur(radius: 3)
                    )
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.vertical, 2)
        .gesture(
            TapGesture()
                .onEnded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    }
                }
        )
    }
    
    var body: some View {
        ZStack {
            AquariusOverview3D()
                .frame(height: 500)
                .padding()
                .matchedGeometryEffect(id: "aquarius-\(constellation.id)", in: animation)
            
            VStack {
                Image("AquariusSymbol")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -220)
                Text(LanguageManager.current.string("360°"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(x: 0, y: -215)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Text(constellation.name)
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

struct InformationAquariusView: View {
    let constellation: ConstellationModel
    @Binding var glowIntensity: Float
    @Binding var isFavorite: Bool
    @Binding var selectedTab: String
    let animation: Namespace.ID
    let viewModel: ConstellationViewModel
    @State private var isNamedStarsExpanded: Bool = false
    @ViewBuilder func infoCard(icon: String, color: Color, title: String, value: String) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.15),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                            .blur(radius: 3)
                    )
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.vertical, 2)
        .gesture(
            TapGesture()
                .onEnded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    }
                }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                AquariusInformation3D()
                    .frame(height: 150)
                    .matchedGeometryEffect(id: "aquarius-\(constellation.id)", in: animation)
                
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
                                if selectedTab == LanguageManager.current.string("Wiki") {
                                    UIPasteboard.general.string = "https://en.wikipedia.org/wiki/Aquarius_(constellation)"
                                } else {
                                    withAnimation(.spring()) {
                                        isFavorite.toggle()
                                        viewModel.toggleFavorite(constellation: constellation)
                                    }
                                }
                            }) {
                                Image(systemName: selectedTab == LanguageManager.current.string("Wiki") ? "document.on.document" : (isFavorite ? "heart.fill" : "heart"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        Text(constellation.aboutDescription.isEmpty ? LanguageManager.current.string("Aquarius About Description") : constellation.aboutDescription)
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
                            NavigationLink(destination: VideoListAquariusView(videoURLs: constellation.videoURLs)) {
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
                            ForEach(constellation.videoURLs.isEmpty ? [
                                "https://www.youtube.com/embed/ZoVnKt_fvDk",
                                "https://www.youtube.com/embed/zmmu-zM3WI0"
                            ] : constellation.videoURLs, id: \.self) { url in
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
                        VStack(spacing: 12) {
                            infoCard(icon: "star.fill", color: .yellow, title: LanguageManager.current.string("Main Stars"), value: "\(constellation.mainStars)")
                            Button(action: {
                                withAnimation {
                                    isNamedStarsExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(Color.blue.opacity(0.2))
                                                .blur(radius: 3)
                                        )
                                    Text(LanguageManager.current.string("Named Stars"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    HStack {
                                        Text("\(constellation.namedStars.count)")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .foregroundColor(.white)
                                        Image(systemName: isNamedStarsExpanded ? "chevron.up" : "chevron.down")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.vertical, 2)
                            if isNamedStarsExpanded {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(constellation.namedStars, id: \.self) { star in
                                        HStack(spacing: 8) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.yellow)
                                            Text(star)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isFavorite)
    }
}

struct VideoListAquariusView: View {
    let videoURLs: [String]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(videoURLs.isEmpty ? [
                    "https://www.youtube.com/embed/ZoVnKt_fvDk",
                    "https://www.youtube.com/embed/zmmu-zM3WI0",
                    "https://www.youtube.com/embed/b2mUHGJvE_k",
                    "https://www.youtube.com/embed/Phc5U3sfPrQ"
                ] : videoURLs, id: \.self) { url in
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
        .navigationTitle(LanguageManager.current.string("Videos"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleriesAquariusView: View {
    let animation: Namespace.ID
    let images = ["Aquarius", "Aquarius01", "Aquarius02", "Aquarius03", "Aquarius04", "Aquarius05"]
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.1), Color.cyan.opacity(0.4), Color.white.opacity(0.4)]),
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
                                            gradient: Gradient(colors: [.cyan, .white, .clear]),
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

struct CommentAquariusView: View {
    var body: some View {
        Text(LanguageManager.current.string("Comment Under Development"))
            .font(.title2)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    AquariusCView(
        constellation: ConstellationModel(name: "Aquarius", constellationDescription: "The water bearer.", constellation_order: 0, namedStars: ["Sadalmelik", "Sadalsuud", "Albali", "Skat", "Ancha"]),
        viewModel: ConstellationViewModel()
    )
}
