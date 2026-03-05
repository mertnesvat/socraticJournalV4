// BOLTScoreCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card on the Today tab showing BOLT score status
public struct BOLTScoreCard: View {
    let latestScore: BOLTScore?
    let onTap: () -> Void

    public var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BOLT SCORE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(AppColors.accent)

                    if let score = latestScore {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.0f", score.score))
                                .font(.system(size: 42, weight: .bold, design: .serif))
                                .foregroundStyle(AppColors.textPrimary)

                            Text("seconds")
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.textTertiary)
                        }

                        let daysAgo = Calendar.current.dateComponents([.day], from: score.recordedAt, to: Date()).day ?? 0
                        Text("Last tested: \(daysAgo == 0 ? "today" : "\(daysAgo) day\(daysAgo == 1 ? "" : "s") ago")")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)
                    } else {
                        Text("Measure your baseline")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(AppSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.accent.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.accent.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
#endif
