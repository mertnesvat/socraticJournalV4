// RecordingStateLabel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ALL-CAPS editorial state label with tracking
/// Minimal text indicator for the recording flow state
public struct RecordingStateLabel: View {
    let state: RecordingState

    public init(state: RecordingState) {
        self.state = state
    }

    public var body: some View {
        Text(labelText.uppercased())
            .font(AppTypography.sectionHeader)
            .tracking(AppTypography.sectionHeaderTracking)
            .foregroundStyle(AppColors.textOnDark.opacity(0.5))
            .contentTransition(.interpolate)
            .animation(.easeInOut(duration: 0.3), value: labelText)
    }

    // MARK: - Computed Properties

    private var labelText: String {
        switch state {
        case .idle:
            return "Tap to Record"
        case .recording:
            return "Recording"
        case .recorded:
            return "Review"
        case .submitting:
            return "Submitting"
        }
    }
}

// MARK: - Preview

#Preview("Idle") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingStateLabel(state: .idle)
    }
}

#Preview("Recording") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingStateLabel(state: .recording)
    }
}

#Preview("Recorded") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordingStateLabel(state: .recorded(audioURL: "/test"))
    }
}

#endif
