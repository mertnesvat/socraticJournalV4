// PhaseLabel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays current phase name and countdown
struct PhaseLabel: View {
    let phaseName: String
    let timeRemaining: TimeInterval

    var body: some View {
        VStack(spacing: 4) {
            Text(phaseName)
                .font(AppTypography.headline)
                .foregroundStyle(.white)

            Text(String(format: "%.1fs", timeRemaining))
                .font(AppTypography.timer)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
#endif
