// TechniqueListSection.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A vertical stack of technique cards with alternating colours
struct TechniqueListSection: View {
    let onSelect: (BreathTechnique) -> Void

    private var techniqueStyles: [(technique: BreathTechnique, color: Color, border: Bool)] {
        [
            (.resonance, AppColors.cardTeal, false),
            (.coherent, AppColors.surface, true),
            (.box, AppColors.cardYellow, false),
            (.fourSevenEight, AppColors.surfaceElevated, false)
        ]
    }

    var body: some View {
        VStack(spacing: AppSpacing.cardGap) {
            ForEach(techniqueStyles, id: \.technique.id) { item in
                TechniqueCard(
                    technique: item.technique,
                    backgroundColor: item.color,
                    showBorder: item.border,
                    onTap: { onSelect(item.technique) }
                )
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#Preview("Technique List Section") {
    ScrollView {
        TechniqueListSection(onSelect: { _ in })
    }
    .background(AppColors.background)
}
#endif
