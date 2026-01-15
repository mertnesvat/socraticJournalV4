// SummaryNarrativeView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the overall personality summary narrative
struct SummaryNarrativeView: View {
    let summary: String
    let analyzedAt: Date
    let isSample: Bool
    let canRefresh: Bool
    let isRefreshing: Bool
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Your Story")
                    .font(.headline)

                Spacer()

                if canRefresh {
                    Button {
                        onRefresh()
                    } label: {
                        HStack(spacing: 4) {
                            if isRefreshing {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Refresh")
                        }
                        .font(.caption)
                    }
                    .disabled(isRefreshing)
                }
            }

            // Summary text
            Text(summary)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(6)

            // Sample disclaimer or last analyzed timestamp
            if isSample {
                sampleDisclaimer
            } else {
                lastAnalyzedView
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var sampleDisclaimer: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text("This is a sample profile. Continue journaling to see your personalized insights.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var lastAnalyzedView: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
            Text("Last analyzed: \(formattedDate)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: analyzedAt, relativeTo: Date())
    }
}

#Preview("Full Profile") {
    SummaryNarrativeView(
        summary: "Your journal entries reveal a thoughtful individual who values self-reflection. You show a balance between analytical thinking and emotional awareness, approaching life's challenges with both curiosity and care. Your personality profile suggests someone who seeks understanding through introspection.",
        analyzedAt: Date().addingTimeInterval(-3600),
        isSample: false,
        canRefresh: true,
        isRefreshing: false,
        onRefresh: {}
    )
    .padding()
}

#Preview("Sample Profile") {
    SummaryNarrativeView(
        summary: "This is a sample profile based on typical journaling patterns. Continue journaling to receive your personalized personality insights based on your unique reflections and experiences.",
        analyzedAt: Date(),
        isSample: true,
        canRefresh: false,
        isRefreshing: false,
        onRefresh: {}
    )
    .padding()
}

#Preview("Refreshing") {
    SummaryNarrativeView(
        summary: "Your personality profile is being updated...",
        analyzedAt: Date(),
        isSample: false,
        canRefresh: true,
        isRefreshing: true,
        onRefresh: {}
    )
    .padding()
}
#endif
