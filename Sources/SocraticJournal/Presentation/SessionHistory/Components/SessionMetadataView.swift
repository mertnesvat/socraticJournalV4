// SessionMetadataView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays session metadata: date, time, duration, and exchange stats
struct SessionMetadataView: View {
    let date: String
    let time: String
    let duration: String
    let exchangeCount: Int
    let answeredCount: Int
    let skippedCount: Int

    var body: some View {
        VStack(spacing: 12) {
            // Date and time row
            HStack(spacing: 16) {
                MetadataItem(
                    icon: "calendar",
                    title: "Date",
                    value: date,
                    color: .blue
                )

                MetadataItem(
                    icon: "clock",
                    title: "Time",
                    value: time,
                    color: .purple
                )

                MetadataItem(
                    icon: "timer",
                    title: "Duration",
                    value: duration,
                    color: .green
                )
            }

            Divider()
                .padding(.horizontal)

            // Exchange stats row
            HStack(spacing: 16) {
                StatItem(
                    value: "\(exchangeCount)",
                    label: "Questions",
                    color: .blue
                )

                StatItem(
                    value: "\(answeredCount)",
                    label: "Answered",
                    color: .green
                )

                if skippedCount > 0 {
                    StatItem(
                        value: "\(skippedCount)",
                        label: "Skipped",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        .padding(.horizontal)
    }
}

/// Individual metadata item with icon
private struct MetadataItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Individual stat item
private struct StatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        SessionMetadataView(
            date: "Jan 15, 2024",
            time: "10:30 AM",
            duration: "8 min",
            exchangeCount: 4,
            answeredCount: 3,
            skippedCount: 1
        )

        SessionMetadataView(
            date: "Jan 14, 2024",
            time: "2:15 PM",
            duration: "12 min",
            exchangeCount: 6,
            answeredCount: 6,
            skippedCount: 0
        )
    }
    .padding(.vertical)
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
