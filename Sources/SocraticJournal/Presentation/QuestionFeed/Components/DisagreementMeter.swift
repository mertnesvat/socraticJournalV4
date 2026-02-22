// DisagreementMeter.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Visual meter showing the opinion split — large geometric donut ring with percentage
public struct DisagreementMeter: View {
    let disagreementRatio: Double
    let responseCount: Int

    public init(disagreementRatio: Double, responseCount: Int) {
        self.disagreementRatio = disagreementRatio
        self.responseCount = responseCount
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Giant donut ring with percentage inside
            ZStack {
                GeometricRing(
                    progress: disagreementRatio,
                    size: 200,
                    lineWidth: 28,
                    accentColor: AppColors.accent,
                    trackColor: AppColors.border
                )

                // Percentage inside the ring
                Text(percentageText)
                    .font(AppTypography.stat)
                    .foregroundStyle(AppColors.textPrimary)
            }

            // Response count below the ring
            VStack(spacing: AppSpacing.xxs) {
                Text(formattedResponseCount)
                    .font(AppTypography.headlineMedium)
                    .foregroundStyle(AppColors.textPrimary)

                Text("responses")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var percentageText: String {
        "\(Int(disagreementRatio * 100))%"
    }

    private var formattedResponseCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: responseCount)) ?? "\(responseCount)"
    }
}

#Preview {
    VStack(spacing: AppSpacing.sectionGap) {
        DisagreementMeter(
            disagreementRatio: 0.81,
            responseCount: 1203
        )

        DisagreementMeter(
            disagreementRatio: 0.45,
            responseCount: 12400
        )
    }
    .padding()
    .background(AppColors.background)
}
#endif
