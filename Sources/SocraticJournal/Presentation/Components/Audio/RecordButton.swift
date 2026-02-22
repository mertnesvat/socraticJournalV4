// RecordButton.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Massive filled coral-red circle record button -- the visual hero of the recording studio.
/// When idle: static filled circle, no decoration.
/// When recording: pulsing ring animation around it.
public struct RecordButton: View {
    /// Whether the button is in the recording state
    let isRecording: Bool

    /// Action triggered on tap
    let action: () -> Void

    /// Controls the pulsing ring animation
    @State private var isPulsing: Bool = false

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
                        .stroke(AppColors.accent.opacity(0.4), lineWidth: 3)
                        .frame(
                            width: AppSpacing.recordButtonSize,
                            height: AppSpacing.recordButtonSize
                        )
                        .scaleEffect(isPulsing ? 1.4 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.6)
                }

                // Main filled circle -- massive coral-red
                Circle()
                    .fill(AppColors.accent)
                    .frame(
                        width: AppSpacing.recordButtonSize,
                        height: AppSpacing.recordButtonSize
                    )

                // Stop square when recording
                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.textOnAccent)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(
                width: AppSpacing.recordButtonSize + 40,
                height: AppSpacing.recordButtonSize + 40
            )
        }
        .buttonStyle(.plain)
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
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
        AppColors.backgroundDark.ignoresSafeArea()
        RecordButton(isRecording: false) {}
    }
}

#Preview("Recording State") {
    ZStack {
        AppColors.backgroundDark.ignoresSafeArea()
        RecordButton(isRecording: true) {}
    }
}

#endif
