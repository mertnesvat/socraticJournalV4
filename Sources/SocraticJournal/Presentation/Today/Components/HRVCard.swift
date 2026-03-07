// HRVCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// HRV display card for the Today tab — only shown when HealthKit is authorized with data
struct HRVCard: View {
    let latestHRV: Double

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("HEART RATE VARIABILITY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(AppColors.accent)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.0f", latestHRV))
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("ms")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppColors.accent.opacity(0.5))
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.accent.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
#endif
