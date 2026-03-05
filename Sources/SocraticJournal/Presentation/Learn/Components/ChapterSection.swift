// ChapterSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Collapsible chapter section with header, progress, and article list
public struct ChapterSection: View {
    let chapter: LearnContent.Chapter
    let isExpanded: Bool
    let expandedArticle: Int?
    let readArticles: Set<Int>
    let onToggle: () -> Void
    let onArticleTap: (Int) -> Void

    private var readCount: Int {
        chapter.articles.filter { readArticles.contains($0.id) }.count
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Chapter header
            Button(action: onToggle) {
                HStack(spacing: 10) {
                    // Teal left accent
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.accent)
                        .frame(width: 4, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.title)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)

                        Text(chapter.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    Text("\(readCount) of \(chapter.articles.count) read")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.accent)

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)

            HairlineDivider()

            // Articles (only when chapter is expanded)
            if isExpanded {
                ForEach(chapter.articles) { article in
                    ArticleRow(
                        article: article,
                        isExpanded: expandedArticle == article.id,
                        isRead: readArticles.contains(article.id),
                        onTap: { onArticleTap(article.id) }
                    )

                    if article.id != chapter.articles.last?.id {
                        HairlineDivider()
                    }
                }
            }
        }
    }
}
#endif
