import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var progress: CGFloat = 0
    @State private var showHomeView = false
    @State private var quoteIndex = Int.random(in: 0..<10)

    private let circleRotationDuration: Double = 8

    private let quotes = [
        "Cố gắng lên bạn nhé! Hôm nay bạn vất vả nhiều rồi!.",
        "Vũ trụ đầy những điều bí ẩn.",
        "Không gian mở ra mọi khả năng.",
        "Vũ trụ đầy những điều kỳ diệu.",
        "Nhìn lên trời, mơ những vì sao.",
        "Vũ trụ là một cuốn sách mở.",
        "Mỗi ngôi sao kể một câu chuyện.",
        "Không gian là khởi đầu vĩ đại.",
        "Vũ trụ ẩn chứa vô vàn bí ẩn.",
        "Hi vọng bạn thích thú với vũ trụ."
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TitleView()
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                QuoteView(quote: quotes[quoteIndex])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                Spacer()

                RotatingDottedCircleView(duration: circleRotationDuration)

                Spacer()

                ProgressArrowView(progress: progress)
                    .padding(.bottom, 50)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
            }
            .padding()
            .background(
                ScrollView(.horizontal, showsIndicators: false) {
                    BackgroundView()
                        .frame(width: UIScreen.main.bounds.width * 2.8)
                }
            )
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                    if progress < 100 {
                        progress += 1
                    } else {
                        timer.invalidate()
                    }
                }

                //Chuyển HomeView sau 5s:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showHomeView = true
                }
            }
            .navigationDestination(isPresented: $showHomeView) {
                HomeView()
                    .environmentObject(viewModel)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - Background View
struct BackgroundView: View {
    var body: some View {
        Image("cosmos_background2")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

// MARK: - Title View
struct TitleView: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("COSMOS")
                .font(.custom("Audiowide", size: 36))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .white.opacity(0.4), radius: 10)

            Text("Explorer")
                .font(.custom("Audiowide", size: 36))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Quote View
struct QuoteView: View {
    let quote: String

    var body: some View {
        Text(quote)
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: 300)
    }
}

// MARK: - Rotating Dotted Circle
struct RotatingDottedCircleView: View {
    let duration: Double

    var body: some View {
        TimelineView(.animation) { context in
            let angle = Angle(degrees: context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration * 360)

            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 200, height: 200)

                ForEach(0..<4) { index in
                    let offsetAngle = Double(index) * .pi / 2
                    let totalAngle = offsetAngle + angle.radians
                    let xOffset = CGFloat(100 * cos(totalAngle))
                    let yOffset = CGFloat(100 * sin(totalAngle))

                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 2)
                        )
                        .offset(x: xOffset, y: yOffset)
                }
            }
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Progress Arrow View
struct ProgressArrowView: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.7))
                .frame(width: 100, height: 50)

            HStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 28))
                    .foregroundColor(.white)

                Text("\(Int(progress))%")
                    .font(.custom("Audiowide", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AuthViewModel())
    }
}
