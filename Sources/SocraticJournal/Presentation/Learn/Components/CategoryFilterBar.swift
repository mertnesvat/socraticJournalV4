// CategoryFilterBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UIKit

/// Horizontal scrolling category filter chips
struct CategoryFilterBar: View {
    @Binding var selectedCategory: LearningCategory?

    var body: some View {
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
    }

    @ViewBuilder
    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
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
