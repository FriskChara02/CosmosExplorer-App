//
//  NewsDetailView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 14/11/25.
//

import SwiftUI

struct NewsDetailView: View {
    let apod: APOD
    @ObservedObject var viewModel: AstronomicalNewsViewModel
    
    @State private var showFullContent = false // False = Tóm tắt - True = Chi tiết
    @State private var showCopied = false
    @State private var aiSummary = ""
    @State private var isLoadingSummary = false
    
    var body: some View {
        ZStack {
            // Background
            Image("BlackBG2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Image
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: apod.url)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(_):
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                    )
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(ProgressView())
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .padding(.horizontal)
                        
                        // Gradient
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 300)
                        .padding(.horizontal)
                        
                        // Title on image
                        VStack(alignment: .leading, spacing: 8) {
                            Text(apod.title)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.subheadline)
                                Text(apod.date)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.blue.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        }
                        .padding(20)
                    }
                    .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Action Buttons Row
                    HStack(spacing: 16) {
                        ActionButton(
                            icon: showCopied ? "checkmark.circle.fill" : "doc.on.clipboard.fill",
                            title: showCopied ? LanguageManager.current.string("copied") : LanguageManager.current.string("copy_link"),
                            color: .blue,
                            isActive: showCopied
                        ) {
                            viewModel.copyLink(apod: apod)
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showCopied = false
                            }
                        }
                        
                        ActionButton(
                            icon: "calendar.badge.plus",
                            title: LanguageManager.current.string("calendar"),
                            color: .purple
                        ) {
                            viewModel.shareToCalendar(apod: apod)
                        }
                    }
                    .padding(.horizontal, 3)
                    
                    // Toggle Buttons: Tóm tắt / Chi tiết
                    HStack(spacing: 12) {
                        ToggleButton(
                            title: LanguageManager.current.string("summary"),
                            isSelected: !showFullContent
                        ) {
                            showFullContent = false
                            if aiSummary.isEmpty && !isLoadingSummary {
                                generateSummary()
                            }
                        }
                        
                        ToggleButton(
                            title: LanguageManager.current.string("detail"),
                            isSelected: showFullContent
                        ) {
                            showFullContent = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Content Area
                    VStack(alignment: .leading, spacing: 16) {
                        if showFullContent {
                            Text(LanguageManager.current.string("full_detail"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(apod.explanation)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        } else {
                            Text(LanguageManager.current.string("summary"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            if isLoadingSummary {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .tint(.blue)
                                    Text(LanguageManager.current.string("generating_summary"))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 20)
                            } else if !aiSummary.isEmpty {
                                Text(aiSummary)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(6)
                            } else {
                                Text(LanguageManager.current.string("no_summary_yet"))
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .italic()
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateSummary()
        }
    }
    
    // Tạo tóm tắt thông minh (giả lập AI summary)
    private func generateSummary() {
        isLoadingSummary = true
        
        // Giả lập gọi API hoặc xử lý local
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            aiSummary = createIntelligentSummary(from: apod.explanation)
            isLoadingSummary = false
        }
    }
    
    // Hàm tạo tóm tắt thông minh
    private func createIntelligentSummary(from text: String) -> String {
        let sentences = text.components(separatedBy: ". ")
        var summary = ""
        let sentenceCount = min(3, sentences.count)
        
        for i in 0..<sentenceCount {
            if i < sentences.count {
                summary += sentences[i]
                if !sentences[i].hasSuffix(".") {
                    summary += "."
                }
                if i < sentenceCount - 1 {
                    summary += " "
                }
            }
        }
        
        if sentences.count > 3 {
            summary += ".."
        }
        
        return summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Action Button Component
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: isActive ? [color, color.opacity(0.7)] : [color.opacity(0.8), color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 3)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Toggle Button Component
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let vm = AstronomicalNewsViewModel()
    return NewsDetailView(
        apod: APOD(
            title: "Sample Space News",
            url: "https://apod.nasa.gov/apod/image/2107/M87_EHT_2021.jpg",
            explanation: "This is a sample explanation of an astronomical phenomenon that would typically be much longer and contain detailed scientific information about the image.",
            date: "2025-11-14"
        ),
        viewModel: vm
    )
}
