// OnboardingSciencePage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 2: "Science-Backed Breathing" with technique list
struct OnboardingSciencePage: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Science-Backed\nBreathing")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    techniqueRow(
                        name: "Resonance Breathing",
                        timing: "5.5s in \u{00B7} 5.5s out",
                        subtitle: "The perfect breath"
                    )
                    techniqueRow(
                        name: "Coherent Breathing",
                        timing: "6s in \u{00B7} 6s out",
                        subtitle: "Calm entry point"
                    )
                }

                Text("Each backed by research.\nGuided by a simple visual.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, AppSpacing.sm)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    private func techniqueRow(name: String, timing: String, subtitle: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            // Accent left border
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.accent)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(timing) — \(subtitle)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(height: 44)
    }
}
#endif
