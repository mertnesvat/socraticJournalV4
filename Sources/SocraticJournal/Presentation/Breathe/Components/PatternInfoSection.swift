// PatternInfoSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// About this pattern section with scientific description and best-for tag
public struct PatternInfoSection: View {
    let pattern: BreathPattern

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT THIS PATTERN")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.textTertiary)

            Text(pattern.importance)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(6)

            HStack(spacing: 6) {
                Text("Best for")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)

                Text(pattern.bestFor)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.cardPadding)
    }
}

#Preview {
    PatternInfoSection(pattern: .resonance)
        .background(AppColors.background)
}
#endif
