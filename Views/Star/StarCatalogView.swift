//
//  StarCatalogView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 17/10/25.
//

import SwiftUI

struct StarCatalogView: View {
    @StateObject private var viewModel = StarViewModel()
    @State private var isSearchActive = false
    @State private var editingStar: StarModel? = nil
    @State private var hasLoadedStars = false
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss

    let dateXOffset: CGFloat
    let dateYOffset: CGFloat
    let gridXOffset: CGFloat
    let gridYOffset: CGFloat
    let gridWidth: CGFloat
    let gridMinHeight: CGFloat
    let gridItemScale: CGFloat
    let gridSpacing: CGFloat

    init(
        dateXOffset: CGFloat = 0,
        dateYOffset: CGFloat = -20,
        gridXOffset: CGFloat = 0,
        gridYOffset: CGFloat = 0,
        gridWidth: CGFloat = 180,
        gridMinHeight: CGFloat = 200,
        gridItemScale: CGFloat = 1.0,
        gridSpacing: CGFloat = 10
    ) {
        self.dateXOffset = dateXOffset
        self.dateYOffset = dateYOffset
        self.gridXOffset = gridXOffset
        self.gridYOffset = gridYOffset
        self.gridWidth = gridWidth
        self.gridMinHeight = gridMinHeight
        self.gridItemScale = gridItemScale
        self.gridSpacing = gridSpacing
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(LanguageManager.current.string("Stars"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSearchActive.toggle()
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "search", in: animation)
                        }
                        NavigationLink(destination: AddStarView(viewModel: viewModel)) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)

                // Ngày tháng
                Text(DateHelper.formatDate(Date()))
                    .font(.subheadline)
                    .offset(x: dateXOffset, y: dateYOffset)
                    .foregroundColor(.white)
                    .padding()

                // Layout 2 cột
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed(gridWidth), spacing: gridSpacing),
                        GridItem(.fixed(gridWidth), spacing: gridSpacing)
                    ], spacing: -40) {
                        ForEach(Array(viewModel.filteredStars.enumerated()), id: \.element.id) { index, star in
                            StarCardView(
                                star: star,
                                viewModel: viewModel,
                                editingStar: $editingStar,
                                xOffset: 0,
                                yOffset: -35,
                                imageXOffset: -3,
                                imageYOffset: -50,
                                imageScale: 1.2,
                                viewCountXOffset: -5,
                                viewCountYOffset: 30,
                                menuXOffset: 3,
                                menuYOffset: 30,
                                viewCountScale: 1.0,
                                menuScale: 1.0
                            )
                            .scaleEffect(gridItemScale)
                            .frame(minHeight: gridMinHeight)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding()
                    .offset(x: gridXOffset, y: gridYOffset)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteredStars)
                }
                .offset(x: 0, y: -45)
                .sheet(item: $editingStar) { star in
                    EditStarView(viewModel: viewModel, star: star)
                }
            }
            .background(Image("Star_background").resizable().scaledToFill().ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .bottom)
            .animation(.easeInOut(duration: 0.3), value: isSearchActive)
            .if(isSearchActive) { view in
                view.searchable(
                    text: $viewModel.searchText,
                    isPresented: $isSearchActive,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: Text(LanguageManager.current.string("Search stars"))
                )
                .foregroundColor(.blue)
                .fontWeight(.bold)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                if !hasLoadedStars {
                    Task {
                        await viewModel.loadStars()
                        await MainActor.run {
                            hasLoadedStars = true
                        }
                    }
                }
            }
        }
    }

    struct StarCardView: View {
        let star: StarModel
        @ObservedObject var viewModel: StarViewModel
        @Binding var editingStar: StarModel?
        let xOffset: CGFloat
        let yOffset: CGFloat
        let imageXOffset: CGFloat
        let imageYOffset: CGFloat
        let imageScale: CGFloat
        let viewCountXOffset: CGFloat
        let viewCountYOffset: CGFloat
        let menuXOffset: CGFloat
        let menuYOffset: CGFloat
        let viewCountScale: CGFloat
        let menuScale: CGFloat
        @Namespace private var animation
        
        @ViewBuilder
        func starView(for star: StarModel) -> some View {
            switch star.name {
            case LanguageManager.current.string("Sirius"):
                SiriusView(star: star, viewModel: viewModel)
            case LanguageManager.current.string("Canopus"):
                CanopusView(star: star, viewModel: viewModel)
            case LanguageManager.current.string("Alpha Centauri"):
                AlphaCentauriView(star: star, viewModel: viewModel)
            default:
                StarView(star: star, viewModel: viewModel)
            }
        }

        var body: some View {
            NavigationLink(destination: starView(for: star)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(width: 170, height: 180)
                        .shadow(radius: 5)

                    VStack {
                        // Số lần xem
                        HStack {
                            VStack {
                                Image(systemName: "eye")
                                    .font(.system(size: 8))
                                    .foregroundColor(.primary)
                                Text("\(star.viewCount)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                            }
                            .scaleEffect(viewCountScale)
                            .offset(x: viewCountXOffset, y: viewCountYOffset)
                            Spacer()
                            // Menu 3 chấm
                            Menu {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        viewModel.toggleFavorite(star: star)
                                    }
                                }) {
                                    Label(star.isFavorite ? LanguageManager.current.string("Unfavorite") : LanguageManager.current.string("Favorite"), systemImage: star.isFavorite ? "heart.fill" : "heart")
                                }
                                
                                if star.star_order > 2 && viewModel.filteredStars.contains(where: { $0.id == star.id }) {
                                    Button(LanguageManager.current.string("Edit")) {
                                        editingStar = star
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .padding(1)
                                    .background(Circle().fill(.ultraThinMaterial))
                                    .matchedGeometryEffect(id: "menu-\(star.id)", in: animation)
                            }
                            .scaleEffect(menuScale)
                            .offset(x: menuXOffset, y: menuYOffset)
                        }
                        .padding(.horizontal, 2)
                        .padding(.top, 1)

                        // Star image
                        Group {
                            if let data = star.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(star.name.lowercased() == "sirius" ? "Sirius":
                                      star.name.lowercased() == "canopus" ? "Canopus":
                                      star.name.lowercased() == "alpha centauri" ? "AlphaCentauri":
                                      "UnknownStar")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 100 * imageScale, height: 100 * imageScale)
                        .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
                        .offset(x: imageXOffset, y: imageYOffset)

                        // Tên và mô tả
                        VStack(alignment: .leading) {
                            Text(star.name)
                                .font(.headline)
                            Text(star.starDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .offset(x: xOffset, y: yOffset)
                        .padding(.bottom, 1)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    StarCatalogView()
        .environmentObject(StarViewModel())
}
