// LearnArticleDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full article detail view with editorial styling
public struct LearnArticleDetailView: View {
    let article: LearningArticle

    public init(article: LearningArticle) {
        self.article = article
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Title
                Text(article.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                // Category + read time
                HStack(spacing: AppSpacing.xs) {
                    Text(article.category.displayName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Text("\u{00B7}")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)

                    Text("\(article.readTimeMinutes) min read")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                HairlineDivider()

                // Body text with paragraph spacing
                bodyText

                // Key Takeaway callout
                keyTakeawayCallout

                HairlineDivider()

                // Source attribution
                Text(article.sourceNote)
                    .font(AppTypography.caption.italic())
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.bottom, AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.md)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Body Text

    private var bodyText: some View {
        let paragraphs = article.body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Key Takeaway Callout

    private var keyTakeawayCallout: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Key Takeaway")
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            Text(article.keyTakeaway)
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(2)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.accent.opacity(0.08))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.accent)
                        .frame(width: 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }
}

#Preview("Article Detail") {
    NavigationStack {
        LearnArticleDetailView(
            article: LearningArticle(
                id: "preview",
                title: "Mouth vs Nasal Breathing",
                summary: "Your nose does far more than you think.",
                body: """
                For most of human history, breathing through the nose was simply how people breathed. It was \
                unremarkable, automatic, the default.

                The difference between nasal and mouth breathing is not merely one of preference. It is \
                physiological. Your nose is an extraordinarily sophisticated organ.

                Perhaps the most important discovery about nasal breathing involves nitric oxide.
                """,
                category: .science,
                keyTakeaway: "Your nose is a pharmacy that produces nitric oxide, humidifies air, and filters pathogens.",
                sourceNote: "James Nestor, Breath: The New Science of a Lost Art (2020)",
                readTimeMinutes: 4
            )
        )
    }
}
#endif
