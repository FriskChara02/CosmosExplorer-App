//
//  LoginView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Cosmos Explorer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Mật khẩu", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: {
                    viewModel.signIn(email: email, password: password) { result in
                        switch result {
                        case .success:
                            print("✅ Đăng nhập thành công")
                            // Không cần set isSignedIn vì AuthViewModel đã xử lý
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Đăng nhập")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                NavigationLink("Đăng ký", destination: RegisterView())
                NavigationLink("Quên mật khẩu?", destination: ForgotPasswordView())
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [.black, .purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
