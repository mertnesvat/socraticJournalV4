// UnlockCountdown.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays a countdown timer until letter unlock date
public struct UnlockCountdown: View {
    let days: Int
    let hours: Int
    let minutes: Int

    public init(days: Int, hours: Int, minutes: Int) {
        self.days = days
        self.hours = hours
        self.minutes = minutes
    }

    public var body: some View {
        HStack(spacing: 16) {
            if days > 0 {
                countdownUnit(value: days, label: "Days")
            }

            countdownUnit(value: hours, label: "Hours")

            if days == 0 {
                countdownUnit(value: minutes, label: "Minutes")
            }
        }
        .padding(.vertical, 12)
    }

    private func countdownUnit(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(minWidth: 60)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Displays a more compact countdown for list views
public struct CompactCountdown: View {
    let days: Int
    let hours: Int
    let minutes: Int

    public init(days: Int, hours: Int, minutes: Int) {
        self.days = days
        self.hours = hours
        self.minutes = minutes
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption2)

            if days > 0 {
                Text("\(days)d \(hours)h")
            } else if hours > 0 {
                Text("\(hours)h \(minutes)m")
            } else {
                Text("\(minutes)m")
            }
        }
        .font(.caption)
        .foregroundStyle(.orange)
    }
}

#Preview {
    VStack(spacing: 32) {
        VStack(spacing: 8) {
            Text("Long Duration")
                .font(.caption)
                .foregroundStyle(.secondary)

            UnlockCountdown(days: 45, hours: 12, minutes: 30)
        }

        VStack(spacing: 8) {
            Text("Short Duration")
                .font(.caption)
                .foregroundStyle(.secondary)

            UnlockCountdown(days: 0, hours: 5, minutes: 45)
        }

        VStack(spacing: 8) {
            Text("Very Short")
                .font(.caption)
                .foregroundStyle(.secondary)

            UnlockCountdown(days: 0, hours: 0, minutes: 15)
        }

        Divider()

        VStack(spacing: 8) {
            Text("Compact Versions")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                CompactCountdown(days: 30, hours: 12, minutes: 0)
                CompactCountdown(days: 0, hours: 5, minutes: 30)
                CompactCountdown(days: 0, hours: 0, minutes: 15)
            }
        }
    }
    .padding()
}
#endif
