// PhaseLabelView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the current breath phase name and countdown timer
public struct PhaseLabelView: View {
    let phaseName: String
    let countdown: Int
    let timing: String
    let isRunning: Bool
    let phaseColorHex: String

    public var body: some View {
        VStack(spacing: 6) {
            Text(phaseName.lowercased())
                .font(.system(size: 28, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(Color(hex: phaseColorHex))
                .animation(.easeInOut(duration: 0.4), value: phaseColorHex)

            Text(isRunning ? "\(countdown)s" : timing)
                .font(.system(size: 13, design: .default))
                .foregroundStyle(AppColors.textTertiary)
                .monospacedDigit()
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        PhaseLabelView(
            phaseName: "inhale",
            countdown: 4,
            timing: "5.5 · 5.5",
            isRunning: true,
            phaseColorHex: "2D5F5D"
        )
        PhaseLabelView(
            phaseName: "exhale",
            countdown: 0,
            timing: "5.5 · 5.5",
            isRunning: false,
            phaseColorHex: "C4502A"
        )
    }
    .padding()
    .background(AppColors.background)
}
#endif
