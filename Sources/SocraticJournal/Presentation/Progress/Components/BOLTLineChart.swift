// BOLTLineChart.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact purple line chart showing BOLT score progression over time
struct BOLTLineChart: View {
    let scores: [BOLTScore]

    private let chartHeight: CGFloat = 72
    private let purple = Color(hex: "7B52AB")

    private var sortedScores: [BOLTScore] {
        scores.sorted { $0.recordedAt < $1.recordedAt }
    }

    private var minScore: Double {
        max(0, (sortedScores.map(\.score).min() ?? 0) - 5)
    }

    private var maxScore: Double {
        max((sortedScores.map(\.score).max() ?? 0) + 5, 40)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("BOLT TREND")
                    .font(.system(size: 11))
                    .tracking(1.0)
                    .foregroundStyle(AppColors.textTertiary)

                Spacer()

                if let latest = sortedScores.last {
                    Text(String(format: "%.1fs", latest.score))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(purple)
                }
            }

            GeometryReader { geo in
                let points = chartPoints(width: geo.size.width)

                ZStack {
                    // Area fill under line
                    if points.count >= 2 {
                        Path { path in
                            path.move(to: CGPoint(x: points[0].x, y: chartHeight))
                            path.addLine(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                            path.addLine(to: CGPoint(x: points.last!.x, y: chartHeight))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [purple.opacity(0.15), purple.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }

                    // Line
                    if points.count >= 2 {
                        Path { path in
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(purple, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    }

                    // Dots
                    ForEach(Array(zip(sortedScores.indices, points)), id: \.0) { _, point in
                        Circle()
                            .fill(purple)
                            .frame(width: 5, height: 5)
                            .position(point)
                    }
                }
            }
            .frame(height: chartHeight)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
    }

    private func chartPoints(width: CGFloat) -> [CGPoint] {
        let sorted = sortedScores
        guard !sorted.isEmpty else { return [] }

        let scoreRange = maxScore - minScore

        if sorted.count == 1 {
            let y = chartHeight * (1.0 - (sorted[0].score - minScore) / scoreRange)
            return [CGPoint(x: width / 2, y: max(2, min(chartHeight - 2, y)))]
        }

        return sorted.enumerated().map { index, score in
            let x = CGFloat(index) / CGFloat(sorted.count - 1) * width
            let normalizedY = (score.score - minScore) / scoreRange
            let y = chartHeight * (1.0 - normalizedY)
            return CGPoint(x: x, y: max(2, min(chartHeight - 2, y)))
        }
    }
}
#endif
