// RecordingStateLabel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Animated text label showing the current recording state
/// Transitions smoothly between idle, recording, and recorded states
public struct RecordingStateLabel: View {
    let state: RecordingState

    /// Controls the pulsing animation for the recording indicator dot
    @State private var isPulsing: Bool = false

    public init(state: RecordingState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Red dot indicator during recording
            if case .recording = state {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .opacity(isPulsing ? 0.4 : 1.0)
            }

            Text(labelText)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(labelColor)
        }
        .contentTransition(.interpolate)
        .animation(.easeInOut(duration: 0.3), value: labelText)
        .onChange(of: state) { _, newState in
            if case .recording = newState {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }

    // MARK: - Computed Properties

    private var labelText: String {
        switch state {
        case .idle:
            return "Tap to record"
        case .recording:
            return "Recording..."
        case .recorded:
            return "Tap play to preview"
        case .submitting:
            return "Submitting..."
        }
    }

    private var labelColor: Color {
        switch state {
        case .idle:
            return Color.white.opacity(0.5)
        case .recording:
            return Color.white.opacity(0.9)
        case .recorded:
            return Color.white.opacity(0.7)
        case .submitting:
            return Color.white.opacity(0.5)
        }
    }
}

// MARK: - Preview

#Preview("Idle") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingStateLabel(state: .idle)
    }
}

#Preview("Recording") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingStateLabel(state: .recording)
    }
}

#Preview("Recorded") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordingStateLabel(state: .recorded(audioURL: "/test"))
    }
}

#endif
