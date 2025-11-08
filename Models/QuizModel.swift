//
//  QuizModel.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 31/10/25.
//

import Foundation
import SwiftData

@Model
class Quiz {
    @Attribute(.unique) var id: Int64
    var title: String
    var quizDescription: String
    var isPublic: Bool
    var createdBy: UUID?
    var createdAt: Date
    var updatedAt: Date
    
    @Attribute(.transformable(by: StringArrayTransformer.self))
    var categoriesData: Data? = nil
    
    @Transient
    var categories: [String] {
        get {
            guard let data = categoriesData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            if newValue.isEmpty {
                categoriesData = nil
            } else {
                let data = try? JSONEncoder().encode(newValue)
                categoriesData = data.map { Data($0) }
            }
        }
    }
    
    @Relationship(deleteRule: .cascade) var cards: [Card] = []

    init(id: Int64 = 0, title: String, quizDescription: String, isPublic: Bool, createdBy: UUID?, categories: [String]) {
        self.id = id
        self.title = title
        self.quizDescription = quizDescription
        self.isPublic = isPublic
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
        self.categories = categories
    }

    func update(updatedTitle: String? = nil, updatedDescription: String? = nil, updatedIsPublic: Bool? = nil, updatedCategories: [String]? = nil) {
        if let updatedTitle { self.title = updatedTitle }
        if let updatedDescription { self.quizDescription = updatedDescription }
        if let updatedIsPublic { self.isPublic = updatedIsPublic }
        if let updatedCategories {
            let materialized: [String] = updatedCategories
                .map { $0 }
                .compactMap { $0 as String? }
                .map { String($0) }
                .sorted()

            self.categories = Array(materialized)
        }
        self.updatedAt = Date()
    }
}

@Model
class Card {
    @Attribute(.unique) var id: Int64
    var term: String
    var definition: String
    var hint: String?
    var imageData: Data?
    var termFormatting: Data?
    var definitionFormatting: Data?
    
    @Relationship(inverse: \Quiz.cards) var quiz: Quiz?

    init(id: Int64 = 0, term: String, definition: String, hint: String? = nil, imageData: Data? = nil, termFormatting: Data? = nil, definitionFormatting: Data? = nil) {
        self.id = id
        self.term = term
        self.definition = definition
        self.hint = hint
        self.imageData = imageData
        self.termFormatting = termFormatting
        self.definitionFormatting = definitionFormatting
    }
}

extension Card {
    func update(
        updatedTerm: String,
        updatedDefinition: String,
        updatedHint: String? = nil,
        updatedImageData: Data? = nil,
        updatedTermFormatting: Data? = nil,
        updatedDefinitionFormatting: Data? = nil
    ) {
        self.term = updatedTerm
        self.definition = updatedDefinition
        self.hint = updatedHint
        self.imageData = updatedImageData
        self.termFormatting = updatedTermFormatting
        self.definitionFormatting = updatedDefinitionFormatting
    }
}

@Model
class Attempt {
    @Attribute(.unique) var id: Int64
    var userId: UUID
    var quizId: Int64
    var mode: String
    var startedAt: Date
    var lastUpdated: Date
    var isCompleted: Bool
    var currentIndex: Int
    var correctCount: Int
    var incorrectCount: Int
    var userAnswers: [Int64: String] = [:]
    var correctCardsPG: String = "{}"

        var correctCards: [Int64] {
            get {
                guard correctCardsPG != "{}" else { return [] }
                let cleaned = correctCardsPG
                    .replacingOccurrences(of: "{", with: "")
                    .replacingOccurrences(of: "}", with: "")
                return cleaned
                    .split(separator: ",")
                    .compactMap { Int64($0) }
            }
            set {
                if newValue.isEmpty {
                    correctCardsPG = "{}"
                } else {
                    correctCardsPG = "{" + newValue.map { String($0) }.joined(separator: ",") + "}"
                }
            }
        }

    init(id: Int64 = 0, userId: UUID, quizId: Int64, mode: String) {
        self.id = id
        self.userId = userId
        self.quizId = quizId
        self.mode = mode
        self.startedAt = Date()
        self.lastUpdated = Date()
        self.isCompleted = false
        self.currentIndex = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.correctCards = []
    }

    func updateProgress(correct: Bool, cardId: Int64, userAnswer: String? = nil) {
        lastUpdated = Date()
        currentIndex += 1
        if correct {
            correctCount += 1
            var cards = self.correctCards
            if !cards.contains(cardId) {
                cards.append(cardId)
                self.correctCards = cards
            }
        } else {
            incorrectCount += 1
        }
        if let userAnswer { userAnswers[cardId] = userAnswer }
        if currentIndex >= 100 { isCompleted = true }
    }
}

@Model
class Favorite {
    @Attribute(.unique) var id: Int64
    var userId: UUID
    var cardId: Int64
    var quizId: Int64
    var addedAt: Date

    init(id: Int64 = 0, userId: UUID, cardId: Int64, quizId: Int64) {
        self.id = id
        self.userId = userId
        self.cardId = cardId
        self.quizId = quizId
        self.addedAt = Date()
    }
}

// MARK: - UserProgress
@Model
class UserProgress {
    @Attribute(.unique) var userId: UUID
    var streakDays: Int = 0
    var lastCompletedDate: Date?
    var totalCompletions: Int = 0
    var weeklyCompletionsPG: String = "{}"

    @Transient
    var weeklyCompletions: [Bool] {
        get {
            guard weeklyCompletionsPG != "{}" else {
                return Array(repeating: false, count: 7)
            }
            let cleaned = weeklyCompletionsPG
                .dropFirst()
                .dropLast()
            return cleaned
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) == "t" }
        }
        set {
            let pgArray = newValue.map { $0 ? "t" : "f" }.joined(separator: ",")
            weeklyCompletionsPG = pgArray.isEmpty ? "{}" : "{\(pgArray)}"
        }
    }

    init(userId: UUID) {
        self.userId = userId
        self.streakDays = 0
        self.lastCompletedDate = nil
        self.weeklyCompletions = Array(repeating: false, count: 7)
        self.totalCompletions = 0
    }

    func markCompletion() {
        let today = Calendar.current.component(.weekday, from: Date()) - 1
        var week = weeklyCompletions
        week[today] = true
        weeklyCompletions = week
        
        if let last = lastCompletedDate,
           Calendar.current.isDateInToday(last) { return }
        
        if let last = lastCompletedDate,
           Calendar.current.isDate(last, inSameDayAs: Date().addingTimeInterval(-86400)) {
            streakDays += 1
        } else {
            streakDays = 1
        }
        
        lastCompletedDate = Date()
        totalCompletions += 1
    }

    func resetWeekly() {
        weeklyCompletions = Array(repeating: false, count: 7)
    }
}

@objc(StringArrayTransformer)
final class StringArrayTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return value
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return value
    }
}

extension ValueTransformer {
    static func registerIfNeeded() {
        let stringName = NSValueTransformerName("StringArrayTransformer")
        if ValueTransformer(forName: stringName) == nil {
            ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: stringName)
        }
    }
}
