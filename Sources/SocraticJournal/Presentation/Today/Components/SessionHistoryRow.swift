// SessionHistoryRow.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A compact row displaying session info: technique name, duration, and time
struct SessionHistoryRow: View {
    let session: BreathSession

    private var durationText: String {
        let minutes = Int(session.actualDuration / 60)
        let seconds = Int(session.actualDuration.truncatingRemainder(dividingBy: 60))
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(seconds)s"
        }
    }

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: session.startedAt).lowercased()
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(session.techniqueName)
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Text("\u{00B7}")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textTertiary)

            Text(durationText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            Text("\u{00B7}")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textTertiary)

            Text(timeText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)

            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

#Preview("Session History Row") {
    VStack(spacing: 0) {
        SessionHistoryRow(session: BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance Breathing",
            startedAt: Date(),
            completedAt: Date().addingTimeInterval(300),
            targetDuration: 300,
            cyclesCompleted: 27
        ))
        HairlineDivider()
        SessionHistoryRow(session: BreathSession(
            techniqueId: "box",
            techniqueName: "Box Breathing",
            startedAt: Date().addingTimeInterval(-3600),
            completedAt: Date().addingTimeInterval(-3600 + 180),
            targetDuration: 300,
            cyclesCompleted: 11
        ))
    }
    .background(AppColors.background)
}
#endif
