// TechniqueSelector.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Horizontal scroll of technique cards for breath session setup
struct TechniqueSelector: View {
    @Binding var selectedTechnique: BreathTechnique
    private let techniques = BreathTechnique.allTechniques

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(techniques) { technique in
                    techniqueCard(technique)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func techniqueCard(_ technique: BreathTechnique) -> some View {
        let isSelected = selectedTechnique.id == technique.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTechnique = technique
            }
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(technique.name)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(technique.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text(technique.description)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 200, alignment: .leading)
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppColors.accent : AppColors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        TechniqueSelector(selectedTechnique: .constant(.resonance))
    }
}
#endif
