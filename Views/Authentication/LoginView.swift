import SwiftUI

enum AuthMode: String {
    case login = "Login"
    case signUp = "Sign Up"
    case forgotPassword = "Forgot Password"
}

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var authMode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showWelcomeView = false
    @Namespace private var animation
    @State private var starOffset: CGFloat = 0
    @State private var circleOffset1 = CGSize.zero
    @State private var circleOffset2 = CGSize.zero
    @State private var meteorOffset = CGSize.zero

    var body: some View {
        NavigationStack {
            ZStack {
                Image("cosmos_background")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        GeometryReader { geometry in
                            ZStack {
                                // Stars background
                                ForEach(0..<40) { _ in
                                    Circle()
                                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                                        .frame(width: CGFloat.random(in: 2...5))
                                        .position(
                                            x: CGFloat.random(in: 0...geometry.size.width),
                                            y: CGFloat.random(in: 0...geometry.size.height)
                                        )
                                        .offset(y: starOffset)
                                        .animation(
                                            Animation.linear(duration: Double.random(in: 20...40)).repeatForever(autoreverses: false),
                                            value: starOffset
                                        )
                                }
                                // Moving circles
                                Circle()
                                    .fill(.white.opacity(0.5))
                                    .frame(width: 5)
                                    .offset(circleOffset1)
                                    .animation(
                                        Animation.linear(duration: 10).repeatForever(autoreverses: false),
                                        value: circleOffset1
                                    )
                                // Snow-like falling circles
                                ForEach(0..<40) { index in
                                    Circle()
                                        .fill(.white.opacity(Double.random(in: 0.3...0.8)))
                                        .frame(width: CGFloat.random(in: 3...7))
                                        .position(
                                            x: CGFloat.random(in: 0...geometry.size.width),
                                            y: -CGFloat.random(in: 0...geometry.size.height)
                                        )
                                        .offset(y: circleOffset2.height)
                                        .animation(
                                            Animation.easeInOut(duration: Double.random(in: 8...15))
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(index) * 0.5),
                                            value: circleOffset2
                                        )
                                }
                                ZStack {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white, .white.opacity(0.2), .clear],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 50, height: 5)
                                        .blur(radius: 3)
                                        .offset(meteorOffset)
                                        .animation(
                                            Animation.linear(duration: 2).repeatForever(autoreverses: false),
                                            value: meteorOffset
                                        )
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                            }
                            .onAppear {
                                // circleOffset1
                                // Để kéo lên cao hơn, thay đổi -geometry.size.height * 1.5
                                // và thay đổi geometry.size.height * 0.5
                                circleOffset1 = CGSize(width: geometry.size.width, height: -geometry.size.height * 1.5)
                                // Snow-like falling circles
                                circleOffset2 = CGSize(width: 0, height: 0)
                                // Meteor movement
                                meteorOffset = CGSize(width: geometry.size.width + 50, height: -50)
                                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                                    circleOffset1 = CGSize(width: -geometry.size.width, height: geometry.size.height * 0.5)
                                }
                                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: false)) {
                                    circleOffset2 = CGSize(width: 0, height: geometry.size.height)
                                }
                                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false).delay(8)) {
                                    meteorOffset = CGSize(width: -geometry.size.width - 50, height: 50)
                                }
                            }
                        }
                    )
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    logoView
                        .padding(.top, 50)

                    HStack {
                        ForEach([AuthMode.login, AuthMode.signUp], id: \.self) { mode in
                            ZStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "globe.asia.australia.fill")
                                        .foregroundColor(mode == .login ? .blue : .red)
                                        .font(.system(size: 20))
                                    Text(LanguageManager.current.string(mode.rawValue))
                                        .font(.title2)
                                        .fontWeight(authMode == mode ? .bold : .regular)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: authMode == mode ? [.white.opacity(0.8), .clear] : [.clear],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ),
                                                    lineWidth: authMode == mode ? 2 : 0
                                                )
                                                .shadow(color: .white.opacity(authMode == mode ? 0.5 : 0), radius: 5)
                                        )
                                        .matchedGeometryEffect(id: "mode_\(mode.rawValue)", in: animation)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                authMode = mode
                                                errorMessage = ""
                                                successMessage = ""
                                                email = ""
                                                password = ""
                                                confirmPassword = ""
                                                username = ""
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)

                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: inputStackHeight)
                        
                        VStack(spacing: 20) {
                            if authMode == .login {
                                LoginFields(email: $email, password: $password, showPassword: $showPassword)
                            } else if authMode == .signUp {
                                RegisterFields(
                                    username: $username,
                                    email: $email,
                                    password: $password,
                                    confirmPassword: $confirmPassword,
                                    showPassword: $showPassword,
                                    showConfirmPassword: $showConfirmPassword
                                )
                            } else {
                                ForgotPasswordFields(email: $email)
                            }
                        }
                        .padding()
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    Button(action: performAction) {
                        Text(LanguageManager.current.string(authMode.rawValue))
                            .font(.headline)
                            .frame(width: 250, height: 50)
                            .background(authMode == .login ? Color.black : authMode == .signUp ? Color.green : Color.red)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 10) {
                        Text("⋆˚☆˖°⋆｡°✮˖ ࣪⊹⋆.˚.𖥔 ݁˖.✦ OR ✩.⋆☾⋆⁺₊✧ִׄ˚ •𖥔 ࣪˖⭑₊⭒*ೃ")
                            .foregroundColor(.white.opacity(0.7))
                            .fontWeight(.bold)
                        HStack(spacing: 20) {
                            Image(systemName: "apple.logo")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                            Image(systemName: "g.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                            Image(systemName: "f.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        }
                    }
                    .padding(.top, 10)

                    if authMode != .forgotPassword {
                        Button(LanguageManager.current.string("Forgot Password Prompt")) {
                            withAnimation(.spring()) {
                                authMode = .forgotPassword
                                errorMessage = ""
                                successMessage = ""
                                email = ""
                            }
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 16))
                    }
                }
                .padding()
                .navigationDestination(isPresented: $showWelcomeView) {
                    WelcomeView()
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                starOffset = 1000
            }
            .ignoresSafeArea(.keyboard)
        }
    }

    private var logoView: some View {
        VStack(spacing: 5) {
            Text("Cosmos Explorer")
                .font(.custom("Audiowide", size: 36))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .white.opacity(0.4), radius: 10, x: 0, y: 0)
                .offset(y: authMode == .login ? sin(Date().timeIntervalSince1970 * 0.5) * 5 : -20)
                .animation(
                    authMode == .login ?
                        .easeInOut(duration: 3.5).repeatForever(autoreverses: true) :
                        .easeInOut(duration: 0.5),
                    value: authMode
                )

            Text(LanguageManager.current.string("Explore the universe"))
                .font(.custom("Audiowide", size: 18))
                .foregroundColor(.white.opacity(0.7))
        }
        .overlay(
            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [.white.opacity(0.1), .clear]), center: .center, startRadius: 0, endRadius: 100))
                    .frame(width: 200, height: 200)
                    .offset(x: -50, y: -100)
            }
        )
    }

    private var inputStackHeight: CGFloat {
        switch authMode {
        case .login:
            return 140
        case .signUp:
            return 260
        case .forgotPassword:
            return 80
        }
    }

    private func performAction() {
        switch authMode {
        case .login:
            viewModel.signIn(email: email, password: password) { result in
                switch result {
                case .success:
                    print("✅ \(LanguageManager.current.string("Login")) thành công")
                    errorMessage = ""
                    showWelcomeView = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        case .signUp:
            if password != confirmPassword {
                errorMessage = LanguageManager.current.string("Passwords do not match")
                return
            }
            viewModel.signUp(email: email, username: username, password: password) { result in
                switch result {
                case .success:
                    print("✅ \(LanguageManager.current.string("Sign Up")) thành công")
                    errorMessage = ""
                    successMessage = LanguageManager.current.string("Sign Up Success")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        case .forgotPassword:
            viewModel.resetPassword(email: email) { result in
                switch result {
                case .success:
                    successMessage = LanguageManager.current.string("Reset email sent")
                    errorMessage = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    successMessage = ""
                }
            }
        }
    }

    struct LoginFields: View {
        @Binding var email: String
        @Binding var password: String
        @Binding var showPassword: Bool

        var body: some View {
            VStack(spacing: 20) {
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
            }
        }
    }

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
                    showPassword: $showConfirmPassword
                )
            }
        }
    }

    struct ForgotPasswordFields: View {
        @Binding var email: String

        var body: some View {
            CustomTextField(
                text: $email,
                placeholder: LanguageManager.current.string("Email"),
                icon: "envelope.fill",
                iconColor: .blue
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
