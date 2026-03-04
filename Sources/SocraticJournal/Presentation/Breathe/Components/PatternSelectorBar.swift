// PatternSelectorBar.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct PatternSelectorBar: View {
    let patterns: [BreathPattern]
    @Binding var selectedId: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(patterns) { pattern in
                    Button {
                        selectedId = pattern.id
                    } label: {
                        Text(pattern.name)
                            .font(AppTypography.patternPill)
                            .fontWeight(selectedId == pattern.id ? .bold : .regular)
                            .foregroundStyle(selectedId == pattern.id ? AppColors.accent : AppColors.textTertiary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedId == pattern.id ? AppColors.accentLight : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(selectedId == pattern.id ? AppColors.accent : AppColors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
}
#endif
