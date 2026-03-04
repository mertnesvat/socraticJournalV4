// MockLearningContentService.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Foundation
@testable import SocraticJournal

/// Mock learning content service for testing
public final class MockLearningContentService: LearningContentServiceProtocol, @unchecked Sendable {

    // MARK: - Configurable Data

    public var articlesToReturn: [LearningArticle] = []

    // MARK: - Init

    public init() {}

    // MARK: - Protocol Methods

    public func getAllArticles() -> [LearningArticle] {
        articlesToReturn
    }

    public func getArticles(for category: LearningCategory) -> [LearningArticle] {
        articlesToReturn.filter { $0.category == category }
    }

    public func getArticle(by id: String) -> LearningArticle? {
        articlesToReturn.first { $0.id == id }
    }
}
