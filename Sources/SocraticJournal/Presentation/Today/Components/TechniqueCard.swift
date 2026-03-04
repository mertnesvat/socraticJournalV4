// TechniqueCard.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A reusable card for displaying a breath technique with configurable background
struct TechniqueCard: View {
    let technique: BreathTechnique
    let backgroundColor: Color
    let showBorder: Bool
    let showPlayIcon: Bool
    let onTap: () -> Void

    init(
        technique: BreathTechnique,
        backgroundColor: Color = AppColors.surface,
        showBorder: Bool = false,
        showPlayIcon: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.technique = technique
        self.backgroundColor = backgroundColor
        self.showBorder = showBorder
        self.showPlayIcon = showPlayIcon
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(technique.name)
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(technique.subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Text(technique.description)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                if showPlayIcon {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            .overlay(
                showBorder ?
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.border, lineWidth: 1) : nil
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Technique Card") {
    VStack(spacing: AppSpacing.cardGap) {
        TechniqueCard(
            technique: .resonance,
            backgroundColor: AppColors.cardTeal,
            showPlayIcon: true,
            onTap: {}
        )
        TechniqueCard(
            technique: .coherent,
            backgroundColor: AppColors.surface,
            showBorder: true,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
#endif
