// BOLTLineChart.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact line chart for BOLT score history.
/// Drawn with SwiftUI Path — no Charts framework.
struct BOLTLineChart: View {
    let scores: [BOLTScore]

    private let chartHeight: CGFloat = 80
    private let dotRadius: CGFloat = 4
    private let lineColor = Color(hex: "7B5EA7")

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()

    /// Scores sorted oldest → newest
    private var sorted: [BOLTScore] {
        scores.sorted { $0.recordedAt < $1.recordedAt }
    }

    private var minScore: Double { sorted.map(\.score).min() ?? 0 }
    private var maxScore: Double { sorted.map(\.score).max() ?? 0 }

    private func yPosition(for score: Double, in height: CGFloat) -> CGFloat {
        let range = maxScore - minScore
        guard range > 0 else { return height / 2 }
        return height * (1.0 - (score - minScore) / range)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let count = sorted.count
            let spacing = count > 1 ? width / CGFloat(count - 1) : width / 2

            ZStack(alignment: .topLeading) {
                // Baseline
                Path { path in
                    path.move(to: CGPoint(x: 0, y: chartHeight))
                    path.addLine(to: CGPoint(x: width, y: chartHeight))
                }
                .stroke(AppColors.border, lineWidth: 0.5)

                // Line connecting dots
                if count > 1 {
                    Path { path in
                        for (i, score) in sorted.enumerated() {
                            let x = count > 1 ? CGFloat(i) * spacing : width / 2
                            let y = yPosition(for: score.score, in: chartHeight)
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                }

                // Dots
                ForEach(Array(sorted.enumerated()), id: \.element.id) { i, score in
                    let x = count > 1 ? CGFloat(i) * spacing : width / 2
                    let y = yPosition(for: score.score, in: chartHeight)

                    Circle()
                        .fill(lineColor)
                        .frame(width: dotRadius * 2, height: dotRadius * 2)
                        .position(x: x, y: y)
                }

                // Min/Max value labels
                if let first = sorted.min(by: { $0.score < $1.score }),
                   let last = sorted.max(by: { $0.score < $1.score }) {
                    // Only show if they differ
                    if first.id != last.id {
                        let minIdx = sorted.firstIndex(where: { $0.id == first.id }) ?? 0
                        let maxIdx = sorted.firstIndex(where: { $0.id == last.id }) ?? 0

                        let minX = count > 1 ? CGFloat(minIdx) * spacing : width / 2
                        let maxX = count > 1 ? CGFloat(maxIdx) * spacing : width / 2
                        let minY = yPosition(for: first.score, in: chartHeight)
                        let maxY = yPosition(for: last.score, in: chartHeight)

                        // Low label (below dot)
                        Text(String(format: "%.0fs", first.score))
                            .font(.system(size: 8))
                            .foregroundStyle(lineColor.opacity(0.7))
                            .position(x: minX, y: minY + 12)

                        // High label (above dot)
                        Text(String(format: "%.0fs", last.score))
                            .font(.system(size: 8))
                            .foregroundStyle(lineColor.opacity(0.7))
                            .position(x: maxX, y: maxY - 12)
                    }
                }
            }
            .frame(height: chartHeight + 4) // small buffer for baseline

            // X-axis date labels below
            HStack(spacing: 0) {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { i, score in
                    Text(dateFormatter.string(from: score.recordedAt))
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .offset(y: chartHeight + 8)
        }
        .frame(height: chartHeight + 28) // chart + label row
    }
}
#endif
