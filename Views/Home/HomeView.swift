//
//  HomeView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI
import FirebaseAuth


struct HomeView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        TabView {
            // Tab 1: Home
            VStack {
                if let username = viewModel.username {
                    Text("Xin chào, \(username)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                } else {
                    Text("Chào mừng đến với Cosmos Explorer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 50)
                }

                Text("Khám phá vũ trụ bao la!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 20)

                Spacer()

                Button(action: {
                    viewModel.signOut()
                }) {
                    Text("Đăng xuất")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.black, .purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .tabItem {
                Label("Trang chủ", systemImage: "house.fill")
            }
            .onAppear {
                if viewModel.username == nil, let user = Auth.auth().currentUser {
                    viewModel.fetchUsername(userId: user.uid)
                }
            }

            // Các tab khác (placeholder)
            Text("Hệ Mặt Trời (Sẽ thêm sau)")
                .tabItem {
                    Label("Hệ Mặt Trời", systemImage: "sun.max.fill")
                }

            Text("Vũ trụ (Sẽ thêm sau)")
                .tabItem {
                    Label("Vũ trụ", systemImage: "star.fill")
                }

            Text("Chòm sao (Sẽ thêm sau)")
                .tabItem {
                    Label("Chòm sao", systemImage: "sparkles")
                }

            Text("Tin tức (Sẽ thêm sau)")
                .tabItem {
                    Label("Tin tức", systemImage: "newspaper.fill")
                }
        }
        .accentColor(.white)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
