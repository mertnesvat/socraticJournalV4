// PatternDistribution.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Pattern usage breakdown for the progress view
struct PatternDistribution: View {
    let stats: [ProgressViewModel.PatternStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PATTERNS USED")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sm)

            if stats.isEmpty {
                Text("No patterns used yet")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.md)
            } else {
                ForEach(stats) { stat in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: stat.colorHex))
                            .frame(width: 8, height: 8)

                        Text(stat.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Text("\(stat.count) sessions")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)

                        Text("\(stat.percentage)%")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.accent)
                            .frame(width: 30, alignment: .trailing)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, 10)

                    if stat.id != stats.last?.id {
                        HairlineDivider()
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
    }
}
#endif
