//
//  PlanetsCatalogView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 23/10/25.
//

import SwiftUI

struct PlanetsCatalogView: View {
    @StateObject private var viewModel = PlanetsViewModel()
    @State private var isSearchActive = false
    @State private var editingPlanets: PlanetsModel? = nil
    @State private var hasLoadedPlanets = false
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
                    Text(LanguageManager.current.string("Planets"))
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
                        NavigationLink(destination: AddPlanetsView(viewModel: viewModel)) {
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
                        ForEach(Array(viewModel.filteredPlanets.enumerated()), id: \.element.id) { index, planets in
                            PlanetsCardView(
                                planets: planets,
                                viewModel: viewModel,
                                editingPlanets: $editingPlanets,
                                xOffset: 0,
                                yOffset: -47,
                                imageXOffset: -3,
                                imageYOffset: -50,
                                imageScale: 1.2,
                                viewCountXOffset: -5,
                                viewCountYOffset: 42,
                                menuXOffset: 3,
                                menuYOffset: 42,
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
                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteredPlanets)
                }
                .offset(x: 0, y: -45)
                .sheet(item: $editingPlanets) { planets in
                    EditPlanetsView(viewModel: viewModel, planets: planets)
                }
            }
            .background(Image("Proximab_background01").resizable().scaledToFill().ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .bottom)
            .animation(.easeInOut(duration: 0.3), value: isSearchActive)
            .if(isSearchActive) { view in
                view.searchable(
                    text: $viewModel.searchText,
                    isPresented: $isSearchActive,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: Text(LanguageManager.current.string("Search planets"))
                )
                .foregroundColor(.blue)
                .fontWeight(.bold)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                if !hasLoadedPlanets {
                    Task {
                        await viewModel.loadPlanets()
                        await MainActor.run {
                            hasLoadedPlanets = true
                        }
                    }
                }
            }
        }
    }
    
    struct PlanetsCardView: View {
        let planets: PlanetsModel
        @ObservedObject var viewModel: PlanetsViewModel
        @Binding var editingPlanets: PlanetsModel?
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
        func planetsView(for planets: PlanetsModel) -> some View {
            switch planets.name {
            case LanguageManager.current.string("Proxima b"):
                ProximabView(planets: planets, viewModel: viewModel)
            case LanguageManager.current.string("Kepler-452b"):
                Kepler452bView(planets: planets, viewModel: viewModel)
            case LanguageManager.current.string("55 Cancri e"):
                Cancrie55View(planets: planets, viewModel: viewModel)
            default:
                PlanetsView(planets: planets, viewModel: viewModel)
            }
        }
        var body: some View {
            NavigationLink(destination: planetsView(for: planets)) {
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
                                Text("\(planets.viewCount)")
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
                                        viewModel.toggleFavorite(planets: planets)
                                    }
                                }) {
                                    Label(planets.isFavorite ? LanguageManager.current.string("Unfavorite") : LanguageManager.current.string("Favorite"), systemImage: planets.isFavorite ? "heart.fill" : "heart")
                                }
                                
                                if planets.planets_order > 2 && viewModel.filteredPlanets.contains(where: { $0.id == planets.id }) {
                                    Button(LanguageManager.current.string("Edit")) {
                                        editingPlanets = planets
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .padding(1)
                                    .background(Circle().fill(.ultraThinMaterial))
                                    .matchedGeometryEffect(id: "menu-\(planets.id)", in: animation)
                            }
                            .scaleEffect(menuScale)
                            .offset(x: menuXOffset, y: menuYOffset)
                        }
                        .padding(.horizontal, 2)
                        .padding(.top, 1)
                        // Planets image
                        Group {
                            if let data = planets.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(planets.name.lowercased() == "proxima b" ? "ProximaB" :
                                      planets.name.lowercased() == "kepler-452b" ? "Kepler452B" :
                                      planets.name.lowercased() == "55 cancri e" ? "Cancri55E" :
                                      (planets.name.isEmpty ? "UnknownPlanets" : planets.name))
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 120 * imageScale, height: 120 * imageScale)
                        .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
                        .offset(x: imageXOffset, y: imageYOffset)
                        // Tên và mô tả
                        VStack(alignment: .leading) {
                            Text(planets.name)
                                .font(.headline)
                            Text(planets.planetsDescription)
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
    PlanetsCatalogView()
        .environmentObject(PlanetsViewModel())
}

