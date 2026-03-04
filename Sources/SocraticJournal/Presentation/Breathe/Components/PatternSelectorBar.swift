// PatternSelectorBar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scrollable chip bar for selecting breathing patterns
public struct PatternSelectorBar: View {
    let patterns: [BreathPattern]
    let selectedId: String
    let onSelect: (BreathPattern) -> Void

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(patterns) { pattern in
                    let isSelected = pattern.id == selectedId
                    Button {
                        onSelect(pattern)
                    } label: {
                        Text(pattern.name)
                            .font(.system(size: 12, weight: isSelected ? .bold : .regular, design: .serif))
                            .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? AppColors.accentLight : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
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
    PatternSelectorBar(
        patterns: BreathPattern.allPatterns,
        selectedId: "resonance",
        onSelect: { _ in }
    )
    .padding(.vertical)
    .background(AppColors.background)
}
#endif
