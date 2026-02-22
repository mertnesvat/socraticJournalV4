// RecordingTimer.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Bold stat timer display showing elapsed recording time in M:SS format
/// No additional chrome -- just the raw time string in bold type
public struct RecordingTimer: View {
    /// Elapsed time in seconds
    let elapsedTime: TimeInterval

    /// Whether the timer is actively counting (recording in progress)
    let isActive: Bool

    /// Maximum recording duration in seconds
    var maxDuration: TimeInterval = 60

    public init(
        elapsedTime: TimeInterval,
        isActive: Bool,
        maxDuration: TimeInterval = 60
    ) {
        self.elapsedTime = elapsedTime
        self.isActive = isActive
        self.maxDuration = maxDuration
    }

    public var body: some View {
        Text(formattedTime(elapsedTime))
            .font(AppTypography.statSmall)
            .monospacedDigit()
            .foregroundStyle(isActive ? AppColors.accent : AppColors.textOnDark)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.15), value: formattedTime(elapsedTime))
    }

    // MARK: - Time Formatting

    /// Formats a time interval as M:SS
    private func formattedTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Active") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingTimer(elapsedTime: 12.5, isActive: true)
    }
}

#Preview("Inactive") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingTimer(elapsedTime: 0, isActive: false)
    }
}

#Preview("Near Max") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingTimer(elapsedTime: 55, isActive: true)
    }
}

#endif
