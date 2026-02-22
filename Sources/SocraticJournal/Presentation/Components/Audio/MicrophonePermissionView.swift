// MicrophonePermissionView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Custom permission request UI for microphone access.
/// Shows a friendly prompt before triggering the system permission dialog,
/// or an "Open Settings" option if the permission was previously denied.
public struct MicrophonePermissionView: View {
    /// Called when the user taps the enable microphone button
    let onRequestPermission: () -> Void

    /// Called when the user taps "Open Settings"
    let onOpenSettings: () -> Void

    /// Whether the microphone permission was previously denied
    var permissionDenied: Bool = false

    public init(
        onRequestPermission: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void,
        permissionDenied: Bool = false
    ) {
        self.onRequestPermission = onRequestPermission
        self.onOpenSettings = onOpenSettings
        self.permissionDenied = permissionDenied
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Microphone icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }

            // Title and subtitle
            VStack(spacing: 8) {
                Text("Socratic needs your microphone")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text("To record your voice answers, we need microphone access.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Action buttons
            VStack(spacing: 12) {
                if permissionDenied {
                    // Permission was denied: show "Open Settings"
                    Button(action: onOpenSettings) {
                        HStack(spacing: 8) {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Text("You previously denied microphone access. You can re-enable it in Settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else {
                    // Permission not yet requested: show "Enable Microphone"
                    Button(action: onRequestPermission) {
                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                            Text("Enable Microphone")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Not Yet Requested") {
    MicrophonePermissionView(
        onRequestPermission: {},
        onOpenSettings: {},
        permissionDenied: false
    )
    .preferredColorScheme(.dark)
}

#Preview("Permission Denied") {
    MicrophonePermissionView(
        onRequestPermission: {},
        onOpenSettings: {},
        permissionDenied: true
    )
    .preferredColorScheme(.dark)
}

#endif
