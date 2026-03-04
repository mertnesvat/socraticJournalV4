// LearnFeedViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Learn tab feed, managing articles and category filtering
@Observable
@MainActor
public final class LearnFeedViewModel {
    // MARK: - State

    private(set) var articles: [LearningArticle] = []
    var selectedCategory: LearningCategory? {
        didSet {
            updateFilteredArticles()
            if let category = selectedCategory {
                analyticsService.logEvent(.categoryFiltered, parameters: [
                    AnalyticsParameter.category.rawValue: category.rawValue
                ])
            }
        }
    }
    private(set) var filteredArticles: [LearningArticle] = []

    // MARK: - Dependencies

    private let contentService: LearningContentServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // MARK: - Init

    public init(
        contentService: LearningContentServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.contentService = contentService
        self.analyticsService = analyticsService
    }

    // MARK: - Actions

    /// Loads all articles from the content service (synchronous)
    public func loadArticles() {
        articles = contentService.getAllArticles()
        updateFilteredArticles()
    }

    /// Logs an analytics event when an article is viewed
    public func trackArticleViewed(_ article: LearningArticle) {
        analyticsService.logEvent(.articleViewed, parameters: [
            AnalyticsParameter.articleId.rawValue: article.id,
            AnalyticsParameter.category.rawValue: article.category.rawValue
        ])
    }

    // MARK: - Private

    private func updateFilteredArticles() {
        if let category = selectedCategory {
            filteredArticles = contentService.getArticles(for: category)
        } else {
            filteredArticles = articles
        }
    }
}
#endif
