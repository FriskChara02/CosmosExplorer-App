//
//  ZodiacRankView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//  Updated UI – 29/10/25
//

import SwiftUI

// MARK: - Rank Category Enum
enum RankCategory: String, CaseIterable, Identifiable {
    case chanh          = "Chanh"
    case daTinh         = "Da Tinh"
    case daiGai         = "Dai Gai"
    case deXom          = "De Xom"
    case dien           = "Dien"
    case faNhieu        = "FA Nhieu"
    case ganDa          = "Gan Da"
    case giaNai         = "Gia Nai"
    case hamHoc         = "Ham Hoc"
    case hatHay         = "Hat Hay"
    case lauCa          = "Lau Ca"
    case luaTinh        = "Lua Tinh"
    case luoiBieng      = "Luoi Bieng"
    case luyTinh        = "Luy Tinh"
    case meChoiGame     = "Me Choi Game"
    case meTrai         = "Me Trai"
    case nghiemTuc      = "Nghiem Tuc"
    case nhatGan        = "Nhat Gan"
    case noiDoi         = "Noi Doi"
    case sangTao        = "Sang Tao"
    case mongMo         = "Mong Mo"
    case soXau          = "So Xau"
    case thanThien      = "Than Thien"
    case thanhThien     = "Thanh Thien"
    case viBanBe        = "Vi Ban Be"
    case voTinh         = "Vo Tinh"
    case nhieuTinhXau   = "Nhieu Tinh Xau Nhat"
    case yeuDoi         = "Yeu Doi"

    var id: String { rawValue }

    var localized: String {
        LanguageManager.current.string("rank_\(rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))")
    }
}

// MARK: - Zodiac Enum
enum Zodiac: String, CaseIterable {
    case aries      = "Aries"
    case taurus     = "Taurus"
    case gemini     = "Gemini"
    case cancer     = "Cancer"
    case leo        = "Leo"
    case virgo      = "Virgo"
    case libra      = "Libra"
    case scorpio    = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn  = "Capricorn"
    case aquarius   = "Aquarius"
    case pisces     = "Pisces"

    var symbolImage: String { "\(rawValue)Zodiac" }
    var localizedName: String { LanguageManager.current.string("zodiac_\(rawValue.lowercased())") }
    var dateRange: String { LanguageManager.current.string("zodiac_\(rawValue.lowercased())_date") }
}

// MARK: - Rank Data (Hardcoded)
private let rankData: [RankCategory: [Zodiac]] = [
    .chanh:          [.leo, .libra, .scorpio, .aries, .taurus, .gemini, .cancer, .virgo, .sagittarius, .capricorn, .aquarius, .pisces],
    .daTinh:         [.libra, .pisces, .cancer, .leo, .scorpio, .gemini, .aries, .taurus, .virgo, .sagittarius, .capricorn, .aquarius],
    .daiGai:         [.pisces, .cancer, .scorpio, .libra, .leo, .gemini, .aries, .taurus, .virgo, .sagittarius, .capricorn, .aquarius],
    .deXom:          [.scorpio, .aries, .leo, .sagittarius, .gemini, .libra, .pisces, .cancer, .taurus, .virgo, .capricorn, .aquarius],
    .dien:           [.gemini, .aquarius, .pisces, .aries, .sagittarius, .leo, .libra, .scorpio, .cancer, .taurus, .virgo, .capricorn],
    .faNhieu:        [.virgo, .capricorn, .taurus, .cancer, .scorpio, .pisces, .libra, .leo, .aries, .gemini, .sagittarius, .aquarius],
    .ganDa:          [.aries, .scorpio, .leo, .sagittarius, .capricorn, .aquarius, .gemini, .libra, .pisces, .cancer, .taurus, .virgo],
    .giaNai:         [.cancer, .pisces, .taurus, .virgo, .capricorn, .libra, .scorpio, .leo, .aries, .gemini, .sagittarius, .aquarius],
    .hamHoc:         [.virgo, .capricorn, .gemini, .aquarius, .sagittarius, .libra, .scorpio, .aries, .leo, .pisces, .cancer, .taurus],
    .hatHay:         [.pisces, .libra, .taurus, .cancer, .leo, .gemini, .scorpio, .aries, .sagittarius, .virgo, .capricorn, .aquarius],
    .lauCa:          [.gemini, .scorpio, .pisces, .libra, .aquarius, .aries, .sagittarius, .leo, .cancer, .taurus, .virgo, .capricorn],
    .luaTinh:        [.scorpio, .gemini, .pisces, .libra, .leo, .aries, .sagittarius, .aquarius, .cancer, .taurus, .virgo, .capricorn],
    .luoiBieng:      [.taurus, .cancer, .pisces, .libra, .capricorn, .virgo, .leo, .scorpio, .aries, .gemini, .sagittarius, .aquarius],
    .luyTinh:        [.pisces, .cancer, .scorpio, .libra, .taurus, .leo, .virgo, .capricorn, .aries, .gemini, .sagittarius, .aquarius],
    .meChoiGame:     [.aquarius, .gemini, .sagittarius, .aries, .pisces, .leo, .libra, .scorpio, .cancer, .taurus, .virgo, .capricorn],
    .meTrai:         [.pisces, .cancer, .libra, .scorpio, .taurus, .leo, .virgo, .capricorn, .aries, .gemini, .sagittarius, .aquarius],
    .nghiemTuc:      [.capricorn, .virgo, .taurus, .scorpio, .cancer, .aries, .leo, .libra, .gemini, .sagittarius, .aquarius, .pisces],
    .nhatGan:        [.pisces, .cancer, .taurus, .libra, .virgo, .capricorn, .leo, .scorpio, .aries, .gemini, .sagittarius, .aquarius],
    .noiDoi:         [.gemini, .pisces, .libra, .scorpio, .aquarius, .sagittarius, .aries, .leo, .cancer, .taurus, .virgo, .capricorn],
    .sangTao:        [.aquarius, .pisces, .gemini, .sagittarius, .aries, .libra, .leo, .scorpio, .cancer, .taurus, .virgo, .capricorn],
    .mongMo:         [.pisces, .cancer, .libra, .taurus, .scorpio, .leo, .virgo, .capricorn, .aries, .gemini, .sagittarius, .aquarius],
    .soXau:          [.libra, .leo, .taurus, .pisces, .cancer, .virgo, .scorpio, .capricorn, .aries, .gemini, .sagittarius, .aquarius],
    .thanThien:      [.libra, .pisces, .gemini, .sagittarius, .aquarius, .leo, .cancer, .taurus, .aries, .scorpio, .virgo, .capricorn],
    .thanhThien:     [.pisces, .cancer, .virgo, .taurus, .capricorn, .libra, .leo, .scorpio, .aries, .gemini, .sagittarius, .aquarius],
    .viBanBe:        [.pisces, .cancer, .libra, .gemini, .sagittarius, .aquarius, .leo, .scorpio, .aries, .taurus, .virgo, .capricorn],
    .voTinh:         [.aquarius, .gemini, .scorpio, .aries, .sagittarius, .capricorn, .virgo, .leo, .libra, .pisces, .cancer, .taurus],
    .nhieuTinhXau:   [.scorpio, .gemini, .pisces, .aries, .leo, .libra, .sagittarius, .aquarius, .cancer, .taurus, .virgo, .capricorn],
    .yeuDoi:         [.sagittarius, .pisces, .leo, .libra, .gemini, .aries, .aquarius, .scorpio, .cancer, .taurus, .virgo, .capricorn]
]

struct ZodiacRankView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: RankCategory? = nil
    @State private var showDropdown = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.clear
                    .background(
                        Image("BlackBG")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.6), Color.purple.opacity(0.15)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                ScrollView {
                    VStack(spacing: 28) {
                        // MARK: - Header
                        headerView

                        // MARK: - Zodiac Grid
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 4), spacing: 12) {
                            ForEach(Zodiac.allCases, id: \.self) { zodiac in
                                VStack(spacing: 4) {
                                    Image(zodiacImageName(for: zodiac))
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.white.opacity(0.9))
                                        .shadow(color: .purple.opacity(0.4), radius: 3)

                                    Text(zodiac.localizedName)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    Text(zodiac.dateRange)
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.6))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(10)
                                .frame(height: 90)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Picker Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.yellow.opacity(0.9))
                                    .font(.title2)

                                Text(LanguageManager.current.string("rank_question"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            // Custom Dropdown Button
                            Button(action: { showDropdown.toggle() }) {
                                HStack {
                                    Text(selectedCategory?.localized ?? LanguageManager.current.string("rank_select_placeholder"))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    Spacer()

                                    Image(systemName: showDropdown ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.purple.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.purple.opacity(0.7), lineWidth: 1.5)
                                        )
                                )
                                .shadow(color: .purple.opacity(0.4), radius: 6, x: 0, y: 3)
                            }

                            // Dropdown List
                            if showDropdown {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(RankCategory.allCases) { cat in
                                        Button(action: {
                                            selectedCategory = cat
                                            showDropdown = false
                                        }) {
                                            HStack {
                                                Text(cat.localized)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 12)
                                                    .padding(.horizontal, 16)
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.purple.opacity(0.2))
                                        }
                                        .background(
                                            Color.purple.opacity(cat == selectedCategory ? 0.4 : 0.1)
                                        )
                                    }
                                }
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                                .shadow(color: .purple.opacity(0.5), radius: 8)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .zIndex(1)
                            }
                        }

                        // MARK: - Ranking List
                        if let category = selectedCategory, let ranks = rankData[category] {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.localized)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)

                                ForEach(ranks.indices, id: \.self) { idx in
                                    let zodiac = ranks[idx]
                                    let rank = idx + 1

                                    HStack(spacing: 12) {
                                        rankBadge(for: rank)
                                            .frame(width: 80)

                                        Image(zodiacImageName(for: zodiac))
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .foregroundStyle(rankColor(for: rank))
                                            .shadow(color: rankGlowColor(for: rank), radius: rank == 1 ? 8 : 4)

                                        Text(zodiac.localizedName.uppercased())
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)

                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(rankGradient(for: rank))
                                            .opacity(0.85)
                                            .shadow(color: rankShadowColor(for: rank), radius: 6, x: 0, y: 3)
                                    )
                                    .padding(.horizontal, 8)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory)
                                }
                            }
                            .padding(.vertical, 8)
                        }

                        Spacer().frame(height: 60)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Zodiac Image Name
    private func zodiacImageName(for zodiac: Zodiac) -> String {
        zodiac.rawValue.lowercased() == "capricorn" ? "HoroscopeZodiac" : "\(zodiac.rawValue.capitalized)Zodiac"
    }

    // MARK: - Rank Badge
    private func rankBadge(for rank: Int) -> some View {
        Group {
            if rank == 1 {
                Text(LanguageManager.current.string("rank_champion"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.8), lineWidth: 1.5)
                    )
            } else if rank == 2 {
                Text(LanguageManager.current.string("rank_runner_up"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.7), lineWidth: 1.5)
                    )
            } else if rank == 3 {
                Text(LanguageManager.current.string("rank_third_place"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.7), lineWidth: 1.5)
                    )
            } else {
                Text("\(LanguageManager.current.string("rank_prefix")) \(rank)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }
        }
    }

    // MARK: - Rank Colors
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .white
        case 3: return .orange
        default: return .white.opacity(0.9)
        }
    }

    private func rankGlowColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow.opacity(0.6)
        case 2: return .white.opacity(0.4)
        case 3: return .orange.opacity(0.5)
        default: return .clear
        }
    }

    private func rankShadowColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow.opacity(0.5)
        case 2: return .gray.opacity(0.4)
        case 3: return .orange.opacity(0.4)
        default: return .purple.opacity(0.3)
        }
    }

    private func rankGradient(for rank: Int) -> LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.orange.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.gray.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.25), Color.purple.opacity(0.15)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left.circle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow.opacity(0.9))

                Text(LanguageManager.current.string("zodiac_rank_title"))
                    .font(.custom("Audiowide", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)

            Spacer()
        }
        .padding(.horizontal, 8)
        .background(
            Color.purple.opacity(0.2)
                .blur(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.purple.opacity(0.8), lineWidth: 1)
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    ZodiacRankView()
}
