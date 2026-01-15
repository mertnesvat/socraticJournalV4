// TrendChartView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Line chart showing clarity scores over time
public struct TrendChartView: View {
    let data: [TrendDataPoint]

    @State private var animatedProgress: CGFloat = 0
    @State private var selectedPoint: TrendDataPoint?

    private let chartHeight: CGFloat = 160

    public init(data: [TrendDataPoint]) {
        self.data = data
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Weekly Trend")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()

                if let selected = selectedPoint {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f", selected.score))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text(formatDate(selected.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Chart
            if data.isEmpty || !hasAnyData {
                emptyChartView
            } else {
                chartContent
            }

            // Day labels
            dayLabels
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = 1.0
            }
        }
    }

    private var hasAnyData: Bool {
        data.contains { $0.score > 0 || $0.sessionCount > 0 }
    }

    private var emptyChartView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No data this week")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: chartHeight)
        .frame(maxWidth: .infinity)
    }

    private var chartContent: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = chartHeight

            ZStack {
                // Grid lines
                gridLines(width: width, height: height)

                // Line path
                linePath(width: width, height: height)

                // Data points
                dataPoints(width: width, height: height)

                // Session count bars
                sessionBars(width: width, height: height)
            }
        }
        .frame(height: chartHeight)
    }

    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Horizontal grid lines
            ForEach(0..<4) { index in
                let y = height * CGFloat(index) / 3
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
            }
        }
    }

    private func linePath(width: CGFloat, height: CGFloat) -> some View {
        let maxScore: Double = 100
        let points = data.enumerated().map { index, point -> CGPoint in
            let x = width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
            let normalizedY = point.score / maxScore
            let y = height - (height * CGFloat(normalizedY))
            return CGPoint(x: x, y: y)
        }

        return ZStack {
            // Gradient fill under line
            if points.count > 1 {
                Path { path in
                    path.move(to: CGPoint(x: points[0].x, y: height))
                    path.addLine(to: points[0])

                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }

                    path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask(
                    Rectangle()
                        .frame(width: width * animatedProgress, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
            }

            // Line
            if points.count > 1 {
                Path { path in
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }

    private func dataPoints(width: CGFloat, height: CGFloat) -> some View {
        let maxScore: Double = 100

        return ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
            if point.score > 0 {
                let x = width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                let normalizedY = point.score / maxScore
                let y = height - (height * CGFloat(normalizedY))

                Circle()
                    .fill(Color(uiColor: .systemBackground))
                    .frame(width: 12, height: 12)
                    .overlay {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                    }
                    .position(x: x, y: y)
                    .opacity(animatedProgress > CGFloat(index) / CGFloat(data.count) ? 1 : 0)
                    .onTapGesture {
                        selectedPoint = point
                    }
            }
        }
    }

    private func sessionBars(width: CGFloat, height: CGFloat) -> some View {
        let maxSessions = max(data.map { $0.sessionCount }.max() ?? 1, 1)

        return ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
            if point.sessionCount > 0 {
                let x = width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                let barHeight = CGFloat(point.sessionCount) / CGFloat(maxSessions) * 30

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 16, height: barHeight * animatedProgress)
                    .position(x: x, y: height - barHeight * animatedProgress / 2)
            }
        }
    }

    private var dayLabels: some View {
        HStack {
            ForEach(data) { point in
                Text(formatDayLabel(point.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func formatDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(3))
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<7).map { offset -> TrendDataPoint in
        let date = calendar.date(byAdding: .day, value: -6 + offset, to: today) ?? today
        let score = Double.random(in: 40...90)
        let count = Int.random(in: 0...3)
        return TrendDataPoint(date: date, score: count > 0 ? score : 0, sessionCount: count)
    }

    return VStack(spacing: 20) {
        TrendChartView(data: sampleData)

        TrendChartView(data: [])
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
