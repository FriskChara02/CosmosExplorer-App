//
//  SolarSystemView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/8/25.
//
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct SolarSystemView: View {
    @StateObject private var viewModel = SolarSystemViewModel()
    @State private var isSearchActive = false
    @State private var editingPlanet: PlanetModel? = nil
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
                    Text(LanguageManager.current.string("Solar System"))
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
                        NavigationLink(destination: AddPlanetView(viewModel: viewModel)) {
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
                        ForEach(Array(viewModel.filteredPlanets.enumerated()), id: \.element.id) { index, planet in
                            PlanetCardView(
                                planet: planet,
                                viewModel: viewModel,
                                editingPlanet: $editingPlanet,
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
                            .animation(nil, value: viewModel.filteredPlanets)
                        }
                    }
                    .padding()
                    .offset(x: gridXOffset, y: gridYOffset)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.filteredPlanets)
                }
                .offset(x: 0, y: -45)
                .sheet(item: $editingPlanet) { planet in
                    EditPlanetView(viewModel: viewModel, planet: planet)
                }
            }
            .background(Image("cosmos_background1").resizable().scaledToFill().ignoresSafeArea())
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
                Task {
                    await viewModel.loadPlanets()
                }
            }
        }
    }
}

// PlanetCardView
struct PlanetCardView: View {
    let planet: PlanetModel
    @ObservedObject var viewModel: SolarSystemViewModel
    @Binding var editingPlanet: PlanetModel?
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
    func planetView(for planet: PlanetModel) -> some View {
        switch planet.name {
        case LanguageManager.current.string("Sun"):
            SunView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Mercury"):
            MercuryView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Venus"):
            VenusView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Earth"):
            EarthView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Moon"):
            MoonView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Mars"):
            MarsView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Jupiter"):
            JupiterView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Saturn"):
            SaturnView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Uranus"):
            UranusView(planet: planet, viewModel: viewModel)
        case LanguageManager.current.string("Neptune"):
            NeptuneView(planet: planet, viewModel: viewModel)
        default:
            PlanetView(planet: planet, viewModel: viewModel)
        }
    }
    
    var body: some View {
        NavigationLink(destination: planetView(for: planet)) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(width: 170, height: 180)
                    .shadow(radius: 5)
                VStack {
                    //Số lần xem
                    HStack {
                        VStack {
                            Image(systemName: "eye")
                                .font(.system(size: 8))
                                .foregroundColor(.primary)
                            Text("\(planet.viewCount)")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(viewCountScale)
                        .offset(x: viewCountXOffset, y: viewCountYOffset)
                        Spacer()
                        //Menu 3 chấm
                        Menu {
                            Button(action: {
                                withAnimation(.spring()) {
                                    viewModel.toggleFavorite(planet: planet)
                                }
                            }) {
                                Label(planet.isFavorite ? LanguageManager.current.string("Unfavorite") : LanguageManager.current.string("Favorite"), systemImage: planet.isFavorite ? "heart.fill" : "heart")
                            }
                            
                            if planet.planet_order > 8 {
                                Button(LanguageManager.current.string("Edit")) {
                                    editingPlanet = planet
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .padding(1)
                                .background(Circle().fill(.ultraThinMaterial))
                                .matchedGeometryEffect(id: "menu-\(planet.id)", in: animation)
                        }
                        .scaleEffect(menuScale)
                        .offset(x: menuXOffset, y: menuYOffset)
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 1)
                    // Planets image
                    Group {
                        if let data = planet.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(planet.name.lowercased() == "sun" ? "Sun" : (planet.name.isEmpty ? "UnknownPlanet" : planet.name))
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(width: 100 * imageScale, height: 100 * imageScale)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
                    .offset(x: imageXOffset, y: imageYOffset)
                    // Tên và mô tả
                    VStack(alignment: .leading) {
                        Text(planet.name)
                            .font(.headline)
                        Text(planet.planetDescription)
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

#Preview {
    SolarSystemView()
    .environmentObject(SolarSystemViewModel())
}

