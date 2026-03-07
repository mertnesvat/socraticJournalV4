// BOLTHistoryList.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// BOLT score history section for the Progress view
struct BOLTHistoryList: View {
    let scores: [BOLTScore]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("BOLT HISTORY")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sm)

            if scores.isEmpty {
                Text("No BOLT tests yet")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else {
                if scores.count >= 2 {
                    BOLTLineChart(scores: scores)
                    HairlineDivider()
                        .padding(.bottom, AppSpacing.sm)
                }

                ForEach(scores) { score in
                    scoreRow(score)
                    if score.id != scores.last?.id {
                        HairlineDivider()
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
    }

    private func scoreRow(_ score: BOLTScore) -> some View {
        let tier = score.tier
        let tierColor = Color(hex: tier.colorHex)

        return HStack(spacing: 14) {
            // Tier color dot
            Circle()
                .fill(tierColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(String(format: "%.1fs", score.score))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(tier.label.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.4)
                        .foregroundStyle(tierColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(tierColor.opacity(0.08)))
                        .overlay(Capsule().stroke(tierColor.opacity(0.2), lineWidth: 1))
                }

                Text(dateFormatter.string(from: score.recordedAt))
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, 10)
    }
}
#endif
