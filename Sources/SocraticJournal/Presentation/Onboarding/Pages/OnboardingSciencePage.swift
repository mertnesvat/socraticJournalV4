// OnboardingSciencePage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 2 — "Ancient Wisdom, Modern Science" with technique list
struct OnboardingSciencePage: View {
    private let techniques: [(name: String, subtitle: String)] = [
        ("Resonant Breathing", "The perfect breath"),
        ("Box Breathing", "Navy SEAL focus"),
        ("4-7-8 Breathing", "Natural tranquilizer"),
        ("Cyclic Sighing", "Stanford's stress reset")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Spacer()

            Text("Ancient Wisdom,\nModern Science")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(techniques, id: \.name) { technique in
                    HStack(spacing: AppSpacing.sm) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.accent)
                            .frame(width: 4, height: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(technique.name)
                                .font(AppTypography.bodyBold)
                                .foregroundStyle(AppColors.textPrimary)
                            Text(technique.subtitle)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            Text("Each backed by research. Guided by a simple visual.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
#endif
