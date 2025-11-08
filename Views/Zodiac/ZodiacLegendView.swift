//
//  ZodiacLegendView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import SwiftUI

struct ZodiacSign: Identifiable {
    let id = UUID()
    let key: String
    let dateKey: String
    let symbol: String
    let color: Color
    let chibiImage: String
    let alignment: HorizontalAlignment
    let english: String
}

struct ZodiacLegendView: View {
    @Environment(\.dismiss) private var dismiss
    
    let signs: [ZodiacSign] = [
        ZodiacSign(key: "aries", dateKey: "aries_date", symbol: "♈", color: Color.yellow.opacity(0.6), chibiImage: "aries_chibi", alignment: .leading, english: "aries"),
        ZodiacSign(key: "taurus", dateKey: "taurus_date", symbol: "♉", color: Color.cyan.opacity(0.6), chibiImage: "taurus_chibi", alignment: .trailing, english: "taurus"),
        ZodiacSign(key: "gemini", dateKey: "gemini_date", symbol: "♊", color: Color.red.opacity(0.6), chibiImage: "gemini_chibi", alignment: .leading, english: "gemini"),
        ZodiacSign(key: "cancer", dateKey: "cancer_date", symbol: "♋", color: Color.purple.opacity(0.6), chibiImage: "cancer_chibi", alignment: .trailing, english: "cancer"),
        ZodiacSign(key: "leo", dateKey: "leo_date", symbol: "♌", color: Color.orange.opacity(0.6), chibiImage: "leo_chibi", alignment: .leading, english: "leo"),
        ZodiacSign(key: "virgo", dateKey: "virgo_date", symbol: "♍", color: Color.red.opacity(0.6), chibiImage: "virgo_chibi", alignment: .trailing, english: "virgo"),
        ZodiacSign(key: "libra", dateKey: "libra_date", symbol: "♎", color: Color.green.opacity(0.6), chibiImage: "libra_chibi", alignment: .leading, english: "libra"),
        ZodiacSign(key: "scorpio", dateKey: "scorpio_date", symbol: "♏", color: Color.orange.opacity(0.6), chibiImage: "scorpio_chibi", alignment: .trailing, english: "scorpio"),
        ZodiacSign(key: "sagittarius", dateKey: "sagittarius_date", symbol: "♐", color: Color.purple.opacity(0.6), chibiImage: "sagittarius_chibi", alignment: .leading, english: "sagittarius"),
        ZodiacSign(key: "capricorn", dateKey: "capricorn_date", symbol: "♑", color: Color.orange.opacity(0.6), chibiImage: "capricorn_chibi", alignment: .trailing, english: "capricorn"),
        ZodiacSign(key: "aquarius", dateKey: "aquarius_date", symbol: "♒", color: Color.teal.opacity(0.6), chibiImage: "aquarius_chibi", alignment: .leading, english: "aquarius"),
        ZodiacSign(key: "pisces", dateKey: "pisces_date", symbol: "♓", color: Color.blue.opacity(0.6), chibiImage: "pisces_chibi", alignment: .trailing, english: "pisces")
    ]
    
    private var leftColumnSigns: [ZodiacSign] {
        signs.enumerated().compactMap { index, sign in index % 2 == 0 ? sign : nil }
    }
    
    private var rightColumnSigns: [ZodiacSign] {
        signs.enumerated().compactMap { index, sign in index % 2 == 1 ? sign : nil }
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .background(
                    Image("cosmos_background1")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.4), Color.purple.opacity(0.1)]),
                        startPoint: .top, endPoint: .bottom
                    )
                )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left.circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "scroll")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text(LanguageManager.current.string("zodiac_legend_title"))
                                .font(.custom("Audiowide", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)
                        
                        Spacer()
                    }
                    .background(
                        Color.purple.opacity(0.2)
                            .blur(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.purple.opacity(0.8), lineWidth: 1)
                            )
                    )
                    
                    // Dual Column Layout
                    HStack(alignment: .top, spacing: 46) {
                        // CỘT TRÁI
                        VStack(spacing: 80) {
                            ForEach(leftColumnSigns) { sign in
                                if sign.english == "aries" {
                                    NavigationLink(destination: AriesLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else if sign.english == "gemini" {
                                    NavigationLink(destination: GeminiLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else if sign.english == "leo" {
                                    NavigationLink(destination: LeoLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else if sign.english == "libra" {
                                    NavigationLink(destination: LibraLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else if sign.english == "sagittarius" {
                                    NavigationLink(destination: SagittariusLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else if sign.english == "aquarius" {
                                    NavigationLink(destination: AquariusLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                } else {
                                    NavigationLink(destination: Text(LanguageManager.current.string("legend_detail_placeholder") + " \(LanguageManager.current.string(sign.key))")) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.leading, 16)
                        
                        // CỘT PHẢI
                        VStack(spacing: 80) {
                            ForEach(rightColumnSigns) { sign in
                                if sign.english == "taurus" {
                                    NavigationLink(destination: TaurusLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else if sign.english == "cancer" {
                                    NavigationLink(destination: CancerLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else if sign.english == "virgo" {
                                    NavigationLink(destination: VirgoLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else if sign.english == "scorpio" {
                                    NavigationLink(destination: ScorpioLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else if sign.english == "pisces" {
                                    NavigationLink(destination: PiscesLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else if sign.english == "capricorn" {
                                    NavigationLink(destination: HoroscopeLegendView()) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                } else {
                                    NavigationLink(destination: Text(LanguageManager.current.string("legend_detail_placeholder") + " \(LanguageManager.current.string(sign.key))")) {
                                        ZodiacLegendCard(sign: sign)
                                            .frame(width: 150, height: 260)
                                            .offset(x: 0, y: 100)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// Card component
struct ZodiacLegendCard: View {
    let sign: ZodiacSign
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 25)
                .fill(sign.color)
                .shadow(color: sign.color.opacity(0.9), radius: 20)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(sign.color.opacity(0.9), lineWidth: 6)
                )
            
            VStack(spacing: 4) {
                Image(sign.english == "capricorn" ? "HoroscopeZodiac" : "\(sign.english.capitalized)Zodiac")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .offset(y: -130)
                
                Text(LanguageManager.current.string(sign.key))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: -125)
                
                Text(LanguageManager.current.string(sign.dateKey))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .offset(y: -120)
            }
            .padding(.top, 16)
            
            Image(sign.chibiImage)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .offset(y: -10)
        }
    }
}

#Preview {
    NavigationStack {
        ZodiacLegendView()
    }
}
