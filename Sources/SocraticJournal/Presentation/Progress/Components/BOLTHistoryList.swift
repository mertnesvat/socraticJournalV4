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

    private var sortedScores: [BOLTScore] {
        scores.sorted { $0.recordedAt < $1.recordedAt }
    }

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
                // Line chart sits above the score rows
                BOLTLineChart(scores: sortedScores)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sm)

                HairlineDivider()

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

// MARK: - BOLTLineChart

/// Compact purple line chart showing BOLT score trend over time
private struct BOLTLineChart: View {
    let scores: [BOLTScore]

    private let chartHeight: CGFloat = 80
    private let dotRadius: CGFloat = 3
    private let latestDotRadius: CGFloat = 4.5
    private let lineColor = Color(hex: "7B61FF")

    private var minVal: Double {
        (scores.map(\.score).min() ?? 0) - 5
    }

    private var maxVal: Double {
        (scores.map(\.score).max() ?? 1) + 5
    }

    private var scoreRange: Double {
        max(maxVal - minVal, 1)
    }

    private func xPos(index: Int, width: CGFloat) -> CGFloat {
        scores.count > 1 ? width * CGFloat(index) / CGFloat(scores.count - 1) : width / 2
    }

    private func yPos(value: Double, height: CGFloat) -> CGFloat {
        let normalized = (value - minVal) / scoreRange
        return height * CGFloat(1 - normalized)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = chartHeight

            ZStack {
                // Line connecting all points
                if scores.count > 1 {
                    Path { path in
                        for (i, score) in scores.enumerated() {
                            let pt = CGPoint(x: xPos(index: i, width: w), y: yPos(value: score.score, height: h))
                            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
                        }
                    }
                    .stroke(lineColor.opacity(0.5), lineWidth: 1.5)
                }

                // Dots
                ForEach(scores.indices, id: \.self) { i in
                    let isLatest = i == scores.count - 1
                    let r: CGFloat = isLatest ? latestDotRadius : dotRadius
                    let x = xPos(index: i, width: w)
                    let y = yPos(value: scores[i].score, height: h)

                    if isLatest {
                        Circle()
                            .stroke(lineColor.opacity(0.25), lineWidth: 1.5)
                            .frame(width: r * 2 + 4, height: r * 2 + 4)
                            .position(x: x, y: y)
                    }

                    Circle()
                        .fill(lineColor)
                        .frame(width: r * 2, height: r * 2)
                        .position(x: x, y: y)
                }
            }
            .frame(width: w, height: h)
        }
        .frame(height: chartHeight)
    }
}
#endif
