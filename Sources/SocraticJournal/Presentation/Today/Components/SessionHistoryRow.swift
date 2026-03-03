// SessionHistoryRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A single row in today's session history list
struct SessionHistoryRow: View {
    let techniqueName: String
    let duration: TimeInterval
    let startedAt: Date

    var body: some View {
        HStack {
            Text(techniqueName)
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Text("\(Int(duration / 60)) min")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            Text(formattedTime)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startedAt)
    }
}
#endif
