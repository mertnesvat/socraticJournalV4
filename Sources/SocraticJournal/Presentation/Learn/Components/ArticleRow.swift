// ArticleRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Enhanced article card with read/unread indicator
public struct ArticleRow: View {
    let article: LearnContent.Article
    let isExpanded: Bool
    let isRead: Bool
    let onTap: () -> Void

    public var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 10) {
                    // Read indicator
                    if isRead {
                        ZStack {
                            Circle()
                                .fill(AppColors.accent)
                                .frame(width: 12, height: 12)
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 4)
                    } else {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)
                            .padding(.horizontal, 3)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        // Tag + read time
                        HStack {
                            Text(article.tag.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.8)
                                .foregroundStyle(Color(hex: article.tagColorHex))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(hex: article.tagColorHex).opacity(0.08))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(hex: article.tagColorHex).opacity(0.2), lineWidth: 1)
                                )

                            Spacer()

                            Text(article.readTime)
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.textTertiary)
                        }

                        // Title
                        Text(article.title)
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)

                        // Subtitle
                        Text(article.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)

            // Expanded body
            if isExpanded {
                VStack(alignment: .leading) {
                    HairlineDivider()
                        .padding(.horizontal, AppSpacing.screenPadding)

                    Text(article.body)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textWarmBody)
                        .lineSpacing(6)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
#endif
