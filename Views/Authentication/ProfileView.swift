import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text(LanguageManager.current.string("Profile"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Button(action: {
                viewModel.signOut()
                errorMessage = nil
            }) {
                Text(LanguageManager.current.string("Sign Out"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
