// CategoryFilterBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Category for filtering Learn tab articles
enum LearnCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case fundamentals = "Fundamentals"
    case patterns = "Patterns"
    case history = "History"
    case advanced = "Advanced"

    var id: String { rawValue }

    var accentColor: Color {
        switch self {
        case .all: return AppColors.accent
        case .fundamentals: return AppColors.accent                // teal #2D5F5D
        case .patterns: return AppColors.accent2                   // coral #C4502A
        case .history: return Color(hex: "7A6030")                 // brown
        case .advanced: return Color(hex: "6B4C8A")                // purple
        }
    }
}

/// Horizontal scrollable pill-chip bar for filtering articles by category.
/// Visual style matches PatternSelectorBar on the Breathe tab.
struct CategoryFilterBar: View {
    let selectedCategory: LearnCategory
    let onSelect: (LearnCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LearnCategory.allCases) { category in
                    let isSelected = category == selectedCategory
                    Button {
                        onSelect(category)
                    } label: {
                        Text(category.rawValue)
                            .font(.system(size: 12, weight: isSelected ? .bold : .regular, design: .serif))
                            .foregroundStyle(isSelected ? Color.white : AppColors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? AppColors.accent : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CategoryFilterBar(selectedCategory: .all, onSelect: { _ in })
        CategoryFilterBar(selectedCategory: .fundamentals, onSelect: { _ in })
        CategoryFilterBar(selectedCategory: .history, onSelect: { _ in })
    }
    .padding(.vertical)
    .background(AppColors.background)
}
#endif
