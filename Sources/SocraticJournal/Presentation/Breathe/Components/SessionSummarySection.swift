// SessionSummarySection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Three-column summary showing duration, cycles, and pattern for a completed session
struct SessionSummarySection: View {
    let durationSeconds: TimeInterval
    let cyclesCompleted: Int
    let patternName: String
    let patternTiming: String

    private var durationFormatted: String {
        let total = Int(durationSeconds)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("Session", showTopBorder: false)

            HStack(spacing: 0) {
                // Duration column
                statColumn(
                    value: durationFormatted,
                    label: "minutes"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 56)

                // Cycles column
                statColumn(
                    value: "\(cyclesCompleted)",
                    label: "cycles"
                )

                HairlineDivider(axis: .vertical)
                    .frame(height: 56)

                // Pattern column
                VStack(spacing: 4) {
                    Text(patternName)
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(patternTiming)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.md)

            HairlineDivider()
        }
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SessionSummarySection(
        durationSeconds: 305,
        cyclesCompleted: 12,
        patternName: "Resonance",
        patternTiming: "5.5 · 5.5"
    )
    .background(AppColors.background)
}
#endif
