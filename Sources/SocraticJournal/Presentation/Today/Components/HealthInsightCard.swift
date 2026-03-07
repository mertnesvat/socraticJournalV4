// HealthInsightCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Resting HR and HRV tiles showing Apple Health cardiovascular data
public struct HealthInsightCard: View {
    let healthKitService: HealthKitServiceProtocol

    @State private var restingHR: Double?
    @State private var hrTrend: Trend = .flat
    @State private var hrv: Double?
    @State private var hrvTrend: Trend = .flat
    @State private var isHidden: Bool = true
    @State private var showConnectRow: Bool = false

    enum Trend {
        case improving, worsening, flat
        var symbol: String {
            switch self { case .improving: return "↑"; case .worsening: return "↓"; case .flat: return "→" }
        }
        var color: Color {
            switch self { case .improving: return AppColors.accent; case .worsening: return AppColors.accent2; case .flat: return AppColors.textTertiary }
        }
    }

    public var body: some View {
        Group {
            if showConnectRow {
                connectHealthRow
            } else if !isHidden {
                healthMetricsRow
            }
        }
        .task { await loadHealthData() }
    }

    // MARK: - Metrics Row

    private var healthMetricsRow: some View {
        HStack(spacing: 0) {
            metricTile(
                label: "RESTING HR",
                value: restingHR.map { String(format: "%.0f", $0) } ?? "—",
                unit: "bpm",
                trend: hrTrend
            )

            HairlineDivider(axis: .vertical)
                .frame(height: 100)

            metricTile(
                label: "HRV",
                value: hrv.map { String(format: "%.0f", $0) } ?? "—",
                unit: "ms",
                trend: hrvTrend
            )
        }
    }

    private func metricTile(label: String, value: String, unit: String, trend: Trend) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(trend.symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(trend.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.cardPadding)
    }

    // MARK: - Connect Row

    private var connectHealthRow: some View {
        Button {
            Task {
                try? await healthKitService.requestAuthorization()
                await loadHealthData()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.accent2)

                Text("Connect Apple Health")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(AppSpacing.cardPadding)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data Loading

    private func loadHealthData() async {
        guard healthKitService.isAvailable else { return }

        async let hrSamples = try? healthKitService.fetchRestingHeartRate(lastDays: 14)
        async let hrvSamples = try? healthKitService.fetchHRV(lastDays: 14)

        let (hrData, hrvData) = await (hrSamples, hrvSamples)

        guard let hrData, let hrvData else {
            showConnectRow = true
            return
        }

        if hrData.isEmpty && hrvData.isEmpty {
            showConnectRow = true
            return
        }

        showConnectRow = false

        if let latestHR = hrData.last?.bpm {
            restingHR = latestHR
            hrTrend = computeHRTrend(from: hrData)
        }

        if let latestHRV = hrvData.last?.sdnn {
            hrv = latestHRV
            hrvTrend = computeHRVTrend(from: hrvData)
        }

        if restingHR != nil || hrv != nil {
            isHidden = false
        }
    }

    private func computeHRTrend(from data: [(date: Date, bpm: Double)]) -> Trend {
        let half = data.count / 2
        guard half > 0 else { return .flat }
        let recent = data.suffix(half).map(\.bpm)
        let older = data.prefix(half).map(\.bpm)
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        let diff = recentAvg - olderAvg
        if diff < -1 { return .improving }
        if diff > 1 { return .worsening }
        return .flat
    }

    private func computeHRVTrend(from data: [(date: Date, sdnn: Double)]) -> Trend {
        let half = data.count / 2
        guard half > 0 else { return .flat }
        let recent = data.suffix(half).map(\.sdnn)
        let older = data.prefix(half).map(\.sdnn)
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        let diff = recentAvg - olderAvg
        if diff > 1 { return .improving }
        if diff < -1 { return .worsening }
        return .flat
    }
}
#endif
