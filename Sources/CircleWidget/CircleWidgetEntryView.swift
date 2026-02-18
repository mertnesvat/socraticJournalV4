// CircleWidgetEntryView.swift
// CircleWidget
// Copyright 2024 StudioNext

import SwiftUI
import WidgetKit

// MARK: - Theme Colors (inline for widget extension)

/// Widget-specific theme colors matching the main app's CircleTheme.
/// Defined inline because the widget extension cannot share the main app's theme file.
private enum WidgetTheme {
    /// Warm amber -- primary accent
    static let warmAmber = Color(red: 0.87, green: 0.65, blue: 0.33)

    /// Soft cream -- light backgrounds
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.92)

    /// Deep warm brown -- text on light backgrounds
    static let warmBrown = Color(red: 0.30, green: 0.22, blue: 0.15)

    /// Warm orange -- gradient end
    static let warmOrange = Color(red: 0.90, green: 0.52, blue: 0.25)

    /// Muted text color
    static let mutedText = Color(red: 0.55, green: 0.48, blue: 0.40)

    /// Background gradient
    static let backgroundGradient = LinearGradient(
        colors: [cream, Color(red: 0.96, green: 0.93, blue: 0.87)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Main Entry View

/// The primary view that switches between small and medium widget layouts.
struct CircleWidgetEntryView: View {
    let entry: CircleWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.widgetData)
        case .systemMedium:
            MediumWidgetView(data: entry.widgetData)
        default:
            SmallWidgetView(data: entry.widgetData)
        }
    }
}

// MARK: - Small Widget (2x2)

/// Small widget layout: circle icon + name at top, latest response or waiting message.
struct SmallWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Circle header
            HStack(spacing: 4) {
                Image(systemName: data.circleIcon)
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.warmAmber)
                Text(data.circleName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetTheme.warmBrown)
            }

            Spacer()

            if let latestResponse = data.responses.first {
                // Latest response
                VStack(alignment: .leading, spacing: 2) {
                    Text(latestResponse.memberName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(WidgetTheme.warmBrown)

                    Text(latestResponse.transcriptSnippet.isEmpty
                         ? "Shared a voice note"
                         : latestResponse.transcriptSnippet)
                        .font(.caption2)
                        .foregroundStyle(WidgetTheme.mutedText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            } else {
                // Empty state
                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: "waveform")
                        .font(.title3)
                        .foregroundStyle(WidgetTheme.warmAmber.opacity(0.6))
                    Text("Waiting for voices...")
                        .font(.caption2)
                        .foregroundStyle(WidgetTheme.mutedText)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .background(WidgetTheme.backgroundGradient)
        .widgetURL(URL(string: "circle://feed"))
    }
}

// MARK: - Medium Widget (4x2)

/// Medium widget layout: prompt text at top, 2-3 response previews below.
struct MediumWidgetView: View {
    let data: WidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row: circle info + prompt
            HStack(spacing: 6) {
                Image(systemName: data.circleIcon)
                    .font(.caption)
                    .foregroundStyle(WidgetTheme.warmAmber)
                Text(data.circleName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetTheme.warmBrown)
                Spacer()
                Text(responseCountText)
                    .font(.caption2)
                    .foregroundStyle(WidgetTheme.mutedText)
            }

            // Prompt text
            Text(data.promptText)
                .font(.footnote.weight(.medium))
                .foregroundStyle(WidgetTheme.warmBrown)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 2)

            if data.responses.isEmpty {
                // Empty state
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.subheadline)
                        .foregroundStyle(WidgetTheme.warmAmber.opacity(0.6))
                    Text("Waiting for voices...")
                        .font(.caption)
                        .foregroundStyle(WidgetTheme.mutedText)
                }
            } else {
                // Response previews (up to 3)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(data.responses.prefix(3).enumerated()), id: \.offset) { _, response in
                        ResponsePreviewRow(response: response)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .background(WidgetTheme.backgroundGradient)
        .widgetURL(URL(string: "circle://feed"))
    }

    private var responseCountText: String {
        let count = data.responses.count
        if count == 0 { return "" }
        return "\(count) voice\(count == 1 ? "" : "s")"
    }
}

// MARK: - Response Preview Row

/// A single response preview row showing member name and transcript snippet.
struct ResponsePreviewRow: View {
    let response: WidgetResponse

    var body: some View {
        HStack(spacing: 6) {
            // Member initial circle
            Text(initial)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(WidgetTheme.warmAmber)
                .clipShape(SwiftUI.Circle())

            // Name and snippet
            VStack(alignment: .leading, spacing: 0) {
                Text(response.memberName)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(WidgetTheme.warmBrown)

                Text(response.transcriptSnippet.isEmpty
                     ? "Shared a voice note"
                     : response.transcriptSnippet)
                    .font(.system(size: 10))
                    .foregroundStyle(WidgetTheme.mutedText)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private var initial: String {
        let components = response.memberName
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        guard let first = components.first else { return "?" }

        if components.count >= 2, let last = components.last {
            return "\(first.prefix(1))\(last.prefix(1))".uppercased()
        }

        return first.prefix(1).uppercased()
    }
}

// MARK: - Previews

#if DEBUG
struct CircleWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Small widget with data
            CircleWidgetEntryView(
                entry: CircleWidgetEntry(date: Date(), widgetData: .preview)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small - With Data")

            // Small widget empty
            CircleWidgetEntryView(
                entry: CircleWidgetEntry(date: Date(), widgetData: .empty)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small - Empty")

            // Medium widget with data
            CircleWidgetEntryView(
                entry: CircleWidgetEntry(date: Date(), widgetData: .preview)
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium - With Data")

            // Medium widget empty
            CircleWidgetEntryView(
                entry: CircleWidgetEntry(date: Date(), widgetData: .empty)
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium - Empty")
        }
    }
}
#endif
