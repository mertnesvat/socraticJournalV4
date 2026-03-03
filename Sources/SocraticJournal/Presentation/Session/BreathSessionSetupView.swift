// BreathSessionSetupView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Setup screen before a breath session — technique info, duration picker, begin button
struct BreathSessionSetupView: View {
    let technique: BreathTechnique
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol

    @State private var selectedMinutes: Int
    @State private var showPacing = false
    @Environment(\.dismiss) private var dismiss

    init(
        technique: BreathTechnique,
        breathSessionRepository: BreathSessionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.technique = technique
        self.breathSessionRepository = breathSessionRepository
        self.analyticsService = analyticsService
        self._selectedMinutes = State(initialValue: technique.defaultDurationMinutes)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Technique header
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(technique.name)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(technique.subtitle)
                            .font(AppTypography.bodyLarge)
                            .foregroundStyle(AppColors.accent)
                    }
                    .padding(.top, AppSpacing.lg)

                    // Description
                    Text(technique.description)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineSpacing(4)

                    // Phase timing diagram
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("PHASES")
                            .font(AppTypography.sectionHeader)
                            .tracking(AppTypography.sectionHeaderTracking)
                            .foregroundStyle(AppColors.textTertiary)

                        ForEach(technique.phases) { phase in
                            HStack(spacing: AppSpacing.sm) {
                                // Phase bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(phaseColor(phase.phaseType))
                                    .frame(
                                        width: phaseBarWidth(phase.duration),
                                        height: 32
                                    )
                                    .overlay(alignment: .leading) {
                                        Text(phase.name)
                                            .font(AppTypography.captionBold)
                                            .foregroundStyle(.white)
                                            .padding(.leading, 8)
                                    }

                                Text(formatDuration(phase.duration))
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.textTertiary)
                                    .monospacedDigit()
                            }
                        }

                        // Cycle duration
                        Text("One cycle: \(formatDuration(technique.cycleDuration))")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                            .padding(.top, AppSpacing.xxs)
                    }

                    // Best for
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("BEST FOR")
                            .font(AppTypography.sectionHeader)
                            .tracking(AppTypography.sectionHeaderTracking)
                            .foregroundStyle(AppColors.textTertiary)

                        Text(technique.bestFor)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    // Duration picker
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("DURATION")
                            .font(AppTypography.sectionHeader)
                            .tracking(AppTypography.sectionHeaderTracking)
                            .foregroundStyle(AppColors.textTertiary)

                        DurationPicker(selectedMinutes: $selectedMinutes)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }

            // Begin button
            Button {
                showPacing = true
            } label: {
                Text("Begin")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textOnAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.accent)
                    )
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showPacing) {
            BreathPacingView(
                technique: technique,
                durationMinutes: selectedMinutes,
                breathSessionRepository: breathSessionRepository,
                analyticsService: analyticsService,
                onDismiss: { dismiss() }
            )
        }
    }

    private func phaseColor(_ type: BreathPhaseType) -> Color {
        switch type {
        case .inhale: return AppColors.accent
        case .inhaleTopUp: return AppColors.accent.opacity(0.7)
        case .hold: return AppColors.cardTeal
        case .exhale: return Color(hex: "5B8DEF")
        }
    }

    private func phaseBarWidth(_ duration: TimeInterval) -> CGFloat {
        let maxDuration = technique.phases.map(\.duration).max() ?? 1
        let ratio = duration / maxDuration
        return max(80, 200 * ratio)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        if seconds == floor(seconds) {
            return "\(Int(seconds))s"
        } else {
            return String(format: "%.1fs", seconds)
        }
    }
}
#endif
