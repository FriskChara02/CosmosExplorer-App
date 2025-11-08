//
//  ZodiacLoveView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 28/10/25.
//

import SwiftUI

struct ZodiacLoveView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMale: ZodiacSign?
    @State private var selectedFemale: ZodiacSign?
    @State private var showResultView = false
    
    let signs: [ZodiacSign] = [
        ZodiacSign(key: "aries", dateKey: "aries_date", symbol: "Aries", color: Color.yellow.opacity(0.6), chibiImage: "aries_chibi", alignment: .leading, english: "aries"),
        ZodiacSign(key: "taurus", dateKey: "taurus_date", symbol: "Taurus", color: Color.cyan.opacity(0.6), chibiImage: "taurus_chibi", alignment: .trailing, english: "taurus"),
        ZodiacSign(key: "gemini", dateKey: "gemini_date", symbol: "Gemini", color: Color.red.opacity(0.6), chibiImage: "gemini_chibi", alignment: .leading, english: "gemini"),
        ZodiacSign(key: "cancer", dateKey: "cancer_date", symbol: "Cancer", color: Color.purple.opacity(0.6), chibiImage: "cancer_chibi", alignment: .trailing, english: "cancer"),
        ZodiacSign(key: "leo", dateKey: "leo_date", symbol: "Leo", color: Color.orange.opacity(0.6), chibiImage: "leo_chibi", alignment: .leading, english: "leo"),
        ZodiacSign(key: "virgo", dateKey: "virgo_date", symbol: "Virgo", color: Color.red.opacity(0.6), chibiImage: "virgo_chibi", alignment: .trailing, english: "virgo"),
        ZodiacSign(key: "libra", dateKey: "libra_date", symbol: "Libra", color: Color.green.opacity(0.6), chibiImage: "libra_chibi", alignment: .leading, english: "libra"),
        ZodiacSign(key: "scorpio", dateKey: "scorpio_date", symbol: "Scorpio", color: Color.orange.opacity(0.6), chibiImage: "scorpio_chibi", alignment: .trailing, english: "scorpio"),
        ZodiacSign(key: "sagittarius", dateKey: "sagittarius_date", symbol: "Sagittarius", color: Color.purple.opacity(0.6), chibiImage: "sagittarius_chibi", alignment: .leading, english: "sagittarius"),
        ZodiacSign(key: "capricorn", dateKey: "capricorn_date", symbol: "Capricorn", color: Color.orange.opacity(0.6), chibiImage: "capricorn_chibi", alignment: .trailing, english: "capricorn"),
        ZodiacSign(key: "aquarius", dateKey: "aquarius_date", symbol: "Aquarius", color: Color.teal.opacity(0.6), chibiImage: "aquarius_chibi", alignment: .leading, english: "aquarius"),
        ZodiacSign(key: "pisces", dateKey: "pisces_date", symbol: "Pisces", color: Color.blue.opacity(0.6), chibiImage: "pisces_chibi", alignment: .trailing, english: "pisces")
    ]
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 4)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
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
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Male Zodiacs
                        zodiacFrame(
                            title: LanguageManager.current.string("male_zodiacs"),
                            signs: signs,
                            selectedSign: selectedMale,
                            onSelect: { selectedMale = $0 }
                        )
                        
                        // Female Zodiacs
                        zodiacFrame(
                            title: LanguageManager.current.string("female_zodiacs"),
                            signs: signs,
                            selectedSign: selectedFemale,
                            onSelect: { selectedFemale = $0 }
                        )
                        
                        resultButton
                            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $showResultView) {
                if let male = selectedMale, let female = selectedFemale {
                    ZodiacLoveResultView(maleSign: male, femaleSign: female)
                }
            }
        }
        .navigationBarHidden(true)
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
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(LanguageManager.current.string("zodiac_love_title"))
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
    
    // MARK: - Zodiac Frame
    private func zodiacFrame(
        title: String,
        signs: [ZodiacSign],
        selectedSign: ZodiacSign?,
        onSelect: @escaping (ZodiacSign) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(signs) { sign in
                    VStack(spacing: 6) {
                        ZodiacCircleView(
                            sign: sign,
                            isSelected: selectedSign?.id == sign.id,
                            onTap: { onSelect(sign) }
                        )
                        .frame(width: 70, height: 70)
                        
                        Text(LanguageManager.current.string(sign.key))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .white.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Result Button
    private var resultButton: some View {
        Button {
            if selectedMale != nil && selectedFemale != nil {
                showResultView = true
            }
        } label: {
            Text(LanguageManager.current.string("result_button"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.pink.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .disabled(selectedMale == nil || selectedFemale == nil)
        .opacity(selectedMale == nil || selectedFemale == nil ? 0.6 : 1.0)
    }
}

// MARK: - Circle View
struct ZodiacCircleView: View {
    let sign: ZodiacSign
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? sign.color : Color.gray.opacity(0.3))
                .overlay(
                    Circle()
                        .stroke(sign.color.opacity(isSelected ? 0.9 : 0.4), lineWidth: 3)
                )
                .shadow(color: isSelected ? sign.color.opacity(0.8) : .clear, radius: 8)
            
            Image(sign.english == "capricorn" ? "HoroscopeZodiac" : "\(sign.english.capitalized)Zodiac")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
        }
        .onTapGesture { onTap() }
    }
}

// MARK: - Result View
struct ZodiacLoveResultView: View {
    @Environment(\.dismiss) private var dismiss
    let maleSign: ZodiacSign
    let femaleSign: ZodiacSign
    
    var body: some View {
        ZStack {
            Color.clear
                .background(
                    Image("BlackBG")
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
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text(LanguageManager.current.string("zodiac_love_result_title"))
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
                    .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Love
                    VStack(spacing: 20) {
                        HStack(spacing: 24) {
                            // Male
                            VStack {
                                Image(maleSign.english == "capricorn" ? "HoroscopeZodiac" : "\(maleSign.english.capitalized)Zodiac")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                Text(LanguageManager.current.string(maleSign.key))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.pink)
                            
                            // Female
                            VStack {
                                Image(femaleSign.english == "capricorn" ? "HoroscopeZodiac" : "\(femaleSign.english.capitalized)Zodiac")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white)
                                    .frame(width: 60, height: 60)
                                Text(LanguageManager.current.string(femaleSign.key))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 24)
                        
                        let maleName = LanguageManager.current.string(maleSign.key)
                        let femaleName = LanguageManager.current.string(femaleSign.key)
                        
                        let templates = [
                            "\(maleName)(Chàng) sẽ không bao giờ cho \(femaleName)(Nàng) cơ hội thứ hai nếu phát hiện được \(femaleName)(Nàng) 'bắt cá hai tay' !",
                            "Thường thì \(femaleName)(Nàng) sẽ thích có con gái còn \(maleName)(Chàng) sẽ thích có con trai hơn.",
                            "\(maleName)(Chàng) hay làm \(femaleName)(Nàng) giận lắm !",
                            "\(maleName)(Chàng) tin vào duyên số còn \(femaleName)(Nàng) tin vào thực tại hơn !",
                            "Đừng mơ \(maleName)(Chàng) xin lỗi khi mắc lỗi mà \(femaleName)(Nàng) không có bằng chứng chính xác nhé :)",
                            "\(maleName)(Chàng) có phần chịu nhường nhịn \(femaleName)(Nàng) hơn",
                            "\(femaleName)(Nàng) là người sáng tạo hơn trong tình yêu, sẽ cho \(maleName)(Chàng) nhiều điều bất ngờ.",
                            "Khi hai người có xích mích \(femaleName)(Nàng) chắc chắn sẽ là người lo nghĩ nhiều hơn !",
                            "Khi có bí mật \(maleName)(Chàng) sẽ giấu kín tốt hơn \(femaleName)(Nàng).",
                            "\(maleName)(Chàng) không quan tâm đến 'chuyện vật chất' khi yêu.",
                            "\(maleName)(Chàng) sẽ có máu ghen(đa nghi) hơn \(femaleName)(Nàng) :)",
                            "Khả năng \(femaleName)(Nàng) sẽ cháy hết mình trong tình yêu hơn \(maleName)(Chàng)",
                            "Nhiều lúc \(femaleName)(Nàng) rất vô lý và gia trưởng trong tình yêu !",
                            "Nếu đến một lúc nào đó bắt buộc phải nói lời chia tay thì \(maleName)(Chàng) sẽ nói trước...",
                            "Nếu hai cặp đôi này có nhiều con cái thì các con sẽ thương \(maleName)(Chàng) nhiều hơn !",
                            "Nếu có em bé \(femaleName)(Nàng) rất giỏi chăm !",
                            "Nếu mà có cãi nhau thì \(femaleName)(Nàng) phải chào thua \(maleName)(Chàng) :)",
                            "Khi có một đối tượng 'chất lượng' hơn \(femaleName)(Nàng) ... thì \(maleName)(Chàng) sẽ dễ bị rung động hơn đấy !",
                            
                            "\(maleName)(Chàng) thích nghe \(femaleName)(Nàng) hát ru dù giọng có hơi... lệch tông một chút :)",
                            "\(femaleName)(Nàng) sẽ là người lên kế hoạch du lịch còn \(maleName)(Chàng) chỉ cần... xách ba lô theo!",
                            "\(maleName)(Chàng) hay giả vờ giận để \(femaleName)(Nàng) dỗ dành bằng đồ ăn ngon.",
                            "\(femaleName)(Nàng) tin vào bói toán, còn \(maleName)(Chàng) bảo 'đừng tin, anh là định mệnh của em rồi'!",
                            "Khi \(femaleName)(Nàng) buồn, \(maleName)(Chàng) sẽ lặng lẽ ôm từ phía sau – không cần lời nói."
                            
                            
                        ]
                        
                        let babyTemplates = [
                            "một cậu bé thuộc chòm sao Bảo Bình có làn da trắng sáng và đôi mắt trong sáng. cậu bé sẽ có rất nhiều ý tưởng và thương yêu động vật sẽ giống \(femaleName)(Nàng) nhiều hơn \(maleName)(Chàng).",
                            "một cô bé thuộc chòm sao Sư Tử có làn da trắng hồng và đôi mắt tinh anh. cô bé sẽ rất sáng tạo và hòa đồng sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng).",
                            "một cậu bé thuộc chòm sao Song Ngư có làn da trắng hồng và đôi mắt trong sáng. cậu bé sẽ có rất nhiều ý tưởng và nhanh nhẹn sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng).",
                            "một cậu bé thuộc chòm sao Ma Kết có làn da trắng sáng và đôi mắt quyến rũ. cậu bé sẽ rất sáng tạo và hiền lành sẽ giống \(femaleName)(Nàng) nhiều hơn \(maleName)(Chàng).",
                            "một cô bé thuộc chòm sao Xử Nữ có làn da trắng hồng và đôi mắt trong sáng. cô bé sẽ rất thông minh và hòa đồng sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng).",
                            "một cậu bé thuộc chòm sao Cự Giải có làn da bánh mật và đôi mắt đầy mộng mơ. cậu bé sẽ rất lanh lợi và hòa đồng sẽ giống \(femaleName)(Nàng) nhiều hơn \(maleName)(Chàng).",
                            
                            "một cậu bé thuộc chòm sao Bạch Dương có làn da bánh mật và đôi mắt lấp lánh. cậu bé sẽ rất năng động và thích khám phá sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng).",
                            "một cô bé thuộc chòm sao Thiên Bình có làn da trắng sáng và đôi mắt dịu dàng. cô bé sẽ rất khéo léo và yêu cái đẹp sẽ giống \(femaleName)(Nàng) nhiều hơn \(maleName)(Chàng).",
                            "một cậu bé thuộc chòm sao Kim Ngưu có làn da trắng hồng và đôi mắt trầm ấm. cậu bé sẽ rất kiên nhẫn và thích ăn ngon sẽ giống \(femaleName)(Nàng) nhiều hơn \(maleName)(Chàng).",
                            "một cô bé thuộc chòm sao Song Tử có làn da trắng sáng và đôi mắt tinh nghịch. cô bé sẽ rất thông minh và nói nhiều sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng).",
                            "một cậu bé thuộc chòm sao Nhân Mã có làn da bánh mật và đôi mắt rực rỡ. cậu bé sẽ rất yêu tự do và thích thể thao sẽ giống \(maleName)(Chàng) nhiều hơn \(femaleName)(Nàng)."
                        ]
                        
                        let randomFacts = templates.shuffled().prefix(8)
                        let babyFact = babyTemplates.randomElement() ?? ""
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(randomFacts, id: \.self) { fact in
                                Text("• \(fact)")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Text("Nếu cặp đôi này có em bé đầu lòng khả năng sẽ là \(babyFact)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.pink.opacity(0.9))
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ZodiacLoveView()
    }
}
