//
//  QuizViewModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI

// MARK: - QuizListViewModel
@MainActor
class QuizListViewModel: ObservableObject {
    @Published var quizzes: [Quiz] = []
    @Published var searchText: String = ""
    @Published var showLoadMore: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteQuizIds: Set<Int64> = []
    
    @AppStorage("hasInsertedSamples") private var hasInsertedSamples = false
    
    public let service: SwiftDataService
    public let mode: String
    public let currentUserId: UUID
    
    init(service: SwiftDataService, mode: String) {
        self.service = service
        self.mode = mode
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        SampleQuizzes()
        loadQuizzes()
    }
    
    func loadQuizzes(loadMore: Bool = false) {
        isLoading = true
        let context = service.container.mainContext
        let mode = self.mode

        let descriptor = FetchDescriptor<Quiz>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            let allQuizzes = try context.fetch(descriptor)

            let filteredQuizzes = allQuizzes.filter { quiz in
                guard let data = quiz.categoriesData else { return false }
                guard let categories = try? JSONDecoder().decode([String].self, from: data) else { return false }
                return categories.contains(mode)
            }

            let own = filteredQuizzes.filter { $0.createdBy == currentUserId }
            let app = filteredQuizzes.filter { $0.createdBy == nil }
            let others = filteredQuizzes.filter { $0.createdBy != nil && $0.createdBy != currentUserId && $0.isPublic }

            quizzes = own + app + others
            showLoadMore = others.count > 10
        } catch {
            errorMessage = "Error loading quizzes: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    var filteredQuizzes: [Quiz] {
        if searchText.isEmpty {
            return quizzes
        } else {
            return quizzes.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func addQuiz(title: String, description: String, isPublic: Bool, categories: [String], cards: [Card]) {
        let newQuiz = Quiz(title: title, quizDescription: description, isPublic: isPublic, createdBy: currentUserId, categories: categories)
        newQuiz.cards = cards
        service.saveQuiz(newQuiz)
        quizzes.insert(newQuiz, at: 0)
    }
    
    func deleteQuiz(_ quiz: Quiz) {
        if quiz.createdBy == currentUserId {
            service.deleteQuiz(quiz)
            quizzes.removeAll { $0.id == quiz.id }
        }
    }
    
    func isQuizFavorite(_ quizId: Int64) -> Bool { favoriteQuizIds.contains(quizId) }
    func toggleQuizFavorite(_ quizId: Int64) {
        if favoriteQuizIds.contains(quizId) {
            favoriteQuizIds.remove(quizId)
        } else {
            favoriteQuizIds.insert(quizId)
        }
        sortQuizzesByFavorites()
    }
    public func sortQuizzesByFavorites() {
        quizzes.sort {
            favoriteQuizIds.contains($0.id) && !favoriteQuizIds.contains($1.id)
        }
    }
    
    // MARK: - SampleQuizzes FULL
    private func SampleQuizzes() {
        guard !hasInsertedSamples else { return }
        
        let context = service.container.mainContext
        
        // Kiểm tra đã có sample quiz nào chưa
        let sampleCount = (try? context.fetchCount(FetchDescriptor<Quiz>(predicate: #Predicate { $0.createdBy == nil }))) ?? 0
            guard sampleCount == 0 else { return }
        
        let now = Date().timeIntervalSince1970 * 1000
        let baseId: Int64 = Int64(now)

        // MARK: - Quiz 1: Hệ Mặt Trời
        let quiz1 = Quiz(
            id: baseId + 1,
            title: "Hệ Mặt Trời",
            quizDescription: "8 hành tinh chính",
            isPublic: false,
            createdBy: nil,
            categories: ["Flashcards"]
        )
        
        let card1_1 = Card(term: "Trái Đất", definition: "Hành tinh thứ 3", hint: "Hành tinh xanh, có sự sống", imageData: imageData(named: "Earth"))
        card1_1.id = baseId + 11
        card1_1.quiz = quiz1
        
        let card1_2 = Card(term: "Sao Hỏa", definition: "Hành tinh Đỏ", hint: "Có núi lửa lớn nhất hệ Mặt Trời", imageData: imageData(named: "Mars"))
        card1_2.id = baseId + 12
        card1_2.quiz = quiz1
        
        let card1_3 = Card(term: "Sao Mộc", definition: "Hành tinh lớn nhất", hint: "Có Vết Đỏ Lớn là bão khổng lồ", imageData: imageData(named: "Jupiter"))
        card1_3.id = baseId + 13
        card1_3.quiz = quiz1
        
        quiz1.cards = [card1_1, card1_2, card1_3]
        service.saveQuiz(quiz1)
        
        // MARK: - Quiz 2: Thiên hà
        let quiz2 = Quiz(
            id: baseId + 2,
            title: "Thiên hà",
            quizDescription: "Các loại thiên hà",
            isPublic: false,
            createdBy: nil,
            categories: ["Flashcards"]
        )
        
        let card2_1 = Card(term: "Andromeda", definition: "Thiên hà Andromeda", hint: "Thiên hà xoắn ốc gần nhất với Ngân Hà", imageData: imageData(named: "Andromeda"))
        card2_1.id = baseId + 21
        card2_1.quiz = quiz2
        
        let card2_2 = Card(term: "M32", definition: "Thiên hà M32", hint: "Thiên hà vệ tinh của Andromeda", imageData: imageData(named: "M32"))
        card2_2.id = baseId + 22
        card2_2.quiz = quiz2
        
        let card2_3 = Card(term: "Triangulum", definition: "Thiên hà Triangulum", hint: "Thành viên thứ 3 trong Nhóm Địa Phương", imageData: imageData(named: "Triangulum"))
        card2_3.id = baseId + 23
        card2_3.quiz = quiz2
        
        quiz2.cards = [card2_1, card2_2, card2_3]
        service.saveQuiz(quiz2)
        
        // MARK: - Quiz 3: Các vì sao
        let quiz3 = Quiz(
            id: baseId + 3,
            title: "Các vì sao",
            quizDescription: "Phân loại và đặc điểm của các ngôi sao",
            isPublic: false,
            createdBy: nil,
            categories: ["Flashcards"]
        )
        
        let card3_1 = Card(term: "Mặt Trời", definition: "Ngôi sao trung tâm của Hệ Mặt Trời", hint: "Ngôi sao loại G, tuổi 4.6 tỷ năm", imageData: imageData(named: "Sun"))
        card3_1.id = baseId + 31
        card3_1.quiz = quiz3
        
        let card3_2 = Card(term: "Sao Siêu Khổng Lồ Đỏ", definition: "Ngôi sao ở giai đoạn cuối, cực lớn và sáng", hint: "Có thể to hơn cả quỹ đạo Trái Đất", imageData: imageData(named: "AlphaCentauri"))
        card3_2.id = baseId + 32
        card3_2.quiz = quiz3
        
        let card3_3 = Card(term: "Sao Lùn Trắng", definition: "Tàn dư của sao sau khi cạn nhiên liệu", hint: "Kích thước bằng Trái Đất nhưng nặng bằng Mặt Trời", imageData: imageData(named: "Canopus"))
        card3_3.id = baseId + 33
        card3_3.quiz = quiz3
        
        quiz3.cards = [card3_1, card3_2, card3_3]
        service.saveQuiz(quiz3)
        
        // MARK: - Quiz 4: Các chòm sao
        let quiz4 = Quiz(
            id: baseId + 4,
            title: "Các chòm sao",
            quizDescription: "Tên và hình dạng của các chòm sao nổi tiếng",
            isPublic: false,
            createdBy: nil,
            categories: ["Flashcards"]
        )
        
        let card4_1 = Card(term: "Orion", definition: "Chòm sao Thợ săn", hint: "Có ngôi sao sáng Betelgeuse và Rigel", imageData: imageData(named: "Sirius"))
        card4_1.id = baseId + 41
        card4_1.quiz = quiz4
        
        let card4_2 = Card(term: "Ursa Major", definition: "Chòm sao Gấu Lớn", hint: "Chứa chòm sao Bắc Đẩu", imageData: imageData(named: "AlphaCentauri"))
        card4_2.id = baseId + 42
        card4_2.quiz = quiz4
        
        let card4_3 = Card(term: "Lyra", definition: "Chòm sao Thiên Cầm", hint: "Có ngôi sao sáng Vega", imageData: imageData(named: "ProximaB"))
        card4_3.id = baseId + 43
        card4_3.quiz = quiz4
        
        quiz4.cards = [card4_1, card4_2, card4_3]
        service.saveQuiz(quiz4)
        
        // MARK: - Learn Quiz 1: Hành tinh trong Hệ Mặt Trời
        let learnQuiz1 = Quiz(
            id: baseId + 101,
            title: "Hành tinh Hệ Mặt Trời",
            quizDescription: "Chọn tên hành tinh đúng",
            isPublic: false,
            createdBy: nil,
            categories: ["Learn"]
        )

        let lcard1_1 = Card(term: "Sao Thủy", definition: "Hành tinh gần Mặt Trời nhất", hint: "Nhỏ nhất, không có khí quyển dày", imageData: imageData(named: "Mercury"))
        lcard1_1.id = baseId + 111
        lcard1_1.quiz = learnQuiz1

        let lcard1_2 = Card(term: "Sao Kim", definition: "Hành tinh nóng nhất", hint: "Có hiệu ứng nhà kính mạnh", imageData: imageData(named: "Venus"))
        lcard1_2.id = baseId + 112
        lcard1_2.quiz = learnQuiz1

        let lcard1_3 = Card(term: "Trái Đất", definition: "Hành tinh có sự sống", hint: "Có nước lỏng và khí quyển oxy", imageData: imageData(named: "Earth"))
        lcard1_3.id = baseId + 113
        lcard1_3.quiz = learnQuiz1

        let lcard1_4 = Card(term: "Sao Hỏa", definition: "Hành tinh đỏ", hint: "Có núi lửa lớn nhất", imageData: imageData(named: "Mars"))
        lcard1_4.id = baseId + 114
        lcard1_4.quiz = learnQuiz1

        learnQuiz1.cards = [lcard1_1, lcard1_2, lcard1_3, lcard1_4]
        service.saveQuiz(learnQuiz1)

        // MARK: - Learn Quiz 2: Các ngôi sao sáng
        let learnQuiz2 = Quiz(
            id: baseId + 102,
            title: "Ngôi sao sáng nhất",
            quizDescription: "Chọn ngôi sao đúng theo độ sáng",
            isPublic: false,
            createdBy: nil,
            categories: ["Learn"]
        )

        let lcard2_1 = Card(term: "Sirius", definition: "Ngôi sao sáng nhất bầu trời đêm", hint: "Thuộc chòm sao Canis Major", imageData: imageData(named: "Sirius"))
        lcard2_1.id = baseId + 121
        lcard2_1.quiz = learnQuiz2

        let lcard2_2 = Card(term: "Canopus", definition: "Ngôi sao sáng thứ 2", hint: "Nằm ở Nam bán cầu", imageData: imageData(named: "Canopus"))
        lcard2_2.id = baseId + 122
        lcard2_2.quiz = learnQuiz2

        let lcard2_3 = Card(term: "Alpha Centauri", definition: "Hệ sao gần nhất", hint: "Gồm 3 ngôi sao", imageData: imageData(named: "AlphaCentauri"))
        lcard2_3.id = baseId + 123
        lcard2_3.quiz = learnQuiz2

        learnQuiz2.cards = [lcard2_1, lcard2_2, lcard2_3]
        service.saveQuiz(learnQuiz2)

        // MARK: - Learn Quiz 3: Hiện tượng vũ trụ
        let learnQuiz3 = Quiz(
            id: baseId + 103,
            title: "Hiện tượng vũ trụ",
            quizDescription: "Chọn tên hiện tượng đúng",
            isPublic: false,
            createdBy: nil,
            categories: ["Learn"]
        )

        let lcard3_1 = Card(term: "Siêu tân tinh", definition: "Vụ nổ sao cực mạnh", hint: "Sáng hơn cả thiên hà", imageData: imageData(named: "cosmos_background1"))
        lcard3_1.id = baseId + 131
        lcard3_1.quiz = learnQuiz3

        let lcard3_2 = Card(term: "Hố đen", definition: "Vùng không gian hút mọi thứ", hint: "Không ánh sáng nào thoát ra", imageData: imageData(named: "BlackHole"))
        lcard3_2.id = baseId + 132
        lcard3_2.quiz = learnQuiz3

        let lcard3_3 = Card(term: "Sao chổi", definition: "Khối băng bay quanh Mặt Trời", hint: "Có đuôi khi gần Mặt Trời", imageData: imageData(named: "ProximaB"))
        lcard3_3.id = baseId + 133
        lcard3_3.quiz = learnQuiz3

        learnQuiz3.cards = [lcard3_1, lcard3_2, lcard3_3]
        service.saveQuiz(learnQuiz3)

        // MARK: - Learn Quiz 4: Vệ tinh tự nhiên
        let learnQuiz4 = Quiz(
            id: baseId + 104,
            title: "Vệ tinh nổi bật",
            quizDescription: "Chọn vệ tinh đúng với hành tinh",
            isPublic: false,
            createdBy: nil,
            categories: ["Learn"]
        )

        let lcard4_1 = Card(term: "Moon", definition: "Vệ tinh của Trái Đất", hint: "Gây ra thủy triều", imageData: imageData(named: "Moon"))
        lcard4_1.id = baseId + 141
        lcard4_1.quiz = learnQuiz4

        let lcard4_2 = Card(term: "Phobos", definition: "Vệ tinh của Sao Hỏa", hint: "Hình dạng bất thường", imageData: imageData(named: "Phobos"))
        lcard4_2.id = baseId + 142
        lcard4_2.quiz = learnQuiz4

        let lcard4_3 = Card(term: "Titan", definition: "Vệ tinh lớn nhất của Sao Thổ", hint: "Có khí quyển dày hơn Trái Đất", imageData: imageData(named: "Titan"))
        lcard4_3.id = baseId + 143
        lcard4_3.quiz = learnQuiz4

        learnQuiz4.cards = [lcard4_1, lcard4_2, lcard4_3]
        service.saveQuiz(learnQuiz4)
        
        // MARK: - Test Quiz 1: Hành tinh trong Hệ Mặt Trời
        let testQuiz1 = Quiz(
            id: baseId + 201,
            title: "Hành tinh Hệ Mặt Trời",
            quizDescription: "Kiểm tra kiến thức về 8 hành tinh",
            isPublic: false,
            createdBy: nil,
            categories: ["Test"]
        )

        let tcard1_1 = Card(term: "Sao Thủy", definition: "Hành tinh gần Mặt Trời nhất", hint: "Nhỏ nhất, không có vệ tinh", imageData: imageData(named: "Mercury"))
        tcard1_1.id = baseId + 211
        tcard1_1.quiz = testQuiz1

        let tcard1_2 = Card(term: "Sao Kim", definition: "Hành tinh nóng nhất", hint: "Có hiệu ứng nhà kính mạnh", imageData: imageData(named: "Venus"))
        tcard1_2.id = baseId + 212
        tcard1_2.quiz = testQuiz1

        let tcard1_3 = Card(term: "Trái Đất", definition: "Hành tinh duy nhất có sự sống", hint: "70% là nước", imageData: imageData(named: "Earth"))
        tcard1_3.id = baseId + 213
        tcard1_3.quiz = testQuiz1

        let tcard1_4 = Card(term: "Sao Hỏa", definition: "Hành tinh đỏ", hint: "Có Olympus Mons - núi lửa lớn nhất", imageData: imageData(named: "Mars"))
        tcard1_4.id = baseId + 214
        tcard1_4.quiz = testQuiz1

        let tcard1_5 = Card(term: "Sao Mộc", definition: "Hành tinh lớn nhất", hint: "Có Vết Đỏ Lớn", imageData: imageData(named: "Jupiter"))
        tcard1_5.id = baseId + 215
        tcard1_5.quiz = testQuiz1

        testQuiz1.cards = [tcard1_1, tcard1_2, tcard1_3, tcard1_4, tcard1_5]
        service.saveQuiz(testQuiz1)

        // MARK: - Test Quiz 2: Các ngôi sao sáng
        let testQuiz2 = Quiz(
            id: baseId + 202,
            title: "Ngôi sao sáng nhất bầu trời",
            quizDescription: "Top 5 ngôi sao sáng nhất",
            isPublic: false,
            createdBy: nil,
            categories: ["Test"]
        )

        let tcard2_1 = Card(term: "Sirius", definition: "Ngôi sao sáng nhất bầu trời đêm", hint: "Thuộc chòm sao Canis Major", imageData: imageData(named: "Sirius"))
        tcard2_1.id = baseId + 221
        tcard2_1.quiz = testQuiz2

        let tcard2_2 = Card(term: "Canopus", definition: "Ngôi sao sáng thứ hai", hint: "Nằm ở Nam bán cầu", imageData: imageData(named: "Canopus"))
        tcard2_2.id = baseId + 222
        tcard2_2.quiz = testQuiz2

        let tcard2_3 = Card(term: "Alpha Centauri", definition: "Hệ sao gần Trái Đất nhất", hint: "Chỉ cách 4.3 năm ánh sáng", imageData: imageData(named: "AlphaCentauri"))
        tcard2_3.id = baseId + 223
        tcard2_3.quiz = testQuiz2

        let tcard2_4 = Card(term: "Vega", definition: "Ngôi sao sáng thứ năm", hint: "Thuộc chòm sao Lyra", imageData: imageData(named: "Moon"))
        tcard2_4.id = baseId + 224
        tcard2_4.quiz = testQuiz2

        testQuiz2.cards = [tcard2_1, tcard2_2, tcard2_3, tcard2_4]
        service.saveQuiz(testQuiz2)

        // MARK: - Test Quiz 3: Hiện tượng vũ trụ
        let testQuiz3 = Quiz(
            id: baseId + 203,
            title: "Hiện tượng vũ trụ nổi bật",
            quizDescription: "Nhận diện các hiện tượng thiên văn",
            isPublic: false,
            createdBy: nil,
            categories: ["Test"]
        )

        let tcard3_1 = Card(term: "Siêu tân tinh", definition: "Vụ nổ sao cực mạnh", hint: "Có thể sáng hơn cả thiên hà", imageData: imageData(named: "Sirius"))
        tcard3_1.id = baseId + 231
        tcard3_1.quiz = testQuiz3

        let tcard3_2 = Card(term: "Hố đen", definition: "Vùng không gian hút mọi thứ", hint: "Không ánh sáng nào thoát ra", imageData: imageData(named: "BlackHole"))
        tcard3_2.id = baseId + 232
        tcard3_2.quiz = testQuiz3

        let tcard3_3 = Card(term: "Sao chổi", definition: "Khối băng di chuyển quanh Mặt Trời", hint: "Có đuôi khi gần Mặt Trời", imageData: imageData(named: "Canopus"))
        tcard3_3.id = baseId + 233
        tcard3_3.quiz = testQuiz3

        let tcard3_4 = Card(term: "Tinh vân", definition: "Đám mây khí và bụi trong vũ trụ", hint: "Nơi sinh ra ngôi sao", imageData: imageData(named: "Nebula"))
        tcard3_4.id = baseId + 234
        tcard3_4.quiz = testQuiz3

        let tcard3_5 = Card(term: "Sao neutron", definition: "Tàn dư cực kỳ đặc của sao lớn", hint: "Một thìa cà phê nặng hàng tỷ tấn", imageData: imageData(named: "Canopus"))
        tcard3_5.id = baseId + 235
        tcard3_5.quiz = testQuiz3

        testQuiz3.cards = [tcard3_1, tcard3_2, tcard3_3, tcard3_4, tcard3_5]
        service.saveQuiz(testQuiz3)

        // MARK: - Test Quiz 4: Vệ tinh tự nhiên
        let testQuiz4 = Quiz(
            id: baseId + 204,
            title: "Vệ tinh nổi bật",
            quizDescription: "Nhận biết vệ tinh của các hành tinh",
            isPublic: false,
            createdBy: nil,
            categories: ["Test"]
        )

        let tcard4_1 = Card(term: "Moon", definition: "Vệ tinh của Trái Đất", hint: "Gây ra thủy triều", imageData: imageData(named: "Moon"))
        tcard4_1.id = baseId + 241
        tcard4_1.quiz = testQuiz4

        let tcard4_2 = Card(term: "Phobos", definition: "Vệ tinh lớn nhất của Sao Hỏa", hint: "Hình dạng bất thường, gần hành tinh", imageData: imageData(named: "Phobos"))
        tcard4_2.id = baseId + 242
        tcard4_2.quiz = testQuiz4

        let tcard4_3 = Card(term: "Titan", definition: "Vệ tinh lớn nhất của Sao Thổ", hint: "Có khí quyển dày hơn Trái Đất", imageData: imageData(named: "AlphaCentauri03"))
        tcard4_3.id = baseId + 243
        tcard4_3.quiz = testQuiz4

        let tcard4_4 = Card(term: "Europa", definition: "Vệ tinh của Sao Mộc", hint: "Có đại dương nước lỏng dưới băng", imageData: imageData(named: "Sirius05"))
        tcard4_4.id = baseId + 244
        tcard4_4.quiz = testQuiz4

        let tcard4_5 = Card(term: "Ganymede", definition: "Vệ tinh lớn nhất Hệ Mặt Trời", hint: "Lớn hơn cả Sao Thủy", imageData: imageData(named: "Canopus03"))
        tcard4_5.id = baseId + 245
        tcard4_5.quiz = testQuiz4

        testQuiz4.cards = [tcard4_1, tcard4_2, tcard4_3, tcard4_4, tcard4_5]
        service.saveQuiz(testQuiz4)
        
        // MARK: - Blocks Quiz 1: Các hành tinh khí khổng lồ
        let blocksQuiz1 = Quiz(
            id: baseId + 301,
            title: "Hành tinh khí khổng lồ",
            quizDescription: "Khám phá các hành tinh khí trong Hệ Mặt Trời",
            isPublic: false,
            createdBy: nil,
            categories: ["Blocks"]
        )

        let bcard1_1 = Card(term: "Sao Mộc", definition: "Hành tinh lớn nhất, có Vết Đỏ Lớn", hint: "Có hơn 79 vệ tinh", imageData: imageData(named: "Jupiter"))
        bcard1_1.id = baseId + 311
        bcard1_1.quiz = blocksQuiz1

        let bcard1_2 = Card(term: "Sao Thổ", definition: "Hành tinh có vành đai nổi bật", hint: "Vành đai làm từ băng và đá", imageData: imageData(named: "Saturn"))
        bcard1_2.id = baseId + 312
        bcard1_2.quiz = blocksQuiz1

        let bcard1_3 = Card(term: "Sao Thiên Vương", definition: "Hành tinh quay nghiêng 98 độ", hint: "Có màu xanh do khí metan", imageData: imageData(named: "Uranus"))
        bcard1_3.id = baseId + 313
        bcard1_3.quiz = blocksQuiz1

        let bcard1_4 = Card(term: "Sao Hải Vương", definition: "Hành tinh xa nhất, có gió mạnh nhất", hint: "Có Vết Tối Lớn là bão khổng lồ", imageData: imageData(named: "Neptune"))
        bcard1_4.id = baseId + 314
        bcard1_4.quiz = blocksQuiz1

        let bcard1_5 = Card(term: "Sao Diêm Vương", definition: "Hành tinh lùn, không còn là hành tinh chính", hint: "Có quỹ đạo lệch tâm", imageData: imageData(named: "Pluto"))
        bcard1_5.id = baseId + 315
        bcard1_5.quiz = blocksQuiz1

        blocksQuiz1.cards = [bcard1_1, bcard1_2, bcard1_3, bcard1_4, bcard1_5]
        service.saveQuiz(blocksQuiz1)
        
        // MARK: - Blocks Quiz 2: Các thiên hà nổi tiếng
        let blocksQuiz2 = Quiz(
            id: baseId + 302,
            title: "Thiên hà nổi tiếng",
            quizDescription: "Khám phá những thiên hà đặc biệt",
            isPublic: false,
            createdBy: nil,
            categories: ["Blocks"]
        )

        let bcard2_1 = Card(term: "Ngân Hà", definition: "Thiên hà xoắn ốc chứa Hệ Mặt Trời", hint: "Có thanh ngang trung tâm", imageData: imageData(named: "cosmos_background2"))
        bcard2_1.id = baseId + 321
        bcard2_1.quiz = blocksQuiz2

        let bcard2_2 = Card(term: "Andromeda", definition: "Thiên hà gần nhất với Ngân Hà", hint: "Có thể thấy bằng mắt thường", imageData: imageData(named: "Andromeda"))
        bcard2_2.id = baseId + 322
        bcard2_2.quiz = blocksQuiz2

        let bcard2_3 = Card(term: "Sombrero", definition: "Thiên hà có vành sáng giống mũ", hint: "Tên khoa học M104", imageData: imageData(named: "Andromeda04"))
        bcard2_3.id = baseId + 323
        bcard2_3.quiz = blocksQuiz2

        let bcard2_4 = Card(term: "Centaurus A", definition: "Thiên hà radio mạnh", hint: "Có hố đen siêu khối lượng", imageData: imageData(named: "Andromeda05"))
        bcard2_4.id = baseId + 324
        bcard2_4.quiz = blocksQuiz2

        blocksQuiz2.cards = [bcard2_1, bcard2_2, bcard2_3, bcard2_4]
        service.saveQuiz(blocksQuiz2)

        // MARK: - Blocks Quiz 3: Các ngôi sao sáng nhất
        let blocksQuiz3 = Quiz(
            id: baseId + 303,
            title: "Ngôi sao sáng nhất",
            quizDescription: "Top ngôi sao rực rỡ trên bầu trời",
            isPublic: false,
            createdBy: nil,
            categories: ["Blocks"]
        )

        let bcard3_1 = Card(term: "Sirius", definition: "Ngôi sao sáng nhất bầu trời đêm", hint: "Thuộc chòm sao Canis Major", imageData: imageData(named: "Sirius"))
        bcard3_1.id = baseId + 331
        bcard3_1.quiz = blocksQuiz3

        let bcard3_2 = Card(term: "Canopus", definition: "Ngôi sao sáng thứ 2", hint: "Nằm ở Nam bán cầu", imageData: imageData(named: "Canopus"))
        bcard3_2.id = baseId + 332
        bcard3_2.quiz = blocksQuiz3

        let bcard3_3 = Card(term: "Rigel", definition: "Ngôi sao xanh khổng lồ trong Orion", hint: "Sáng gấp 120.000 lần Mặt Trời", imageData: imageData(named: "Canopus05"))
        bcard3_3.id = baseId + 333
        bcard3_3.quiz = blocksQuiz3

        let bcard3_4 = Card(term: "Vega", definition: "Ngôi sao sáng trong chòm Lyra", hint: "Dùng để hiệu chuẩn độ sáng", imageData: imageData(named: "Sirius05"))
        bcard3_4.id = baseId + 334
        bcard3_4.quiz = blocksQuiz3

        blocksQuiz3.cards = [bcard3_1, bcard3_2, bcard3_3, bcard3_4]
        service.saveQuiz(blocksQuiz3)
        
        // MARK: - Blast Quiz 1: Các hiện tượng vũ trụ
        let blastQuiz1 = Quiz(
            id: baseId + 401,
            title: "Hiện tượng vũ trụ",
            quizDescription: "Các hiện tượng đáng kinh ngạc trong không gian",
            isPublic: false,
            createdBy: nil,
            categories: ["Blast"]
        )

        let blcard1_1 = Card(term: "Big Bang", definition: "Vụ nổ lớn tạo ra vũ trụ", hint: "Xảy ra khoảng 13.8 tỷ năm trước", imageData: imageData(named: "cosmos_background"))
        blcard1_1.id = baseId + 411
        blcard1_1.quiz = blastQuiz1

        let blcard1_2 = Card(term: "Sao băng", definition: "Vật thể cháy sáng khi rơi vào khí quyển", hint: "Thường từ sao chổi hoặc tiểu hành tinh", imageData: imageData(named: "AlphaCentauri03"))
        blcard1_2.id = baseId + 412
        blcard1_2.quiz = blastQuiz1

        let blcard1_3 = Card(term: "Lỗ đen siêu khối lượng", definition: "Hố đen ở trung tâm thiên hà", hint: "Có khối lượng hàng triệu Mặt Trời", imageData: imageData(named: "BlackHole"))
        blcard1_3.id = baseId + 413
        blcard1_3.quiz = blastQuiz1

        let blcard1_4 = Card(term: "Sao đôi", definition: "Hai ngôi sao quay quanh nhau", hint: "Có thể tạo ra sóng hấp dẫn", imageData: imageData(named: "Canopus06"))
        blcard1_4.id = baseId + 414
        blcard1_4.quiz = blastQuiz1

        blastQuiz1.cards = [blcard1_1, blcard1_2, blcard1_3, blcard1_4]
        service.saveQuiz(blastQuiz1)
        
        // MARK: - Blast Quiz 2: Các hành tinh lùn
        let blastQuiz2 = Quiz(
            id: baseId + 402,
            title: "Hành tinh lùn",
            quizDescription: "Những thế giới nhỏ nhưng đặc biệt",
            isPublic: false,
            createdBy: nil,
            categories: ["Blast"]
        )

        let blcard2_1 = Card(term: "Pluto", definition: "Hành tinh lùn nổi tiếng nhất", hint: "Có 5 vệ tinh, lớn nhất là Charon", imageData: imageData(named: "Kepler452B"))
        blcard2_1.id = baseId + 421
        blcard2_1.quiz = blastQuiz2

        let blcard2_2 = Card(term: "Eris", definition: "Hành tinh lùn xa nhất", hint: "Lớn hơn Pluto một chút", imageData: imageData(named: "Cancri55E02"))
        blcard2_2.id = baseId + 422
        blcard2_2.quiz = blastQuiz2

        let blcard2_3 = Card(term: "Ceres", definition: "Hành tinh lùn trong vành đai tiểu hành tinh", hint: "Là tiểu hành tinh lớn nhất", imageData: imageData(named: "Cancri55E03"))
        blcard2_3.id = baseId + 423
        blcard2_3.quiz = blastQuiz2

        let blcard2_4 = Card(term: "Makemake", definition: "Hành tinh lùn ở vành đai Kuiper", hint: "Không có vệ tinh", imageData: imageData(named: "Kepler452B05"))
        blcard2_4.id = baseId + 424
        blcard2_4.quiz = blastQuiz2

        blastQuiz2.cards = [blcard2_1, blcard2_2, blcard2_3, blcard2_4]
        service.saveQuiz(blastQuiz2)

        // MARK: - Blast Quiz 3: Các hiện tượng thiên văn
        let blastQuiz3 = Quiz(
            id: baseId + 403,
            title: "Hiện tượng thiên văn",
            quizDescription: "Các sự kiện hiếm có trên bầu trời",
            isPublic: false,
            createdBy: nil,
            categories: ["Blast"]
        )

        let blcard3_1 = Card(term: "Siêu tân tinh", definition: "Vụ nổ sao cực mạnh", hint: "Có thể sáng hơn cả thiên hà", imageData: imageData(named: "ProximaB02"))
        blcard3_1.id = baseId + 431
        blcard3_1.quiz = blastQuiz3

        let blcard3_2 = Card(term: "Sao chổi", definition: "Khối băng phát sáng khi gần Mặt Trời", hint: "Có đuôi dài hàng triệu km", imageData: imageData(named: "ProximaB01"))
        blcard3_2.id = baseId + 432
        blcard3_2.quiz = blastQuiz3

        let blcard3_3 = Card(term: "Mưa sao băng", definition: "Nhiều sao băng cùng lúc", hint: "Từ bụi sao chổi", imageData: imageData(named: "ProximaB04"))
        blcard3_3.id = baseId + 433
        blcard3_3.quiz = blastQuiz3

        let blcard3_4 = Card(term: "Nhật thực toàn phần", definition: "Mặt Trăng che kín Mặt Trời", hint: "Chỉ thấy ở dải hẹp trên Trái Đất", imageData: imageData(named: "ProximaB03"))
        blcard3_4.id = baseId + 434
        blcard3_4.quiz = blastQuiz3

        blastQuiz3.cards = [blcard3_1, blcard3_2, blcard3_3, blcard3_4]
        service.saveQuiz(blastQuiz3)
        
        // MARK: - Match Quiz 1: Các chòm sao nổi bật
        let matchQuiz1 = Quiz(
            id: baseId + 501,
            title: "Chòm sao nổi bật",
            quizDescription: "Ghép đôi tên và đặc điểm của chòm sao",
            isPublic: false,
            createdBy: nil,
            categories: ["Match"]
        )

        let mcard1_1 = Card(term: "Orion", definition: "Chòm sao Thợ Săn với Betelgeuse", hint: "Dễ thấy vào mùa đông", imageData: imageData(named: "Orion"))
        mcard1_1.id = baseId + 511
        mcard1_1.quiz = matchQuiz1

        let mcard1_2 = Card(term: "Ursa Major", definition: "Chòm sao Gấu Lớn chứa Bắc Đẩu", hint: "Dùng để tìm Sao Bắc Cực", imageData: imageData(named: "TaurusZodiac"))
        mcard1_2.id = baseId + 512
        mcard1_2.quiz = matchQuiz1

        let mcard1_3 = Card(term: "Cassiopeia", definition: "Chòm sao Nữ Hoàng hình chữ W", hint: "Đối diện với Bắc Đẩu", imageData: imageData(named: "LeoZodiac"))
        mcard1_3.id = baseId + 513
        mcard1_3.quiz = matchQuiz1

        let mcard1_4 = Card(term: "Leo", definition: "Chòm sao Sư Tử với ngôi sao Regulus", hint: "Biểu tượng cung hoàng đạo", imageData: imageData(named: "leo_chibi"))
        mcard1_4.id = baseId + 514
        mcard1_4.quiz = matchQuiz1

        let mcard1_5 = Card(term: "Scorpius", definition: "Chòm sao Bọ Cạp với Antares đỏ", hint: "Có hình dạng giống bọ cạp", imageData: imageData(named: "taurus_chibi"))
        mcard1_5.id = baseId + 515
        mcard1_5.quiz = matchQuiz1

        matchQuiz1.cards = [mcard1_1, mcard1_2, mcard1_3, mcard1_4, mcard1_5]
        service.saveQuiz(matchQuiz1)
        
        // MARK: - Match Quiz 2: Vệ tinh nổi bật
        let matchQuiz2 = Quiz(
            id: baseId + 502,
            title: "Vệ tinh đặc biệt",
            quizDescription: "Ghép vệ tinh với hành tinh mẹ",
            isPublic: false,
            createdBy: nil,
            categories: ["Match"]
        )

        let mcard2_1 = Card(term: "Titan", definition: "Vệ tinh lớn nhất của Sao Thổ", hint: "Có khí quyển dày hơn Trái Đất", imageData: imageData(named: "Apollo11"))
        mcard2_1.id = baseId + 521
        mcard2_1.quiz = matchQuiz2

        let mcard2_2 = Card(term: "Ganymede", definition: "Vệ tinh lớn nhất Hệ Mặt Trời", hint: "Lớn hơn Sao Thủy", imageData: imageData(named: "CassiniProbe"))
        mcard2_2.id = baseId + 522
        mcard2_2.quiz = matchQuiz2

        let mcard2_3 = Card(term: "Europa", definition: "Vệ tinh có đại dương dưới băng", hint: "Có thể có sự sống", imageData: imageData(named: "JunoProbe"))
        mcard2_3.id = baseId + 523
        mcard2_3.quiz = matchQuiz2

        let mcard2_4 = Card(term: "Io", definition: "Vệ tinh có núi lửa hoạt động", hint: "Màu vàng do lưu huỳnh", imageData: imageData(named: "MercuryProbe"))
        mcard2_4.id = baseId + 524
        mcard2_4.quiz = matchQuiz2

        let mcard2_5 = Card(term: "Enceladus", definition: "Vệ tinh phun nước của Sao Thổ", hint: "Có đại dương ngầm", imageData: imageData(named: "ParkerProbe"))
        mcard2_5.id = baseId + 525
        mcard2_5.quiz = matchQuiz2

        matchQuiz2.cards = [mcard2_1, mcard2_2, mcard2_3, mcard2_4, mcard2_5]
        service.saveQuiz(matchQuiz2)

        // MARK: - Match Quiz 3: Các loại sao
        let matchQuiz3 = Quiz(
            id: baseId + 503,
            title: "Phân loại sao",
            quizDescription: "Ghép loại sao với đặc điểm",
            isPublic: false,
            createdBy: nil,
            categories: ["Match"]
        )

        let mcard3_1 = Card(term: "Sao lùn đỏ", definition: "Ngôi sao nhỏ, mát, sống lâu", hint: "Chiếm 70% số sao", imageData: imageData(named: "AlphaCentauri06"))
        mcard3_1.id = baseId + 531
        mcard3_1.quiz = matchQuiz3

        let mcard3_2 = Card(term: "Sao khổng lồ đỏ", definition: "Ngôi sao lớn, mát, giai đoạn cuối", hint: "Có thể nuốt chửng hành tinh", imageData: imageData(named: "AlphaCentauri"))
        mcard3_2.id = baseId + 532
        mcard3_2.quiz = matchQuiz3

        let mcard3_3 = Card(term: "Sao neutron", definition: "Tàn dư siêu đặc của sao lớn", hint: "1 thìa nặng tỷ tấn", imageData: imageData(named: "Canopus02"))
        mcard3_3.id = baseId + 533
        mcard3_3.quiz = matchQuiz3

        let mcard3_4 = Card(term: "Sao lùn trắng", definition: "Tàn dư của sao giống Mặt Trời", hint: "Kích thước bằng Trái Đất", imageData: imageData(named: "Canopus"))
        mcard3_4.id = baseId + 534
        mcard3_4.quiz = matchQuiz3

        matchQuiz3.cards = [mcard3_1, mcard3_2, mcard3_3, mcard3_4]
        service.saveQuiz(matchQuiz3)
        
        // Lưu tất cả
        do {
            try context.save()
            hasInsertedSamples = true
            print("Sample quizzes inserted successfully")
        } catch {
            print("Error saving sample quizzes: \(error)")
        }
    }

        private func imageData(named name: String) -> Data? {
            guard let image = UIImage(named: name) else {
                print("Warning: Image '\(name)' not found in asset catalog.")
                return nil
            }
            return image.jpegData(compressionQuality: 0.8)
        }
}

// MARK: - AddEditQuizViewModel
@MainActor
class AddEditQuizViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var isPublic: Bool = false
    @Published var selectedCategories: Set<String> = []
    @Published var cards: [Card] = []
    @Published var selectedImage: PhotosPickerItem?
    @Published var errorMessage: String?
    
    public var isEdit: Bool
    public var quiz: Quiz?
    public let service: SwiftDataService
    private let currentUserId: UUID
    
    init(service: SwiftDataService, quiz: Quiz? = nil) {
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        if let quiz = quiz {
            self.isEdit = true
            self.quiz = quiz
            self.title = quiz.title
            self.description = quiz.quizDescription
            self.isPublic = quiz.isPublic
            self.selectedCategories = Set(quiz.categories)
            self.cards = quiz.cards
        } else {
            self.isEdit = false
        }
    }
    
    func save() {
            guard !title.isEmpty else {
                errorMessage = "Title is required"
                return
            }

            let materializedCategories = Array(selectedCategories)
                .map { String($0) }
                .sorted()
            
            var safeCopy = materializedCategories
            safeCopy.append("_force_copy")
            safeCopy.removeLast()

            if isEdit, let quiz = quiz {
                quiz.update(
                    updatedTitle: title,
                    updatedDescription: description,
                    updatedIsPublic: isPublic,
                    updatedCategories: safeCopy
                )
                quiz.cards = cards
                service.updateQuiz(quiz)
            } else {
                let newQuiz = Quiz(
                    title: title,
                    quizDescription: description,
                    isPublic: isPublic,
                    createdBy: currentUserId,
                    categories: safeCopy
                )
                newQuiz.cards = cards
                service.saveQuiz(newQuiz)
            }
        }
    
    func addCard(term: String, definition: String, hint: String?, imageData: Data?, termFormatting: Data?, definitionFormatting: Data?) {
        let newCard = Card(
            term: term,
            definition: definition,
            hint: hint,
            imageData: imageData,
            termFormatting: termFormatting,
            definitionFormatting: definitionFormatting
        )
        newCard.id = Int64(Date().timeIntervalSince1970 * 1000) + Int64.random(in: 0..<1000)
        cards.append(newCard)
    }
    
    func updateCard(_ card: Card, term: String, definition: String, hint: String?, imageData: Data?, termFormatting: Data?, definitionFormatting: Data?) {
        card.update(updatedTerm: term, updatedDefinition: definition, updatedHint: hint, updatedImageData: imageData, updatedTermFormatting: termFormatting, updatedDefinitionFormatting: definitionFormatting)
    }
    
    func deleteCard(_ card: Card) {
        cards.removeAll { $0.id == card.id }
    }
    
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if (try await item.loadTransferable(type: Data.self)) != nil {
            }
        } catch {
            errorMessage = "Error loading image"
        }
    }
}

// MARK: - FlashcardsViewModel
@MainActor
class FlashcardsViewModel: ObservableObject {
    @Published var currentCard: Card?
    @Published var showAnswer: Bool = false
    @Published var showHint: Bool = false
    @Published var showEdit: Bool = false
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var isFavorite: Bool = false
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    public let currentUserId: UUID

    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        
            if quiz.id == 0 {
                quiz.id = Int64(Date().timeIntervalSince1970 * 1000)
            }
        
        service.saveQuiz(quiz)
        
        self.attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Flashcards", userId: currentUserId)
    }
    
    public func loadCurrentCard() {
        if attempt.currentIndex < quiz.cards.count {
            currentCard = quiz.cards[attempt.currentIndex]
            isFavorite = service.isFavorite(cardId: currentCard?.id ?? 0, userId: currentUserId)
            showEdit = quiz.createdBy == currentUserId
        } else {
            isCompleted = true
            correctCount = attempt.correctCount
            incorrectCount = attempt.incorrectCount
        }
    }
    
    func flipCard() {
        showAnswer.toggle()
    }
    
    func nextCard(correct: Bool) {
        guard let cardId = currentCard?.id else { return }
        attempt.updateProgress(correct: correct, cardId: cardId)
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    func previousCard() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
            loadCurrentCard()
        }
    }
    
    func toggleFavorite() {
        guard let cardId = currentCard?.id else { return }
        if isFavorite {
            service.removeFavorite(cardId: cardId, userId: currentUserId)
        } else {
            service.addFavorite(cardId: cardId, quizId: quiz.id, userId: currentUserId)
        }
        isFavorite.toggle()
    }
    
    func reset() {
        attempt.isCompleted = false
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    func backToLast() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
            loadCurrentCard()
        }
    }
    
    func createSampleFlashcards() {
        let sampleFlashcards = Quiz(
            title: "Sample Flashcards",
            quizDescription: "Demo flashcards",
            isPublic: true,
            createdBy: nil,
            categories: ["Flashcards"]
        )
        let card1 = Card(term: "Cosmos", definition: "Wowwwww")
        card1.id = 1
        let card2 = Card(term: "Universe", definition: "Naniiiiii")
        card2.id = 2
        sampleFlashcards.cards = [card1, card2]
        service.saveQuiz(sampleFlashcards)
    }
    
    var totalCount: Int {
        quiz.cards.count
    }
}

// MARK: - LearnViewModel
@MainActor
class LearnViewModel: ObservableObject {
    @Published var currentCard: Card?
    @Published var options: [String] = []
    @Published var selectedOption: String?
    @Published var showHint: Bool = false
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var isFavorite: Bool = false
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    private let currentUserId: UUID
    
    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        self.attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Learn", userId: currentUserId)
        
        self.attempt.currentIndex = 0
        self.attempt.isCompleted = false
        service.updateAttempt(self.attempt)
        loadCurrentCard()
    }
    
    public func loadCurrentCard() {
        if attempt.currentIndex < quiz.cards.count {
            currentCard = quiz.cards[attempt.currentIndex]
            generateOptions()
            isFavorite = service.isFavorite(cardId: currentCard?.id ?? 0, userId: currentUserId)
        } else {
            isCompleted = true
            correctCount = attempt.correctCount
            incorrectCount = attempt.incorrectCount
        }
    }
    
    private func generateOptions() {
        guard let correct = currentCard?.definition else { return }
        let wrongs = quiz.cards
            .filter { $0.id != currentCard?.id }
            .map { $0.definition }
            .shuffled()
            .prefix(3)
        options = (Array(wrongs) + [correct]).shuffled()
    }
    
    func selectOption(_ option: String) {
            selectedOption = option
            let correct = option == currentCard?.definition
            let cardId = currentCard?.id ?? 0

            attempt.updateProgress(correct: correct, cardId: cardId)
            service.updateAttempt(attempt)

        }

        func dontKnow() {
            selectedOption = currentCard?.definition
            let cardId = currentCard?.id ?? 0
            
            attempt.updateProgress(correct: false, cardId: cardId)
            service.updateAttempt(attempt)
            
        }
        
        func nextCard() {
            service.updateAttempt(attempt)
            
            selectedOption = nil
            loadCurrentCard()
        }
    
    func toggleFavorite() {
        guard let cardId = currentCard?.id else { return }
        if isFavorite {
            service.removeFavorite(cardId: cardId, userId: currentUserId)
        } else {
            service.addFavorite(cardId: cardId, quizId: quiz.id, userId: currentUserId)
        }
        isFavorite.toggle()
    }
    
    func reset() {
        attempt.isCompleted = false
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    func backToLast() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
            loadCurrentCard()
        }
    }
}

// MARK: - TestViewModel
@MainActor
class TestViewModel: ObservableObject {
    @Published var selectedTypes: Set<String> = ["Multiple Choice", "True or False", "Written", "Fill in the Blank"]
    @Published var currentCard: Card?
    @Published var currentType: String = ""
    @Published var options: [String] = []
    @Published var userAnswer: String = ""
    @Published var isTrueFalse: Bool?
    @Published var displayedDefinition: String = ""
    @Published var blankedTerm: String = ""
    @Published var fillOptions: [String] = []
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    private let currentUserId: UUID
    
    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        self.attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Test", userId: currentUserId)
    }
    
    func startTest() {
        guard !selectedTypes.isEmpty else { return }
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        attempt.isCompleted = false
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    private func loadCurrentCard() {
        if attempt.currentIndex < quiz.cards.count {
            currentCard = quiz.cards[attempt.currentIndex]
            currentType = selectedTypes.randomElement() ?? "Multiple Choice"
            userAnswer = ""
            isTrueFalse = nil
            displayedDefinition = ""
            blankedTerm = ""
            fillOptions = []
            
            switch currentType {
            case "Multiple Choice":
                generateMCOptions()
            case "True or False":
                generateTrueFalse()
            case "Fill in the Blank":
                generateFillInBlank()
            case "Written":
                break
            default: break
            }
        } else {
            isCompleted = true
            correctCount = attempt.correctCount
            incorrectCount = attempt.incorrectCount
        }
    }
    
    private func generateMCOptions() {
        guard let correct = currentCard?.definition else { return }
        let wrongs = quiz.cards
            .filter { $0.id != currentCard?.id }
            .map { $0.definition }
            .shuffled()
            .prefix(3)
        options = (Array(wrongs) + [correct]).shuffled()
    }
    
    private func generateTrueFalse() {
        guard let correctDef = currentCard?.definition else { return }
        let isCorrect = Bool.random()
        if isCorrect {
            displayedDefinition = correctDef
        } else {
            let wrong = quiz.cards
                .filter { $0.id != currentCard?.id }
                .map { $0.definition }
                .randomElement() ?? correctDef
            displayedDefinition = wrong
        }
    }
    
    private func generateFillInBlank() {
        guard let term = currentCard?.term, let correctDef = currentCard?.definition else { return }
        let words = term.split(separator: " ").map(String.init)
        guard words.count > 1, let blankIndex = words.indices.randomElement() else {
            blankedTerm = "_____"
            return
        }
        
        var blanked = words
        blanked[blankIndex] = "_____"
        blankedTerm = blanked.joined(separator: " ")
        
        // 4 đáp án: 1 đúng + 3 sai
        let wrongs = quiz.cards
            .filter { $0.id != currentCard?.id }
            .map { $0.definition }
            .shuffled()
            .prefix(3)
        fillOptions = (Array(wrongs) + [correctDef]).shuffled()
    }
    
    func submitAnswer() {
        var correct = false
        let originalDef = quiz.cards.first { $0.id == currentCard?.id }?.definition ?? ""
        
        switch currentType {
        case "Multiple Choice":
            correct = userAnswer == originalDef
        case "True or False":
            let isCurrentlyCorrect = (displayedDefinition == originalDef)
            correct = (isTrueFalse == true && isCurrentlyCorrect) || (isTrueFalse == false && !isCurrentlyCorrect)
        case "Written":
            let normalizedUser = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedCorrect = originalDef.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            correct = normalizedUser == normalizedCorrect
        case "Fill in the Blank":
            correct = userAnswer == originalDef
        default: break
        }
        
        attempt.updateProgress(correct: correct, cardId: currentCard?.id ?? 0, userAnswer: userAnswer)
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    func dontKnow() {
        attempt.updateProgress(correct: false, cardId: currentCard?.id ?? 0)
        service.updateAttempt(attempt)
        loadCurrentCard()
    }
    
    func reset() {
        attempt.isCompleted = false
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        service.updateAttempt(attempt)
        selectedTypes = ["Multiple Choice", "True or False", "Written", "Fill in the Blank"]
        
        isCompleted = false
        loadCurrentCard()
    }
    
    func backToLast() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
            loadCurrentCard()
        }
    }
}

// MARK: - BlocksViewModel
@MainActor
class BlocksViewModel: ObservableObject {
    @Published var grid: [[Bool]] = Array(repeating: Array(repeating: false, count: 10), count: 10)
    @Published var currentShape: [[Int]] = []
    @Published var dragPosition: CGPoint = .zero
    @Published var showQuestion: Bool = false
    @Published var currentCard: Card?
    @Published var userAnswer: String = ""
    @Published var attemptsLeft: Int = 3
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    private let currentUserId: UUID
    public var placeCount: Int = 0
    
    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        self.attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Blocks", userId: currentUserId)
    }
    
    func generateNextShape() {
        let size = Int.random(in: 1...3)
        currentShape = Array(repeating: Array(repeating: 1, count: size), count: size)
    }
    
    // MARK: - Đặt khối vào lưới
    func placeShape() {
        placeCount += 1
        if placeCount % 2 == 0 {
            showQuestion = true
            currentCard = quiz.cards.randomElement()
        }
        
        // Kiểm tra hoàn thành: khi đủ số lần đặt = số câu hỏi × 2
        if placeCount >= quiz.cards.count * 2 {
            isCompleted = true
            correctCount = attempt.correctCount
            incorrectCount = attempt.incorrectCount
        }
    }
    
    // MARK: - Kiểm tra và đặt khối vào lưới
    func canPlaceShape(at gridX: Int, _ gridY: Int) -> Bool {
        let h = currentShape.count
        let w = currentShape[0].count
        guard gridX >= 0, gridY >= 0, gridX + w <= 10, gridY + h <= 10 else { return false }
        
        for y in 0..<h {
            for x in 0..<w where currentShape[y][x] == 1 {
                if grid[gridY + y][gridX + x] { return false }
            }
        }
        return true
    }
    
    func placeShapeInGrid(at gridX: Int, _ gridY: Int) {
        var newGrid = grid
        let h = currentShape.count
        let w = currentShape[0].count
        for y in 0..<h {
            for x in 0..<w where currentShape[y][x] == 1 {
                newGrid[gridY + y][gridX + x] = true
            }
        }
        grid = newGrid
    }
    
    func submitAnswer() {
        let correct = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                     currentCard?.definition.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if correct {
            attempt.updateProgress(correct: true, cardId: currentCard?.id ?? 0, userAnswer: userAnswer)
            showQuestion = false
            userAnswer = ""
        } else {
            attemptsLeft -= 1
            if attemptsLeft == 0 {
                resetGridAndAttempts()
            }
        }
        service.updateAttempt(attempt)
    }
    
    private func resetGridAndAttempts() {
        grid = Array(repeating: Array(repeating: false, count: 10), count: 10)
        attemptsLeft = 3
        placeCount = 0
        showQuestion = false
        userAnswer = ""
    }
    
    func reset() {
        resetGridAndAttempts()
        attempt.isCompleted = false
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        service.updateAttempt(attempt)
        generateNextShape()
    }
    
    func backToLast() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
        }
    }
    
    private func loadCurrentCard() { }
}

// MARK: - BlastViewModel
@MainActor
class BlastViewModel: ObservableObject {
    @Published var currentCard: Card?
    @Published var floatingOptions: [(String, CGPoint)] = []
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    private let currentUserId: UUID
    
    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        self.attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Blast", userId: currentUserId)
        loadCurrentCard()
    }
    
    func loadCurrentCard() {
        if quiz.cards.isEmpty {
            isCompleted = true
            return
        }
        if attempt.currentIndex < quiz.cards.count {
            currentCard = quiz.cards[attempt.currentIndex]
            generateFloatingOptions()
        } else {
            isCompleted = true
            correctCount = attempt.correctCount
            incorrectCount = attempt.incorrectCount
        }
    }
    
    func generateFloatingOptions() {
        guard let correct = currentCard?.definition else { return }
        let wrongs = quiz.cards
            .filter { $0.id != currentCard?.id }
            .map { $0.definition }
            .shuffled()
            .prefix(3)
        let allOptions = (Array(wrongs) + [correct]).shuffled()
        
        var positions: [CGPoint] = []
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let minDistance: CGFloat = 100
        
        for _ in 0..<allOptions.count {
            var newPosition: CGPoint
            var isValid: Bool
            repeat {
                isValid = true
                newPosition = CGPoint(
                    x: CGFloat.random(in: 50...(screenWidth - 50)),
                    y: CGFloat.random(in: 150...(screenHeight / 2))
                )
                for existing in positions {
                    let distance = hypot(newPosition.x - existing.x, newPosition.y - existing.y)
                    if distance < minDistance {
                        isValid = false
                        break
                    }
                }
            } while !isValid
            positions.append(newPosition)
        }
        
        floatingOptions = Array(zip(allOptions, positions))
    }
    
    func tapOption(_ option: String) {
        guard let cardId = currentCard?.id else { return }
        let correct = option == currentCard?.definition
        attempt.updateProgress(correct: correct, cardId: cardId)
        service.updateAttempt(attempt)
        correctCount = attempt.correctCount
        incorrectCount = attempt.incorrectCount
        loadCurrentCard()
    }
    
    func reset() {
        attempt.isCompleted = false
        attempt.currentIndex = 0
        attempt.correctCount = 0
        attempt.incorrectCount = 0
        attempt.userAnswers = [:]
        attempt.correctCards = []
        service.updateAttempt(attempt)
        correctCount = 0
        incorrectCount = 0
        isCompleted = false
        loadCurrentCard()
    }
    
    func backToLast() {
        if attempt.currentIndex > 0 {
            attempt.currentIndex -= 1
            service.updateAttempt(attempt)
            loadCurrentCard()
        }
    }
}

// MARK: - MatchViewModel
@MainActor
class MatchViewModel: ObservableObject {
    @Published var gridItems: [MatchItem] = []
    @Published var selectedItem1: MatchItem?
    @Published var selectedItem2: MatchItem?
    @Published var matchedPairs: Set<Int64> = []
    @Published var isCompleted: Bool = false
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    
    public var quiz: Quiz
    public var attempt: Attempt
    public let service: SwiftDataService
    private let currentUserId: UUID
    
    private let gridSize = 4 // 4x4
    
    init(quiz: Quiz, service: SwiftDataService) {
        self.quiz = quiz
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        
        self.attempt = Attempt(userId: currentUserId, quizId: quiz.id, mode: "Match")
        
        if quiz.id == 0 {
            quiz.id = Int64(Date().timeIntervalSince1970 * 1000)
            service.saveQuiz(quiz)
        }
        
    }

    func startMatch() {
        let attempt = service.loadOrCreateAttempt(for: quiz.id, mode: "Match", userId: currentUserId)
        self.attempt = attempt
        
        setupGrid()
        loadCurrentCard()
    }
    
    func setupGrid() {
        guard quiz.cards.count >= 8 else {
            let cards = quiz.cards.shuffled()
            let selected = Array(cards.prefix(8))
            createGrid(from: selected)
            return
        }
        
        let selected = Array(quiz.cards.prefix(8))
        createGrid(from: selected)
    }
    
    private func createGrid(from cards: [Card]) {
        var items: [MatchItem] = []
        
        for card in cards {
            let termItem = MatchItem(
                id: UUID(),
                cardId: card.id,
                text: card.term,
                type: .term
            )
            let defItem = MatchItem(
                id: UUID(),
                cardId: card.id,
                text: card.definition,
                type: .definition
            )
            items.append(termItem)
            items.append(defItem)
        }
        
        self.gridItems = items.shuffled()
        resetSelection()
    }
    
    func selectItem(_ item: MatchItem) {
        guard !matchedPairs.contains(item.cardId) else { return }
        
        if selectedItem1 == nil {
            selectedItem1 = item
        } else if selectedItem2 == nil {
            selectedItem2 = item
            checkMatch()
        }
    }
    
    private func checkMatch() {
        guard let item1 = selectedItem1, let item2 = selectedItem2 else { return }
        
        let isMatch = item1.cardId == item2.cardId && item1.type != item2.type
        
        if isMatch {
                matchedPairs.insert(item1.cardId)
                attempt.updateProgress(correct: true, cardId: item1.cardId)
                service.updateAttempt(attempt)
            
            let totalPairs = gridItems.count / 2
            if matchedPairs.count == totalPairs {
                attempt.isCompleted = true
                service.updateAttempt(attempt)
                isCompleted = true
            }
        } else {
                attempt.updateProgress(correct: false, cardId: item1.cardId)
                service.updateAttempt(attempt)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.resetSelection()
            }
        }
        
        correctCount = attempt.correctCount
        incorrectCount = attempt.incorrectCount
        
        if isMatch {
            withAnimation(.easeInOut) {
                self.resetSelection()
            }
        }
    }
    
    private func resetSelection() {
        selectedItem1 = nil
        selectedItem2 = nil
    }
    
    func reset() {
        matchedPairs = []
        correctCount = 0
        incorrectCount = 0
        isCompleted = false

        let newAttempt = Attempt(userId: currentUserId, quizId: quiz.id, mode: "Match")
        service.container.mainContext.insert(newAttempt)
        try? service.container.mainContext.save()
        service.saveOrUpdateAttempt(newAttempt, isUpdate: false)

        self.attempt = newAttempt
        setupGrid()
    }
    
    func backToLast() {}
    
    // MARK: - Load Current Card
    private func loadCurrentCard() {
        correctCount = attempt.correctCount
        incorrectCount = attempt.incorrectCount
        isCompleted = attempt.isCompleted
    }
}

// MARK: - Match Item Model
struct MatchItem: Identifiable, Equatable {
    let id: UUID
    let cardId: Int64
    let text: String
    let type: ItemType
    
    enum ItemType {
        case term, definition
    }
    
    static func == (lhs: MatchItem, rhs: MatchItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - FavoritesViewModel
@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var cards: [Card] = []
    
    private let service: SwiftDataService
    private let currentUserId: UUID
    
    init(service: SwiftDataService) {
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        loadFavorites()
    }
    
    func loadFavorites() {
        let context = service.container.mainContext
        let userId = self.currentUserId
        
        let predicate = #Predicate<Favorite> { $0.userId == userId }
        let descriptor = FetchDescriptor<Favorite>(predicate: predicate, sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        do {
            favorites = try context.fetch(descriptor)
        } catch {
            print("Error loading favorites: \(error)")
        }
    }
    
    func removeFavorite(_ favorite: Favorite) {
        service.removeFavorite(cardId: favorite.cardId, userId: currentUserId)
        loadFavorites()
    }
}

// MARK: - EducationViewModel
@MainActor
class EducationViewModel: ObservableObject {
    @Published var streakDays: Int = 0
    @Published var weeklyCompletions: [Bool] = Array(repeating: false, count: 7)
    
    private let service: SwiftDataService
    private let currentUserId: UUID
    private var userProgress: UserProgress?
    
    init(service: SwiftDataService) {
        self.service = service
        self.currentUserId = AuthManager.shared.currentUserId ?? UUID()
        loadProgress()
    }
    
    func loadProgress() {
        let context = service.container.mainContext
        let userId = self.currentUserId
        
        let predicate = #Predicate<UserProgress> { $0.userId == userId }
        do {
            if let progress = try context.fetch(FetchDescriptor<UserProgress>(predicate: predicate)).first {
                userProgress = progress
                streakDays = progress.streakDays
                weeklyCompletions = progress.weeklyCompletions
            } else {
                userProgress = UserProgress(userId: currentUserId)
                context.insert(userProgress!)
                try context.save()
            }
        } catch {
            print("Error loading progress: \(error)")
        }
    }
    
    func markSessionComplete() {
        userProgress?.markCompletion()
        if let progress = userProgress {
            streakDays = progress.streakDays
            weeklyCompletions = progress.weeklyCompletions
            service.updateUserProgress(progress)
        }
    }
    
    func resetWeekly() {
        userProgress?.resetWeekly()
        if let progress = userProgress {
            weeklyCompletions = progress.weeklyCompletions
            service.updateUserProgress(progress)
        }
    }
}
