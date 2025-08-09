//
//  ForgotPasswordView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/7/25.
//

import SwiftUI

struct ForgotPasswordFields: View {
    @Binding var email: String

    var body: some View {
        CustomTextField(
            text: $email,
            placeholder: "Email",
            icon: "envelope.fill",
            iconColor: .blue
        )
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordFields(email: .constant(""))
    }
}
