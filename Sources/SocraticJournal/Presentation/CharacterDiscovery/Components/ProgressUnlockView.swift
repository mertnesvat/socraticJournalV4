// ProgressUnlockView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the progress toward unlocking character discovery
struct ProgressUnlockView: View {
    let unlockState: CharacterDiscoveryUnlockState
    let totalEntries: Int

    var body: some View {
        VStack(spacing: 16) {
            // Progress ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)

                // Progress circle
                Circle()
                    .trim(from: 0, to: unlockState.progressPercent / 100.0)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 4) {
                    Text("\(Int(unlockState.progressPercent))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(progressColor)

                    Text("Unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            // Status message
            Text(unlockState.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Entry count
            HStack(spacing: 4) {
                Image(systemName: "book.closed.fill")
                    .foregroundStyle(progressColor)
                Text("\(totalEntries) journal \(totalEntries == 1 ? "entry" : "entries")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // State-specific content
            stateContent
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var stateContent: some View {
        switch unlockState {
        case .locked(_, let entriesNeeded):
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Keep journaling to discover your personality profile")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)

                if entriesNeeded <= 5 {
                    Text("Only \(entriesNeeded) more \(entriesNeeded == 1 ? "session" : "sessions") to go!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(progressColor)
                }
            }

        case .sample:
            HStack(spacing: 6) {
                Image(systemName: "eye.fill")
                    .foregroundStyle(.orange)
                Text("Preview Available")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())

        case .available:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Full Access")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    private var progressColor: Color {
        switch unlockState {
        case .locked: return .gray
        case .sample: return .orange
        case .available: return .green
        }
    }
}

#Preview("Locked") {
    ProgressUnlockView(
        unlockState: .locked(progress: 15, entriesNeeded: 2),
        totalEntries: 1
    )
    .padding()
}

#Preview("Sample") {
    ProgressUnlockView(
        unlockState: .sample(progress: 35),
        totalEntries: 3
    )
    .padding()
}

#Preview("Available") {
    ProgressUnlockView(
        unlockState: .available(progress: 65),
        totalEntries: 8
    )
    .padding()
}
#endif
