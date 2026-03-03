// LearningContentServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for learning content operations
public protocol LearningContentServiceProtocol: Sendable {
    func getAllArticles() -> [LearningArticle]
    func getArticles(for category: LearningCategory) -> [LearningArticle]
    func getArticle(by id: String) -> LearningArticle?
}
