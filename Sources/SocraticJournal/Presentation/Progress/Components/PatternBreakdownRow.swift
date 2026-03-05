// PatternBreakdownRow.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A single row in the pattern breakdown list showing usage stats and progress bar
struct PatternBreakdownRow: View {
    let stat: ProgressViewModel.PatternStat

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Top row: pattern name + stats
            HStack(alignment: .center) {
                // Colored dot + pattern name
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(Color(hex: stat.tagColorHex))
                        .frame(width: 8, height: 8)

                    Text(stat.patternName)
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                }

                Spacer()

                // Minutes + session count
                Text("\(Int(stat.totalMinutes)) min \u{00B7} \(stat.sessionCount) \(stat.sessionCount == 1 ? "session" : "sessions")")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(AppColors.surface)
                        .frame(height: 4)

                    // Fill
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color(hex: stat.tagColorHex))
                        .frame(width: max(geometry.size.width * stat.proportion, 4), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
    }
}
#endif
