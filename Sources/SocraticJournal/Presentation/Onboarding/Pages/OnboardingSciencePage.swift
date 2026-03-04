// OnboardingSciencePage.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Page 2 — The Science: breathing techniques with credibility
struct OnboardingSciencePage: View {
    let onNext: () -> Void

    private let warmNavyBackground = Color(hex: "0F1E2E")

    private let techniques: [(name: String, description: String)] = [
        ("resonance breathing", "the perfect breath"),
        ("coherent breathing", "gentle & calming"),
        ("box breathing", "Navy SEAL focus"),
        ("4-7-8 relaxation", "natural tranquiliser"),
    ]

    var body: some View {
        ZStack {
            warmNavyBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Small wave preview at top
                AmbientWaveView(
                    color: .white,
                    opacity: 0.2,
                    amplitude: 15,
                    frequency: 2.0
                )
                .frame(height: 100)
                .clipped()

                Spacer().frame(height: AppSpacing.xl)

                // Stat headline
                VStack(spacing: AppSpacing.sm) {
                    Text("5.5")
                        .font(AppTypography.stat)
                        .foregroundStyle(.white)
                    + Text(" breaths per minute")
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)

                    Text("the rhythm that synchronises your heart and lungs")
                        .font(AppTypography.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer().frame(height: AppSpacing.xxl)

                // Technique list with accent left-border
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    ForEach(techniques, id: \.name) { technique in
                        HStack(spacing: AppSpacing.sm) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppColors.accent)
                                .frame(width: 3, height: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(technique.name)
                                    .font(AppTypography.body)
                                    .foregroundStyle(.white.opacity(0.9))

                                Text(technique.description)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer()

                Button {
                    onNext()
                } label: {
                    Text("next")
                        .font(AppTypography.bodyBold)
                        .foregroundStyle(.white)
                        .padding(.vertical, AppSpacing.md)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }
}

#Preview {
    OnboardingSciencePage(onNext: {})
}
#endif
