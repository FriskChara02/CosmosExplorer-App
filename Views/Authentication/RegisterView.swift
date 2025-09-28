//
//  RegisterView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct RegisterFields: View {
    @Binding var username: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var showPassword: Bool
    @Binding var showConfirmPassword: Bool

    var body: some View {
        VStack(spacing: 20) {
            CustomTextField(
                text: $username,
                placeholder: LanguageManager.current.string("Username"),
                icon: "person.fill",
                iconColor: .green
            )
            CustomTextField(
                text: $email,
                placeholder: LanguageManager.current.string("Email"),
                icon: "envelope.fill",
                iconColor: .blue
            )
            CustomSecureField(
                text: $password,
                placeholder: LanguageManager.current.string("Password"),
                icon: showPassword ? "eye.fill" : "eye.slash.fill",
                iconColor: .purple,
                showPassword: $showPassword
            )
            CustomSecureField(
                text: $confirmPassword,
                placeholder: LanguageManager.current.string("Confirm Password"),
                icon: showConfirmPassword ? "eye.fill" : "eye.slash.fill",
                iconColor: .purple,
                showPassword: $showConfirmPassword,
                trailingIcon: password == confirmPassword && !password.isEmpty ? "checkmark.circle.fill" : nil,
                trailingIconColor: .green
            )
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let iconColor: Color
    var trailingIcon: String?
    var trailingIconColor: Color?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .frame(width: 200, height: 44)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white.opacity(0.7)),
                    alignment: .bottom
                )
            
            if let trailingIcon = trailingIcon, let trailingIconColor = trailingIconColor {
                Image(systemName: trailingIcon)
                    .foregroundColor(trailingIconColor)
                    .frame(width: 24)
            }
        }
        .padding(.horizontal)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let iconColor: Color
    @Binding var showPassword: Bool
    var trailingIcon: String?
    var trailingIconColor: Color?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
                .onTapGesture {
                    showPassword.toggle()
                }
            
            if showPassword {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.7)),
                        alignment: .bottom
                    )
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.7)),
                        alignment: .bottom
                    )
            }
            
            if let trailingIcon = trailingIcon, let trailingIconColor = trailingIconColor {
                Image(systemName: trailingIcon)
                    .foregroundColor(trailingIconColor)
                    .frame(width: 24)
            }
        }
        .padding(.horizontal)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterFields(
            username: .constant(""),
            email: .constant(""),
            password: .constant(""),
            confirmPassword: .constant(""),
            showPassword: .constant(false),
            showConfirmPassword: .constant(false)
        )
    }
}
