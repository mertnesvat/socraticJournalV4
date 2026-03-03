// LearnFeedView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public struct LearnFeedView: View {
    private let contentService: BreathContentServiceProtocol = BreathContentService()
    @State private var selectedCategory: LearningCategory? = nil

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                    // Header
                    Text("Learn")
                        .font(AppTypography.display2)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, AppSpacing.heroTopPadding)

                    // Category filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            filterChip("All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(LearningCategory.allCases, id: \.rawValue) { category in
                                filterChip(shortLabel(for: category), isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }

                    // Learning cards
                    ForEach(filteredBits) { bit in
                        learningCard(bit)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sectionGap)
            }
            .background(AppColors.background)
        }
    }

    private var filteredBits: [LearningBit] {
        if let category = selectedCategory {
            return contentService.getLearningBitsForCategory(category)
        }
        return contentService.getAllLearningBits()
    }

    @ViewBuilder
    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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

    @ViewBuilder
    private func learningCard(_ bit: LearningBit) -> some View {
        let isEven = (Int(bit.id) ?? 0) % 2 == 0
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Category badge
            Text(bit.category.rawValue)
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textOnAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.accent))

            Text(bit.title)
                .font(AppTypography.headlineMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text(bit.body)
                .font(AppTypography.bodyLarge)
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(AppSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEven ? AppColors.surfaceElevated : AppColors.surface)
        )
    }

    private func shortLabel(for category: LearningCategory) -> String {
        switch category {
        case .science: return "Science"
        case .nasal: return "Nasal"
        case .ancient: return "Ancient"
        case .techniques: return "Techniques"
        case .facts: return "Facts"
        }
    }
}
#endif
