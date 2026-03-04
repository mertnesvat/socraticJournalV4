// LearnFeedView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The Learn tab — editorial feed of breathing science articles
public struct LearnFeedView: View {
    @State var viewModel: LearnFeedViewModel

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                categoryFilter
                    .padding(.top, AppSpacing.md)
                articleCards
                    .padding(.top, AppSpacing.lg)

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .task { viewModel.loadContent() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Learn")
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text("The science of breathing")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.heroTopPadding)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                filterChip("All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(LearningCategory.allCases, id: \.rawValue) { category in
                    filterChip(category.rawValue, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Article Cards

    private var articleCards: some View {
        VStack(spacing: AppSpacing.cardGap) {
            ForEach(Array(viewModel.filteredBits.enumerated()), id: \.element.id) { index, bit in
                LearningCard(bit: bit, useElevatedBackground: index % 2 != 0)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

// MARK: - Learning Card

struct LearningCard: View {
    let bit: LearningBit
    var useElevatedBackground: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Category badge
            Text(bit.category.rawValue)
                .font(AppTypography.badge)
                .foregroundStyle(AppColors.textOnAccent)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs)
                .background(Capsule().fill(categoryColor))

            // Title
            Text(bit.title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            // Body
            Text(bit.body)
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(6)

            // Source note
            if let source = bit.sourceNote {
                Text(source)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .italic()
                    .padding(.top, AppSpacing.xxs)
            }
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(useElevatedBackground ? AppColors.surfaceElevated : AppColors.surface)
        )
    }

    private var categoryColor: Color {
        switch bit.category {
        case .science: return AppColors.accent
        case .nasal: return AppColors.cardTeal
        case .ancient: return AppColors.cardYellow
        }
    }
}
#endif
