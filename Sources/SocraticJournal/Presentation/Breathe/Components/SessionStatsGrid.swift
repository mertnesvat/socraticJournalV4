// SessionStatsGrid.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Two-column stat layout showing duration and cycle count
public struct SessionStatsGrid: View {
    let durationFormatted: String
    let cycleCount: Int

    public var body: some View {
        HStack(spacing: 0) {
            // Duration
            VStack(spacing: 4) {
                Text(durationFormatted)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()

                Text("duration")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)

            HairlineDivider(axis: .vertical)
                .frame(height: 60)

            // Cycles
            VStack(spacing: 4) {
                Text("\(cycleCount)")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                Text("cycles")
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    /// Format seconds into M:SS string
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
#endif
