// RecordingTimer.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Monospace timer display showing elapsed recording time in M:SS format
/// Includes a max duration indicator to show the recording limit
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
        HStack(spacing: 4) {
            // Elapsed time
            Text(formattedTime(elapsedTime))
                .font(.system(size: isActive ? 28 : 24, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(isActive ? Color.white : Color.white.opacity(0.4))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: formattedTime(elapsedTime))

            // Max duration indicator
            Text("/ \(formattedTime(maxDuration))")
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color.white.opacity(0.25))
        }
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
        Color.black.ignoresSafeArea()
        RecordingTimer(elapsedTime: 12.5, isActive: true)
    }
}

#Preview("Inactive") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingTimer(elapsedTime: 0, isActive: false)
    }
}

#Preview("Near Max") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingTimer(elapsedTime: 55, isActive: true)
    }
}

#endif
