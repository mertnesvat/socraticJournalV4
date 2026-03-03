// LearnView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Learn tab: curated articles and quick facts about breathing science
public struct LearnView: View {
    @State private var selectedArticle: LearnArticle?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Learn")
                            .font(AppTypography.display)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.md)

                    // Article cards
                    SectionHeaderView("Articles")

                    LazyVStack(spacing: 0) {
                        ForEach(Array(LearnContent.articles.enumerated()), id: \.element.id) { index, article in
                            NavigationLink(value: article.id) {
                                articleCard(article, isElevated: index % 2 == 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Quick facts strip
                    SectionHeaderView("Quick Facts")
                        .padding(.top, AppSpacing.md)

                    quickFactsStrip
                        .padding(.bottom, AppSpacing.xxl)
                }
            }
            .background(AppColors.background)
            .navigationDestination(for: String.self) { articleId in
                if let article = LearnContent.articles.first(where: { $0.id == articleId }) {
                    ArticleDetailView(article: article)
                }
            }
        }
    }

    // MARK: - Article Card

    private func articleCard(_ article: LearnArticle, isElevated: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Category pill
            Text(article.category.uppercased())
                .font(AppTypography.badge)
                .tracking(1.0)
                .foregroundStyle(AppColors.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(AppColors.accent.opacity(0.15))
                )

            // Title
            Text(article.title)
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.leading)

            // Preview
            Text(article.preview)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Read time
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                Text("\(article.readTimeMinutes) min read")
                    .font(AppTypography.caption)
            }
            .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .background(isElevated ? AppColors.surfaceElevated : AppColors.surface)
    }

    // MARK: - Quick Facts Strip

    private var quickFactsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(BreathFacts.all) { fact in
                    quickFactCard(fact)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func quickFactCard(_ fact: BreathFacts.Fact) -> some View {
        Text(fact.text)
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.leading)
            .lineLimit(4)
            .frame(width: 160, alignment: .topLeading)
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    LearnView()
        .environment(ThemeManager.shared)
}
#endif
