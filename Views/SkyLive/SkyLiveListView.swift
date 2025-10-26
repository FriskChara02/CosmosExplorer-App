//
//  SkyLiveListView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 26/10/25.
//

import SwiftUI

struct SkyLiveListView: View {
    @ObservedObject var viewModel = SkyLiveViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let planets = [
        ("Sun", "sun.max.fill", Color.yellow),
        ("Moon", "moon.fill", Color.gray),
        ("Mercury", "circle.fill", Color.gray),
        ("Venus", "circle.fill", Color.orange),
        ("Earth", "globe", Color.blue),
        ("Mars", "circle.fill", Color.red),
        ("Jupiter", "circle.fill", Color.brown),
        ("Saturn", "circle.fill", Color(red: 0.9, green: 0.8, blue: 0.6)),
        ("Uranus", "circle.fill", Color.cyan),
        ("Neptune", "circle.fill", Color.blue)
    ]
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.backward.circle")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(LanguageManager.current.string("SkyLive"))
                                .font(.title)
                                .foregroundColor(.white)
                            Text(currentDate)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 10)
                    
                    if viewModel.isLoading {
                        ProgressView(LanguageManager.current.string("LoadingData"))
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .padding(.top, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 25) {
                                ForEach(planets, id: \.0) { planet in
                                    NavigationLink(destination: SkyLiveView(
                                        planetName: planet.0,
                                        viewModel: viewModel
                                    )) {
                                        planetRowView(name: planet.0, icon: planet.1, color: planet.2)
                                            .contentShape(Rectangle())
                                    }
                                }
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .background(Image("BlackBG").resizable().scaledToFill().ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            if viewModel.isLoading {
                viewModel.fetchData()
            }
        }
    }
    
    // MARK: - Planet Row
    func planetRowView(name: String, icon: String, color: Color) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(LanguageManager.current.string(name))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let planetInfo = viewModel.planetData[name] {
                    HStack(spacing: 15) {
                        Text("\(LanguageManager.current.string("Up")) \(planetInfo.rise)")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("\(LanguageManager.current.string("Down")) \(planetInfo.set)")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(planetInfo.altitude)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward.circle")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SkyLiveListView()
}
