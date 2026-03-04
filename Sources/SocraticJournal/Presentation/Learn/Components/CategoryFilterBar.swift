// CategoryFilterBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal pill filter bar for learning content categories
public struct CategoryFilterBar: View {
    @Binding var selectedCategory: LearningCategory?

    public init(selectedCategory: Binding<LearningCategory?>) {
        _selectedCategory = selectedCategory
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                filterPill(title: "All", category: nil)

                ForEach(LearningCategory.allCases, id: \.self) { category in
                    filterPill(title: category.displayName, category: category)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Filter Pill

    @ViewBuilder
    private func filterPill(title: String, category: LearningCategory?) -> some View {
        let isSelected = selectedCategory == category

        Button {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(title)
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : Color.clear)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Category Filter Bar") {
    VStack {
        CategoryFilterBar(selectedCategory: .constant(nil))
        CategoryFilterBar(selectedCategory: .constant(.science))
    }
    .padding(.vertical)
    .background(AppColors.background)
}
#endif
