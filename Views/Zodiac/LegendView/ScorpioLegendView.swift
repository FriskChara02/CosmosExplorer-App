//
//  ScorpioLegendView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 29/10/25.
//

import SwiftUI

struct ScorpioLegendView: View {
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
                        Color.purple.opacity(0.3)
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
                            gradient: Gradient(colors: [Color.red.opacity(0.6), Color.pink.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 8)
              
                Button(action: { dismiss() }) {
                    Image("scorpio_chibi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.pink]),
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
                Text(LanguageManager.current.string("scorpio"))
                    .font(.custom("Audiowide", size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .red.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 10)
              
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                  
                    Text(tabs[selectedTab].1)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red.opacity(0.9))
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
                            gradient: Gradient(colors: [Color.red.opacity(0.15), Color.purple.opacity(0.1)]),
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
                                    gradient: Gradient(colors: [Color.red.opacity(0.8), Color.pink.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "tab", in: animation)
                            .shadow(color: .red.opacity(0.5), radius: 8, y: 4)
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
                infoRow(icon: "number", title: LanguageManager.current.string("zodiac_order"), value: LanguageManager.current.string("8th_zodiac"))
                infoRow(icon: "person.2", title: LanguageManager.current.string("other_names"), value: LanguageManager.current.string("scorpion_names"))
                infoRow(icon: "sparkles", title: LanguageManager.current.string("characteristic"), value: LanguageManager.current.string("fixed"))
                infoRow(icon: "figure.wave", title: LanguageManager.current.string("symbol"), value: LanguageManager.current.string("scorpion"))
            }
          
            infoCard(title: LanguageManager.current.string("time_luck")) {
                infoRow(icon: "number.circle", title: LanguageManager.current.string("lucky_numbers"), value: LanguageManager.current.string("2_7_9"))
            }
          
            infoCard(title: LanguageManager.current.string("astronomy")) {
                infoRow(icon: "sparkle", title: LanguageManager.current.string("ruling_planet"), value: LanguageManager.current.string("pluto"))
                infoRow(icon: "wind", title: LanguageManager.current.string("element"), value: LanguageManager.current.string("water"))
            }
          
            infoCard(title: LanguageManager.current.string("gemstones")) {
                Text(LanguageManager.current.string("scorpio_gems"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(nil)
            }
          
            infoCard(title: LanguageManager.current.string("colors_symbols")) {
                infoRow(icon: "paintpalette", title: LanguageManager.current.string("colors"), value: LanguageManager.current.string("red_chestnut"))
                infoRow(icon: "leaf", title: LanguageManager.current.string("metal"), value: LanguageManager.current.string("steel"))
            }
          
            infoCard(title: LanguageManager.current.string("health_relations")) {
                infoRow(icon: "heart.text.square", title: LanguageManager.current.string("body_parts"), value: LanguageManager.current.string("reproductive_organs"))
                infoRow(icon: "heart.circle", title: LanguageManager.current.string("dating_with"), value: LanguageManager.current.string("cancer_pisces"))
                infoRow(icon: "person.2.circle", title: LanguageManager.current.string("friends_with"), value: LanguageManager.current.string("aquarius_leo"))
                infoRow(icon: "xmark.seal", title: LanguageManager.current.string("clash_with"), value: LanguageManager.current.string("taurus"))
            }
        }
    }
  
    // MARK: - Legend Section
    private var legendSection: some View {
        VStack(spacing: 16) {
            legendCard(
                icon: "bolt.fill",
                title: LanguageManager.current.string("greek_myth_orion"),
                content: LanguageManager.current.string("hera_scorpion_orion")
            )
          
            legendCard(
                icon: "drop.fill",
                title: LanguageManager.current.string("phaethon_story"),
                content: LanguageManager.current.string("phaethon_scorpion")
            )
          
            legendCard(
                icon: "pyramid.fill",
                title: LanguageManager.current.string("symbol_meaning"),
                content: LanguageManager.current.string("scorpion_behavior")
            )
        }
    }
  
    // MARK: - Personality Section
    private var personalitySection: some View {
        VStack(spacing: 16) {
            traitCard(
                icon: "brain",
                gradient: [Color.purple, Color.red],
                title: LanguageManager.current.string("strong_will"),
                content: LanguageManager.current.string("strong_will_desc")
            )
          
            traitCard(
                icon: "eye.fill",
                gradient: [Color.red, Color.pink],
                title: LanguageManager.current.string("mysterious_eyes"),
                content: LanguageManager.current.string("mysterious_eyes_desc")
            )
          
            traitCard(
                icon: "flame.fill",
                gradient: [Color.orange, Color.red],
                title: LanguageManager.current.string("passionate_vindictive"),
                content: LanguageManager.current.string("passionate_vindictive_desc")
            )
          
            traitCard(
                icon: "shield.fill",
                gradient: [Color.pink, Color.black],
                title: LanguageManager.current.string("three_levels"),
                content: LanguageManager.current.string("three_levels_desc")
            )
          
            traitCard(
                icon: "lightbulb.fill",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("intuition_thinking"),
                content: LanguageManager.current.string("intuition_thinking_desc")
            )
          
            traitCard(
                icon: "person.3.fill",
                gradient: [Color.red, Color.purple],
                title: LanguageManager.current.string("loyal_protective"),
                content: LanguageManager.current.string("loyal_protective_desc")
            )
        }
    }
  
    // MARK: - Love Section
    private var loveSection: some View {
        VStack(spacing: 16) {
            loveCard(
                icon: "heart.fill",
                title: LanguageManager.current.string("intense_love"),
                content: LanguageManager.current.string("intense_love_desc")
            )
          
            loveCard(
                icon: "house.fill",
                title: LanguageManager.current.string("family"),
                content: LanguageManager.current.string("family_scorpio_desc")
            )
          
            conquestCard()
          
            loveCard(
                icon: "calendar",
                title: LanguageManager.current.string("dating_tips"),
                content: LanguageManager.current.string("dating_tips_desc")
            )
        }
    }
  
    // MARK: - Career Section
    private var careerSection: some View {
        VStack(spacing: 16) {
            careerCard(
                icon: "lightbulb.fill",
                gradient: [Color.yellow, Color.orange],
                title: LanguageManager.current.string("suitable_careers"),
                content: LanguageManager.current.string("suitable_careers_desc")
            )
          
            careerCard(
                icon: "briefcase.fill",
                gradient: [Color.red, Color.purple],
                title: LanguageManager.current.string("work_style"),
                content: LanguageManager.current.string("work_style_desc")
            )
          
            careerCard(
                icon: "dollarsign.circle.fill",
                gradient: [Color.green, Color.red],
                title: LanguageManager.current.string("finance"),
                content: LanguageManager.current.string("finance_scorpio_desc")
            )
        }
    }
  
    // MARK: - Card Components
    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.red)
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
                            gradient: Gradient(colors: [Color.red.opacity(0.3), Color.purple.opacity(0.2)]),
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
                .foregroundColor(.red.opacity(0.8))
                .frame(width: 24)
            Text(title + ":")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 120, alignment: .leading)
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
                            gradient: Gradient(colors: [Color.orange.opacity(0.15), Color.red.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            }
        )
        .shadow(color: .red.opacity(0.2), radius: 10, y: 5)
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
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
            }
        )
        .shadow(color: .red.opacity(0.2), radius: 10, y: 5)
    }
  
    private func conquestCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                        Text(LanguageManager.current.string("male_conquest_scorpio"))
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
                        Text(LanguageManager.current.string("female_conquest_scorpio"))
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
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.red.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
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
        ScorpioLegendView()
    }
}
