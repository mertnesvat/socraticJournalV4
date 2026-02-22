// RecordButton.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A large circular record button with pulse animation when recording.
/// Displays a white circle with inner red dot when idle, and a full red circle
/// with a pulsing ring animation when recording.
public struct RecordButton: View {
    /// Whether the button is in the recording state
    let isRecording: Bool

    /// Action triggered on tap
    let action: () -> Void

    /// Controls the pulsing ring animation
    @State private var isPulsing: Bool = false

    /// Diameter of the button
    private let diameter: CGFloat = 80

    public init(isRecording: Bool, action: @escaping () -> Void) {
        self.isRecording = isRecording
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                // Pulsing ring (visible only when recording)
                if isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.4), lineWidth: 3)
                        .frame(width: diameter, height: diameter)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.6)
                }

                // Outer circle (white border)
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: diameter, height: diameter)

                // Inner shape: red circle (small when idle, full when recording)
                RoundedRectangle(cornerRadius: isRecording ? 8 : diameter / 2)
                    .fill(Color.red)
                    .frame(
                        width: isRecording ? diameter * 0.4 : diameter - 12,
                        height: isRecording ? diameter * 0.4 : diameter - 12
                    )
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .frame(width: diameter + 20, height: diameter + 20)
            .shadow(
                color: isRecording ? Color.red.opacity(0.5) : Color.black.opacity(0.3),
                radius: isRecording ? 12 : 6,
                x: 0,
                y: isRecording ? 0 : 3
            )
        }
        .buttonStyle(.plain)
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Idle State") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordButton(isRecording: false) {
            // No-op
        }
    }
}

#Preview("Recording State") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordButton(isRecording: true) {
            // No-op
        }
    }
}

#endif
