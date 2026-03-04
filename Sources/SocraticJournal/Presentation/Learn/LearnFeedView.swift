// LearnFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Learn tab showing educational articles about breathwork science
public struct LearnFeedView: View {
    @State private var viewModel: LearnFeedViewModel

    public init(
        contentService: LearningContentServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        _viewModel = State(initialValue: LearnFeedViewModel(
            contentService: contentService,
            analyticsService: analyticsService
        ))
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredArticles.isEmpty && viewModel.articles.isEmpty {
                    emptyView
                } else if viewModel.filteredArticles.isEmpty {
                    filteredEmptyView
                } else {
                    contentView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationDestination(for: LearningArticle.ID.self) { articleId in
                if let article = viewModel.articles.first(where: { $0.id == articleId }) {
                    LearnArticleDetailView(article: article)
                        .onAppear {
                            viewModel.trackArticleViewed(article)
                        }
                }
            }
        }
        .onAppear {
            viewModel.loadArticles()
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "book")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textTertiary)

            Text("No articles yet")
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Text("Educational content is on its way.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Filtered Empty State

    private var filteredEmptyView: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection

                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.textTertiary)

                    Text("No articles in this category")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Try selecting a different category.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection

                // Article cards
                VStack(spacing: AppSpacing.cardGap) {
                    ForEach(Array(viewModel.filteredArticles.enumerated()), id: \.element.id) { index, article in
                        NavigationLink(value: article.id) {
                            LearningArticleCard(article: article, index: index) {}
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Learn")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)

            CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)

            HairlineDivider()
                .padding(.top, AppSpacing.xs)
        }
        .padding(.bottom, AppSpacing.md)
    }
}

#Preview("Learn Feed") {
    LearnFeedView(
        contentService: StaticLearningContentService(),
        analyticsService: FirebaseAnalyticsService.shared
    )
}
#endif
