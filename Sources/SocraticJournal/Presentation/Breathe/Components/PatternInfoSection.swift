// PatternInfoSection.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct PatternInfoSection: View {
    let pattern: BreathPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT THIS PATTERN")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.textQuaternary)

            Text(pattern.importance)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(5)

            HStack(spacing: 4) {
                Text("Best for")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textQuaternary)
                Text("·")
                    .foregroundStyle(AppColors.textQuaternary)
                Text(pattern.best)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(20)
    }
}
#endif
