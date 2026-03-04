// LearnFeedViewModelTests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("LearnFeedViewModel Tests")
struct LearnFeedViewModelTests {

    // MARK: - Test Helpers

    static func makeSampleArticle(
        id: String = "test-1",
        title: String = "Test Article",
        category: LearningCategory = .science
    ) -> LearningArticle {
        LearningArticle(
            id: id,
            title: title,
            summary: "A test summary",
            body: "A test body paragraph.",
            category: category,
            keyTakeaway: "A key takeaway",
            sourceNote: "Test Source (2024)",
            readTimeMinutes: 3
        )
    }

    // MARK: - Load Articles

    @Suite("Load Articles")
    struct LoadArticlesTests {

        @Test("loadArticles populates articles and filteredArticles")
        @MainActor
        func loadArticlesPopulatesArticles() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science),
                makeSampleArticle(id: "2", category: .anatomy)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()

            #expect(viewModel.articles.count == 2)
            #expect(viewModel.filteredArticles.count == 2)
        }

        @Test("loadArticles with empty service returns empty arrays")
        @MainActor
        func loadArticlesEmpty() {
            let contentService = MockLearningContentService()
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()

            #expect(viewModel.articles.isEmpty)
            #expect(viewModel.filteredArticles.isEmpty)
        }
    }

    // MARK: - Category Filtering

    @Suite("Category Filtering")
    struct CategoryFilteringTests {

        @Test("selecting a category filters articles correctly")
        @MainActor
        func filterByCategory() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science),
                makeSampleArticle(id: "2", category: .anatomy),
                makeSampleArticle(id: "3", category: .science),
                makeSampleArticle(id: "4", category: .practice)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()
            viewModel.selectedCategory = .science

            #expect(viewModel.filteredArticles.count == 2)
            #expect(viewModel.filteredArticles.allSatisfy { $0.category == .science })
        }

        @Test("selecting nil category shows all articles")
        @MainActor
        func filterAllCategory() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science),
                makeSampleArticle(id: "2", category: .anatomy)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()
            viewModel.selectedCategory = .science
            #expect(viewModel.filteredArticles.count == 1)

            viewModel.selectedCategory = nil
            #expect(viewModel.filteredArticles.count == 2)
        }

        @Test("filtering by category with no matches returns empty")
        @MainActor
        func filterByCategoryNoMatches() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()
            viewModel.selectedCategory = .practice

            #expect(viewModel.filteredArticles.isEmpty)
            #expect(viewModel.articles.count == 1)
        }

        @Test("category filter logs analytics event")
        @MainActor
        func categoryFilterLogsAnalytics() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()
            viewModel.selectedCategory = .anatomy

            #expect(analytics.hasLoggedEvent(.categoryFiltered))
            let params = analytics.lastParameters(for: .categoryFiltered)
            #expect(params?[AnalyticsParameter.category.rawValue] as? String == "anatomy")
        }
    }

    // MARK: - Analytics

    @Suite("Analytics Tracking")
    struct AnalyticsTests {

        @Test("trackArticleViewed logs article_viewed event with parameters")
        @MainActor
        func trackArticleViewedLogsEvent() {
            let contentService = MockLearningContentService()
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            let article = makeSampleArticle(id: "hrv-resonance", category: .science)
            viewModel.trackArticleViewed(article)

            #expect(analytics.hasLoggedEvent(.articleViewed))
            let params = analytics.lastParameters(for: .articleViewed)
            #expect(params?[AnalyticsParameter.articleId.rawValue] as? String == "hrv-resonance")
            #expect(params?[AnalyticsParameter.category.rawValue] as? String == "science")
        }

        @Test("selecting nil category does not log analytics")
        @MainActor
        func nilCategoryDoesNotLog() {
            let contentService = MockLearningContentService()
            contentService.articlesToReturn = [
                makeSampleArticle(id: "1", category: .science)
            ]
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            viewModel.loadArticles()
            viewModel.selectedCategory = nil

            #expect(!analytics.hasLoggedEvent(.categoryFiltered))
        }
    }

    // MARK: - Initial State

    @Suite("Initial State")
    struct InitialStateTests {

        @Test("initial state has empty articles and nil category")
        @MainActor
        func initialStateIsEmpty() {
            let contentService = MockLearningContentService()
            let analytics = MockAnalyticsService()
            let viewModel = LearnFeedViewModel(
                contentService: contentService,
                analyticsService: analytics
            )

            #expect(viewModel.articles.isEmpty)
            #expect(viewModel.filteredArticles.isEmpty)
            #expect(viewModel.selectedCategory == nil)
        }
    }
}
