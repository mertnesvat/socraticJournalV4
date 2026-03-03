// BreathSessionCompleteView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Session completion summary — shows stats and allows return to dashboard
struct BreathSessionCompleteView: View {
    let session: BreathSession
    let technique: BreathTechnique
    let breathSessionRepository: BreathSessionRepositoryProtocol
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sectionGap) {
            Spacer()

            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppColors.accent)

            // Title
            VStack(spacing: AppSpacing.xs) {
                Text("Well Done")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(technique.name)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Stats
            HStack(spacing: AppSpacing.xxl) {
                statItem(
                    value: formatDuration(session.totalDuration),
                    label: "Duration"
                )

                Rectangle()
                    .fill(AppColors.border)
                    .frame(width: 1, height: 48)

                statItem(
                    value: "\(session.cyclesCompleted)",
                    label: session.cyclesCompleted == 1 ? "Cycle" : "Cycles"
                )
            }
            .padding(AppSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
            )

            Spacer()

            // Done button
            Button {
                onDismiss()
            } label: {
                Text("Done")
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
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(minWidth: 80)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(secs)s"
        }
        return "\(secs)s"
    }
}
#endif
