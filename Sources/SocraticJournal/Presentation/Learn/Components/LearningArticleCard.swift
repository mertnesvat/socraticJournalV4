// LearningArticleCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card displaying a learning article preview with category, title, summary, and key takeaway
public struct LearningArticleCard: View {
    let article: LearningArticle
    let index: Int
    let onTap: () -> Void

    public init(article: LearningArticle, index: Int, onTap: @escaping () -> Void) {
        self.article = article
        self.index = index
        self.onTap = onTap
    }

    private var backgroundColor: Color {
        index.isMultiple(of: 2) ? AppColors.surface : AppColors.surfaceElevated
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Category tag pill
                categoryTag

                // Title
                Text(article.title)
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)

                // Summary (2-3 lines)
                Text(article.summary)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Read time
                Text("\(article.readTimeMinutes) min read")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                // Key takeaway strip
                keyTakeawayStrip
            }
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Tag

    private var categoryTag: some View {
        Text(article.category.displayName.uppercased())
            .font(AppTypography.badge)
            .tracking(1)
            .foregroundStyle(AppColors.textOnAccent)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xxs)
            .background(
                Capsule()
                    .fill(AppColors.accent.opacity(0.85))
            )
    }

    // MARK: - Key Takeaway Strip

    private var keyTakeawayStrip: some View {
        HStack(spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.accent)
                .frame(width: 4)

            Text(article.keyTakeaway)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.accent.opacity(0.08))
        )
    }
}

#Preview("Learning Article Card") {
    let sampleArticle = LearningArticle(
        id: "sample",
        title: "Mouth vs Nasal Breathing",
        summary: "Your nose does far more than you think. From producing nitric oxide to filtering pathogens, nasal breathing is a cornerstone of respiratory health.",
        body: "Full body text here...",
        category: .science,
        keyTakeaway: "Your nose is a pharmacy that produces nitric oxide, humidifies air, and filters pathogens.",
        sourceNote: "James Nestor, Breath (2020)",
        readTimeMinutes: 4
    )

    ScrollView {
        VStack(spacing: AppSpacing.cardGap) {
            LearningArticleCard(article: sampleArticle, index: 0) {}
            LearningArticleCard(article: sampleArticle, index: 1) {}
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
#endif
