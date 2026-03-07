// BOLTHistoryList.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// BOLT score history section for the Progress view
struct BOLTHistoryList: View {
    let recentScores: [BOLTScore]
    let allScores: [BOLTScore]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if allScores.isEmpty {
                // Header + empty state
                Text("BOLT HISTORY")
                    .font(.system(size: 11))
                    .tracking(1.0)
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sm)

                Text("No BOLT tests yet")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else {
                // Chart first
                if allScores.count >= 2 {
                    BOLTLineChart(scores: allScores)
                    HairlineDivider()
                }

                // Header + See All below the chart
                HStack {
                    Text("BOLT HISTORY")
                        .font(.system(size: 11))
                        .tracking(1.0)
                        .foregroundStyle(AppColors.textTertiary)

                    Spacer()

                    if allScores.count > recentScores.count {
                        NavigationLink {
                            AllBOLTScoresView(scores: allScores)
                        } label: {
                            Text("See All")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

                ForEach(recentScores) { score in
                    scoreRow(score)
                    if score.id != recentScores.last?.id {
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
