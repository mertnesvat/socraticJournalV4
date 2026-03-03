// ArticleDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full article detail view with sections and key takeaway
public struct ArticleDetailView: View {
    let article: LearnArticle
    @Environment(\.dismiss) private var dismiss

    public init(article: LearnArticle) {
        self.article = article
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                // Header
                articleHeader
                    .padding(.top, AppSpacing.lg)

                // Sections
                ForEach(article.sections) { section in
                    sectionView(section)
                }

                // Key takeaway
                takeawayCard
                    .padding(.top, AppSpacing.md)

                Spacer(minLength: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
    }

    // MARK: - Header

    private var articleHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Category
            Text(article.category.uppercased())
                .font(AppTypography.badge)
                .tracking(1.0)
                .foregroundStyle(AppColors.accent)

            // Title
            Text(article.title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            // Read time
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                Text("\(article.readTimeMinutes) min read")
                    .font(AppTypography.caption)
            }
            .foregroundStyle(AppColors.textTertiary)

            HairlineDivider()
                .padding(.top, AppSpacing.sm)
        }
    }

    // MARK: - Section

    private func sectionView(_ section: ArticleSection) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(section.heading)
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text(section.body)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Key Takeaway

    private var takeawayCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.accent)

                Text("KEY TAKEAWAY")
                    .font(AppTypography.badge)
                    .tracking(1.0)
                    .foregroundStyle(AppColors.accent)
            }

            Text(article.keyTakeaway)
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.accent.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(article: LearnContent.articles[0])
    }
    .environment(ThemeManager.shared)
}
#endif
