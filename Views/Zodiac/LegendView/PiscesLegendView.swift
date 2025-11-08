//
//  PiscesLegendView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/10/25.
//

import SwiftUI

struct PiscesLegendView: View {
    @State private var selectedTab = 0
    @State private var headerOffset: CGFloat = 0
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    
    let tabs = [
        (
            LanguageManager.current.string("tab_profile"),
            LanguageManager.current.string("tab_profile_subtitle"),
            "person.crop.circle"
        ),
        (
            LanguageManager.current.string("tab_legend"),
            LanguageManager.current.string("tab_legend_subtitle"),
            "star.fill"
        ),
        (
            LanguageManager.current.string("tab_personality"),
            LanguageManager.current.string("tab_personality_subtitle"),
            "brain.head.profile"
        ),
        (
            LanguageManager.current.string("tab_love"),
            LanguageManager.current.string("tab_love_subtitle"),
            "heart.fill"
        ),
        (
            LanguageManager.current.string("tab_career"),
            LanguageManager.current.string("tab_career_subtitle"),
            "briefcase.fill"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .offset(y: max(-headerOffset, 0))
                .zIndex(100)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 40)
                    tabBarView
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    contentContainer
                }
                .background(GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                headerOffset = value
            }
        }
        .background(
            ZStack {
                Image("BlackBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.7),
                        Color.purple.opacity(0.3),
                        Color.blue.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        )
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 8)
                
                Button(action: { dismiss() }) {
                    Image("pisces_chibi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(LanguageManager.current.string("pisces"))
                    .font(.custom("Audiowide", size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 10)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(tabs[selectedTab].1)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.purple.opacity(0.9))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                Color.black.opacity(0.4)
                BlurView(style: .systemUltraThinMaterialDark)
                    .opacity(0.8)
            }
            .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
        )
    }
    
    // MARK: - Tab Bar
    private var tabBarView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(0..<3) { i in
                    tabButton(index: i)
                }
            }
            HStack(spacing: 8) {
                ForEach(3..<tabs.count, id: \.self) { i in
                    tabButton(index: i)
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
    }
    
    private func tabButton(index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: tabs[index].2)
                    .font(.system(size: 20, weight: .semibold))
                Text(LanguageManager.current.string("tab_\(index)"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "tab", in: animation)
                            .shadow(color: .purple.opacity(0.5), radius: 8, y: 4)
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Content Container
    private var contentContainer: some View {
        VStack(alignment: .leading, spacing: 20) {
            contentView(for: selectedTab)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    // MARK: - Content Views
    @ViewBuilder
    private func contentView(for index: Int) -> some View {
        switch index {
        case 0: profileSection
        case 1: legendSection
        case 2: personalitySection
        case 3: loveSection
        case 4: careerSection
        default: EmptyView()
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 12) {
            infoCard(title: LanguageManager.current.string("basic_info")) {
                infoRow(icon: "number", title: LanguageManager.current.string("zodiac_order"), value: LanguageManager.current.string("12th_zodiac"))
                infoRow(icon: "person.2", title: LanguageManager.current.string("nature"), value: LanguageManager.current.string("inconstant_changeable"))
                infoRow(icon: "calendar", title: LanguageManager.current.string("weekday"), value: LanguageManager.current.string("tuesday"))
                infoRow(icon: "drop", title: LanguageManager.current.string("element"), value: LanguageManager.current.string("water"))
            }
            
            infoCard(title: LanguageManager.current.string("astronomy")) {
                infoRow(icon: "star.circle", title: LanguageManager.current.string("ruling_planet"), value: LanguageManager.current.string("neptune_jupiter"))
                infoRow(icon: "globe.asia.australia", title: LanguageManager.current.string("planet"), value: LanguageManager.current.string("neptune_dreams"))
                infoRow(icon: "fish", title: LanguageManager.current.string("symbol"), value: LanguageManager.current.string("two_fish"))
            }
            
            infoCard(title: LanguageManager.current.string("gemstones")) {
                Text(LanguageManager.current.string("pisces_gems"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(nil)
            }
            
            infoCard(title: LanguageManager.current.string("colors_symbols")) {
                infoRow(icon: "paintpalette", title: LanguageManager.current.string("colors"), value: LanguageManager.current.string("purple_gray_blue"))
                infoRow(icon: "leaf", title: LanguageManager.current.string("flowers"), value: LanguageManager.current.string("lotus_iris_camellia"))
                infoRow(icon: "cube", title: LanguageManager.current.string("metal"), value: LanguageManager.current.string("tin"))
                infoRow(icon: "pawprint", title: LanguageManager.current.string("animals"), value: LanguageManager.current.string("elephant_dolphin_dog"))
            }
            
            infoCard(title: LanguageManager.current.string("health_relations")) {
                infoRow(icon: "heart.text.square", title: LanguageManager.current.string("body_parts"), value: LanguageManager.current.string("feet"))
                infoRow(icon: "heart.circle", title: LanguageManager.current.string("dating_with"), value: LanguageManager.current.string("cancer_scorpio"))
                infoRow(icon: "person.2.circle", title: LanguageManager.current.string("friends_with"), value: LanguageManager.current.string("gemini_sagittarius"))
                infoRow(icon: "checkmark.seal", title: LanguageManager.current.string("compatible_with"), value: LanguageManager.current.string("cancer_scorpio_pisces"))
                infoRow(icon: "xmark.seal", title: LanguageManager.current.string("clash_with"), value: LanguageManager.current.string("virgo"))
            }
            
            infoCard(title: LanguageManager.current.string("time_luck")) {
                infoRow(icon: "number.circle", title: LanguageManager.current.string("lucky_numbers"), value: LanguageManager.current.string("1_3_4_9"))
            }
        }
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        VStack(spacing: 16) {
            legendCard(
                icon: "figure.2.and.child.holdinghands",
                title: LanguageManager.current.string("greek_myth"),
                content: LanguageManager.current.string("aphrodite_eros_typhon")
            )
            
            legendCard(
                icon: "fish.fill",
                title: LanguageManager.current.string("symbol_meaning"),
                content: LanguageManager.current.string("two_fish_connected")
            )
        }
    }
    
    // MARK: - Personality Section
    private var personalitySection: some View {
        VStack(spacing: 16) {
            traitCard(
                icon: "brain",
                gradient: [Color.purple, Color.blue],
                title: LanguageManager.current.string("mysterious_dual"),
                content: LanguageManager.current.string("mysterious_dual_desc")
            )
            
            traitCard(
                icon: "eye",
                gradient: [Color.blue, Color.cyan],
                title: LanguageManager.current.string("intuitive_artistic"),
                content: LanguageManager.current.string("intuitive_artistic_desc")
            )
            
            traitCard(
                icon: "heart.circle.fill",
                gradient: [Color.pink, Color.purple],
                title: LanguageManager.current.string("kind_sensitive"),
                content: LanguageManager.current.string("kind_sensitive_desc")
            )
            
            traitCard(
                icon: "cloud.rain",
                gradient: [Color.gray, Color.blue],
                title: LanguageManager.current.string("dreamy_escapist"),
                content: LanguageManager.current.string("dreamy_escapist_desc")
            )
            
            traitCard(
                icon: "person.3.fill",
                gradient: [Color.teal, Color.green],
                title: LanguageManager.current.string("sociable_open"),
                content: LanguageManager.current.string("sociable_open_desc")
            )
            
            traitCard(
                icon: "lightbulb.fill",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("imaginative_lazy"),
                content: LanguageManager.current.string("imaginative_lazy_desc")
            )
        }
    }
    
    // MARK: - Love Section
    private var loveSection: some View {
        VStack(spacing: 16) {
            loveCard(
                icon: "heart.fill",
                title: LanguageManager.current.string("romantic_love"),
                content: LanguageManager.current.string("romantic_love_desc")
            )
            
            loveCard(
                icon: "house.fill",
                title: LanguageManager.current.string("family"),
                content: LanguageManager.current.string("family_desc")
            )
            
            conquestCard()
        }
    }
    
    // MARK: - Career Section
    private var careerSection: some View {
        VStack(spacing: 16) {
            careerCard(
                icon: "lightbulb.fill",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("creative_career"),
                content: LanguageManager.current.string("creative_career_desc")
            )
            
            careerCard(
                icon: "briefcase.fill",
                gradient: [Color.blue, Color.purple],
                title: LanguageManager.current.string("work"),
                content: LanguageManager.current.string("work_desc")
            )
            
            careerCard(
                icon: "dollarsign.circle.fill",
                gradient: [Color.green, Color.teal],
                title: LanguageManager.current.string("finance"),
                content: LanguageManager.current.string("finance_desc")
            )
        }
    }
    
    // MARK: - Card Components
    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.purple)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.purple.opacity(0.8))
                .frame(width: 24)
            Text(title + ":")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.95))
                .lineLimit(nil)
            Spacer(minLength: 0)
        }
    }
    
    private func legendCard(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            }
        )
        .shadow(color: .blue.opacity(0.2), radius: 10, y: 5)
    }
    
    private func traitCard(icon: String, gradient: [Color], title: String, content: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: gradient.map { $0.opacity(0.4) }), startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: gradient[0].opacity(0.2), radius: 10, y: 5)
    }
    
    private func loveCard(icon: String, title: String, content: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.pink.opacity(0.4), lineWidth: 1)
            }
        )
        .shadow(color: .pink.opacity(0.2), radius: 10, y: 5)
    }
    
    private func conquestCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.pink, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text(LanguageManager.current.string("conquest"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LanguageManager.current.string("male") + ":")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue.opacity(0.9))
                        Text(LanguageManager.current.string("male_conquest_pisces"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Divider().background(Color.white.opacity(0.2))
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.pink)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LanguageManager.current.string("female") + ":")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.pink.opacity(0.9))
                        Text(LanguageManager.current.string("female_conquest_pisces"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.pink.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            }
        )
        .shadow(color: .purple.opacity(0.2), radius: 10, y: 5)
    }
    
    private func careerCard(icon: String, gradient: [Color], title: String, content: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: gradient.map { $0.opacity(0.4) }), startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: gradient[0].opacity(0.2), radius: 10, y: 5)
    }
}

#Preview {
    NavigationStack {
        PiscesLegendView()
    }
}
