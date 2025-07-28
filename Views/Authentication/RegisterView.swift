//
//  RegisterView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Tạo tài khoản")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Tên người dùng", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Mật khẩu", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Xác nhận mật khẩu", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                if password != confirmPassword {
                    errorMessage = "Mật khẩu và xác nhận mật khẩu không khớp"
                    return
                }
                
                viewModel.signUp(email: email, password: password, username: username) { result in
                    switch result {
                    case .success:
                        print("✅ Đăng ký thành công")
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Đăng ký")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            NavigationLink("Đã có tài khoản? Đăng nhập", destination: LoginView())
        }
        .padding()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
