//
//  LeoLegendView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/10/25.
//

import SwiftUI

struct LeoLegendView: View {
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
                        Color.red.opacity(0.4),
                        Color.orange.opacity(0.3)
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
                            gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 8)
                
                Button(action: { dismiss() }) {
                    Image("leo_chibi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.red]),
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
                Text(LanguageManager.current.string("leo"))
                    .font(.custom("Audiowide", size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .orange.opacity(0.9)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.6), radius: 10)
                
                HStack(spacing: 4) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(tabs[selectedTab].1)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
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
                            gradient: Gradient(colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            }
        )
        .shadow(color: .yellow.opacity(0.3), radius: 15, y: 5)
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
            .foregroundColor(selectedTab == index ? .yellow : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if selectedTab == index {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "tab", in: animation)
                            .shadow(color: .yellow.opacity(0.5), radius: 8, y: 4)
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
                infoRow(icon: "number", title: LanguageManager.current.string("zodiac_order"), value: LanguageManager.current.string("5th_zodiac"))
                infoRow(icon: "crown", title: LanguageManager.current.string("nature"), value: LanguageManager.current.string("organized"))
                infoRow(icon: "sun.max", title: LanguageManager.current.string("ruling_planet"), value: LanguageManager.current.string("sun"))
            }
            
            infoCard(title: LanguageManager.current.string("time_luck")) {
                infoRow(icon: "calendar", title: LanguageManager.current.string("weekday"), value: LanguageManager.current.string("sunday"))
                infoRow(icon: "number.circle", title: LanguageManager.current.string("lucky_numbers"), value: LanguageManager.current.string("1_4_6"))
            }
            
            infoCard(title: LanguageManager.current.string("astronomy")) {
                infoRow(icon: "cat", title: LanguageManager.current.string("symbol"), value: LanguageManager.current.string("lion"))
                infoRow(icon: "flame", title: LanguageManager.current.string("element"), value: LanguageManager.current.string("fire"))
            }
            
            infoCard(title: LanguageManager.current.string("gemstones")) {
                Text(LanguageManager.current.string("leo_gems"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(nil)
            }
            
            infoCard(title: LanguageManager.current.string("colors_symbols")) {
                infoRow(icon: "paintpalette", title: LanguageManager.current.string("colors"), value: LanguageManager.current.string("red_gold_orange"))
                infoRow(icon: "leaf", title: LanguageManager.current.string("flowers"), value: LanguageManager.current.string("sunflower_marigold"))
            }
            
            infoCard(title: LanguageManager.current.string("body_parts")) {
                infoRow(icon: "heart", title: LanguageManager.current.string("body"), value: LanguageManager.current.string("heart_back"))
                infoRow(icon: "drop", title: LanguageManager.current.string("metal"), value: LanguageManager.current.string("gold"))
            }
            
            infoCard(title: LanguageManager.current.string("health_relations")) {
                infoRow(icon: "heart.circle", title: LanguageManager.current.string("dating_with"), value: LanguageManager.current.string("aries_sagittarius"))
                infoRow(icon: "person.2.circle", title: LanguageManager.current.string("friends_with"), value: LanguageManager.current.string("taurus_scorpio"))
                infoRow(icon: "xmark.seal", title: LanguageManager.current.string("clash_with"), value: LanguageManager.current.string("aquarius"))
            }
        }
    }
    
    // MARK: - Legend Section
    private var legendSection: some View {
        VStack(spacing: 16) {
            legendCard(
                icon: "shield.fill",
                title: LanguageManager.current.string("hercules_nemea"),
                content: LanguageManager.current.string("hercules_nemea_desc")
            )
            
            legendCard(
                icon: "hand.raised.fill",
                title: LanguageManager.current.string("strangle_lion"),
                content: LanguageManager.current.string("strangle_lion_desc")
            )
            
            legendCard(
                icon: "star.fill",
                title: LanguageManager.current.string("eternal_glory"),
                content: LanguageManager.current.string("eternal_glory_desc")
            )
            
            legendCard(
                icon: "cat.fill",
                title: LanguageManager.current.string("symbol_meaning"),
                content: LanguageManager.current.string("lion_symbol")
            )
        }
    }
    
    // MARK: - Personality Section
    private var personalitySection: some View {
        VStack(spacing: 16) {
            traitCard(
                icon: "crown",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("proud_leadership"),
                content: LanguageManager.current.string("proud_leadership_desc")
            )
            
            traitCard(
                icon: "flame",
                gradient: [Color.orange, Color.red],
                title: LanguageManager.current.string("energetic_generous"),
                content: LanguageManager.current.string("energetic_generous_desc")
            )
            
            traitCard(
                icon: "sun.max",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("optimistic_charismatic"),
                content: LanguageManager.current.string("optimistic_charismatic_desc")
            )
            
            traitCard(
                icon: "star",
                gradient: [Color.orange, Color.yellow],
                title: LanguageManager.current.string("ambitious_showy"),
                content: LanguageManager.current.string("ambitious_showy_desc")
            )
            
            traitCard(
                icon: "shield",
                gradient: [Color.red, Color.orange],
                title: LanguageManager.current.string("loyal_protective"),
                content: LanguageManager.current.string("loyal_protective_desc")
            )
            
            traitCard(
                icon: "person.3",
                gradient: [Color.yellow, Color.red],
                title: LanguageManager.current.string("social_love_attention"),
                content: LanguageManager.current.string("social_love_attention_desc")
            )
        }
    }
    
    // MARK: - Love Section
    private var loveSection: some View {
        VStack(spacing: 16) {
            loveCard(
                icon: "flame.fill",
                title: LanguageManager.current.string("passionate_loyal"),
                content: LanguageManager.current.string("passionate_loyal_desc")
            )
            
            loveCard(
                icon: "crown.fill",
                title: LanguageManager.current.string("demands_respect"),
                content: LanguageManager.current.string("demands_respect_desc")
            )
            
            conquestCard()
        }
    }
    
    // MARK: - Career Section
    private var careerSection: some View {
        VStack(spacing: 16) {
            careerCard(
                icon: "crown.fill",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("leadership_roles"),
                content: LanguageManager.current.string("leadership_roles_desc")
            )
            
            careerCard(
                icon: "mic.fill",
                gradient: [Color.orange, Color.red],
                title: LanguageManager.current.string("entertainment_fame"),
                content: LanguageManager.current.string("entertainment_fame_desc")
            )
            
            careerCard(
                icon: "bag.fill",
                gradient: [Color.yellow, Color.red],
                title: LanguageManager.current.string("business_luxury"),
                content: LanguageManager.current.string("business_luxury_desc")
            )
        }
    }
    
    // MARK: - Card Components
    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.yellow)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.orange.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .yellow.opacity(0.3), radius: 10, y: 5)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow.opacity(0.9))
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
                            gradient: Gradient(colors: [.yellow, .orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
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
                            gradient: Gradient(colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
            }
        )
        .shadow(color: .yellow.opacity(0.3), radius: 10, y: 5)
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
                    .foregroundColor(.yellow)
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
                    .fill(Color.black.opacity(0.2))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: gradient.map { $0.opacity(0.5) }), startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: gradient[0].opacity(0.3), radius: 10, y: 5)
    }
    
    private func loveCard(icon: String, title: String, content: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.yellow)
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
                    .fill(Color.black.opacity(0.2))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
            }
        )
        .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
    }
    
    private func conquestCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text(LanguageManager.current.string("conquest"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LanguageManager.current.string("male") + ":")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.yellow.opacity(0.9))
                        Text(LanguageManager.current.string("male_conquest"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Divider().background(Color.yellow.opacity(0.3))
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LanguageManager.current.string("female") + ":")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.orange.opacity(0.9))
                        Text(LanguageManager.current.string("female_conquest"))
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
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.15)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            }
        )
        .shadow(color: .yellow.opacity(0.3), radius: 10, y: 5)
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
                    .foregroundColor(.yellow)
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
                    .fill(Color.black.opacity(0.2))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: gradient.map { $0.opacity(0.5) }), startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: gradient[0].opacity(0.3), radius: 10, y: 5)
    }
}

#Preview {
    NavigationStack {
        LeoLegendView()
    }
}
