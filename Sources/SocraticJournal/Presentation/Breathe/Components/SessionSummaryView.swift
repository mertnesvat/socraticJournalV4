// SessionSummaryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Post-session summary sheet showing session stats and affirming message
public struct SessionSummaryView: View {
    let session: BreathSession
    let streakCount: Int
    let onDismiss: () -> Void

    /// Rotating affirming messages
    private static let affirmations = [
        "Well done.",
        "Your body thanks you.",
        "Calm carries forward.",
        "Breathe easy."
    ]

    public init(session: BreathSession, streakCount: Int = 0, onDismiss: @escaping () -> Void) {
        self.session = session
        self.streakCount = streakCount
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            // Affirming message
            Text(Self.affirmations.randomElement() ?? "Well done.")
                .font(AppTypography.phaseLabelSmall)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.bottom, AppSpacing.md)

            // Session duration
            VStack(spacing: AppSpacing.xxs) {
                Text(session.formattedDuration)
                    .font(AppTypography.stat)
                    .foregroundStyle(AppColors.textPrimary)

                Text("total time")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }

            // Stats row
            HStack(spacing: AppSpacing.xl) {
                statItem(
                    value: "\(session.breathsCompleted)",
                    label: "breaths"
                )

                if streakCount > 0 {
                    statItem(
                        value: "\(streakCount)",
                        label: "day streak"
                    )
                }
            }
            .padding(.top, AppSpacing.sm)

            // Pattern name
            Text(session.patternName)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, AppSpacing.xs)

            Spacer()

            // Done button
            AccentPillButton("Done") {
                onDismiss()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.accent)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
    }
}

#Preview {
    SessionSummaryView(
        session: BreathSession(
            patternId: "resonance",
            patternName: "Resonance",
            startTime: Date().addingTimeInterval(-300),
            endTime: Date(),
            totalDurationSeconds: 300,
            breathsCompleted: 27
        ),
        streakCount: 3,
        onDismiss: {}
    )
}
#endif
