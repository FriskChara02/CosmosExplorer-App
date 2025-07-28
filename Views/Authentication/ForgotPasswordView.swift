//
//  ForgotPasswordView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Quên mật khẩu")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
            }

            Button(action: {
                viewModel.resetPassword(email: email) { result in
                    switch result {
                    case .success:
                        successMessage = "Email khôi phục đã được gửi!"
                        errorMessage = ""
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        successMessage = ""
                    }
                }
            }) {
                Text("Gửi email khôi phục")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            NavigationLink("Quay lại đăng nhập", destination: LoginView())
        }
        .padding()
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
