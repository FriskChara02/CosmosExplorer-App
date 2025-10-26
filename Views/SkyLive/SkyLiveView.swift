//
//  SkyLiveView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI
import RealityKit

struct SkyLiveView: View {
    let planetName: String
    @ObservedObject var viewModel: SkyLiveViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM. yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            // Gradient Background based on planet
            backgroundGradient(for: planetName)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        withAnimation(.easeInOut) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.backward.circle.fill")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.system(size: 24, weight: .medium))
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.3)).blur(radius: 10))
                            .scaleEffect(1.0)
                            .animation(.spring(), value: 1.0)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(LanguageManager.current.string(planetName))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                        Text(currentDate)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                        .font(.system(size: 24))
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Main Content
                if viewModel.isLoading {
                    ProgressView(LanguageManager.current.string("Loading Data"))
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.2)
                        .padding(.top, 60)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // 3D Planet View
                            VStack {
                                planetView(for: planetName)
                                    .frame(height: 320)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.05))
                                            .blur(radius: 20)
                                            .shadow(radius: 10)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                    )
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 1.5), value: 1.0)
                                
                                if planetName == "Earth" {
                                    Text(LanguageManager.current.string("You Are Living Here"))
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.top, 8)
                                }
                            }
                            .padding(.top, 20)
                            
                            if let planetInfo = viewModel.planetData[planetName] {
                                // Basic Info Section
                                infoSection(title: LanguageManager.current.string("Basic Information"), content: {
                                    VStack(spacing: 12) {
                                        infoRow(title: "\(LanguageManager.current.string("Altitude")):", value: planetInfo.altitude, color: .white)
                                        infoRow(title: "\(LanguageManager.current.string("Rise")):", value: "↑ \(planetInfo.rise)", color: .green)
                                        infoRow(title: "\(LanguageManager.current.string("Transit")):", value: "ᯓ \(planetInfo.transit)", color: .yellow)
                                        infoRow(title: "\(LanguageManager.current.string("Set")):", value: "↓ \(planetInfo.set)", color: .orange)
                                        if let orbitalSpeed = planetInfo.orbitalSpeed {
                                            infoRow(title: "\(LanguageManager.current.string("Orbital Speed")):", value: orbitalSpeed, color: .cyan)
                                        }
                                        if let current = planetInfo.currentTime {
                                            infoRow(title: "\(LanguageManager.current.string("Current Time")):", value: current, color: .white)
                                        }
                                    }
                                })
                                
                                // Sun
                                if planetName == "Sun" {
                                    infoSection(title: LanguageManager.current.string("Sun"), content: {
                                        VStack(spacing: 12) {
                                            if let dayLength = planetInfo.dayLength {
                                                infoRow(title: "\(LanguageManager.current.string("Day Length")):", value: dayLength, color: .yellow)
                                            }
                                            if let nightLength = planetInfo.nightLength {
                                                infoRow(title: "\(LanguageManager.current.string("Night Length")):", value: nightLength, color: .blue)
                                            }
                                            if let seasons = planetInfo.seasons {
                                                ForEach(seasons, id: \.self) { season in
                                                    infoRow(title: "\(LanguageManager.current.string("Season")):", value: season, color: .pink)
                                                }
                                            }
                                        }
                                    })
                                }
                                
                                // Moon
                                if planetName == "Moon" {
                                    infoSection(title: LanguageManager.current.string("Moon"), content: {
                                        VStack(spacing: 12) {
                                            if let phase = planetInfo.moonPhase {
                                                infoRow(title: "\(LanguageManager.current.string("Moon Phase")):", value: phase, color: .gray)
                                            }
                                            if let nextPhases = planetInfo.nextMoonPhases {
                                                ForEach(nextPhases, id: \.self) { phase in
                                                    infoRow(title: "\(LanguageManager.current.string("Next Phase")):", value: phase, color: .white)
                                                }
                                            }
                                        }
                                    })
                                }
                                
                                // Astronomical Events
                                infoSection(title: LanguageManager.current.string("Special Astronomical Events"), content: {
                                    if let events = planetInfo.astronomicalEvents, !events.isEmpty {
                                        VStack(spacing: 12) {
                                            ForEach(events, id: \.name) { event in
                                                VStack(alignment: .leading, spacing: 8) {
                                                    HStack {
                                                        Text(event.name)
                                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                                            .foregroundColor(.white)
                                                        Spacer()
                                                    }
                                                    Text("\(LanguageManager.current.string("Date")): \(event.date)")
                                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                                        .foregroundColor(.cyan)
                                                    Text(event.description)
                                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                                        .foregroundColor(.white)
                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.white.opacity(0.1))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                        )
                                                )
                                                .scaleEffect(1.0)
                                                .animation(.easeInOut, value: 1.0)
                                            }
                                        }
                                    } else {
                                        Text(LanguageManager.current.string("No Special Events Today ^^"))
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                    }
                                })
                                
                                // Explanations Section
                                infoSection(title: LanguageManager.current.string("Event Explanations"), content: {
                                    DisclosureGroup {
                                        VStack(spacing: 12) {
                                            explanationRow(title: LanguageManager.current.string("Altitude"), description: LanguageManager.current.string("Altitude Explanation"))
                                            explanationRow(title: LanguageManager.current.string("Rise"), description: LanguageManager.current.string("Rise Explanation"))
                                            explanationRow(title: LanguageManager.current.string("Transit"), description: LanguageManager.current.string("Transit Explanation"))
                                            explanationRow(title: LanguageManager.current.string("Set"), description: LanguageManager.current.string("Set Explanation"))
                                            
                                            if let events = planetInfo.astronomicalEvents, !events.isEmpty {
                                                ForEach(events, id: \.name) { event in
                                                    explanationRow(title: event.name, description: explanation(for: event.name))
                                                }
                                            } else {
                                                Text(LanguageManager.current.string("No Explanations Available"))
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.gray)
                                                    .padding(.vertical, 8)
                                            }
                                        }
                                    } label: {
                                        Label(LanguageManager.current.string("Event Explanations"), systemImage: "questionmark.circle.fill")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal)
                                    .accentColor(.green)
                                })
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    // Gradient background
    func backgroundGradient(for planet: String) -> some View {
        switch planet {
        case "Sun":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.orange.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
        case "Moon":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.3, alpha: 1))]), startPoint: .top, endPoint: .bottom)
        case "Mercury":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
        case "Venus":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.orange.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
        case "Earth":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
        case "Mars":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.red.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
        case "Jupiter":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.brown.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
        case "Saturn":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color(red: 0.9, green: 0.8, blue: 0.6).opacity(0.9)]), startPoint: .top, endPoint: .bottom)
        case "Uranus":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.cyan.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
        case "Neptune":
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    func infoRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.vertical, 2)
    }
    
    func explanationRow(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(description)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    func planetView(for planet: String) -> some View {
        switch planet {
        case "Sun": Sun3DView()
        case "Moon": Moon3DView()
        case "Mercury": Mercury3DView()
        case "Venus": Venus3DView()
        case "Earth": Earth3DView()
        case "Mars": Mars3DView()
        case "Jupiter": Jupiter3DView()
        case "Saturn": Saturn3DView()
        case "Uranus": Uranus3DView()
        case "Neptune": Neptune3DView()
        default: EmptyView()
        }
    }
    
    func explanation(for eventName: String) -> String {
        switch eventName {
        case LanguageManager.current.string("Moon Phase"):
            return LanguageManager.current.string("Moon Phase Explanation")
        case LanguageManager.current.string("Phase Angle"):
            return LanguageManager.current.string("Phase Angle Explanation")
        case LanguageManager.current.string("Illuminated Fraction"):
            return LanguageManager.current.string("Illuminated Fraction Explanation")
        case LanguageManager.current.string("Elongation"):
            return LanguageManager.current.string("Elongation Explanation")
        case LanguageManager.current.string("Opposition"):
            return LanguageManager.current.string("Opposition Explanation")
        default:
            return LanguageManager.current.string("No Explanation Available")
        }
    }
}

#Preview {
    SkyLiveView(planetName: "Moon", viewModel: SkyLiveViewModel())
}
