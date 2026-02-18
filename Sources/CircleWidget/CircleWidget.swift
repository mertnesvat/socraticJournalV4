// CircleWidget.swift
// CircleWidget Extension
// Copyright 2024 StudioNext

import WidgetKit
import SwiftUI

// MARK: - Shared Data Models (duplicated from main app)

/// Data model shared between the main app and the widget via UserDefaults JSON.
/// This struct is duplicated from the main app — keep both in sync.
struct WidgetData: Codable, Sendable {
    let circleEmoji: String
    let circleName: String
    let promptText: String
    let memberResponses: [MemberResponse]
    let respondedCount: Int
    let totalMembers: Int
    let updatedAt: Date
}

/// Represents a single member's response status for the widget.
/// This struct is duplicated from the main app — keep both in sync.
struct MemberResponse: Codable, Sendable {
    let displayName: String
    let transcriptSnippet: String?
    let hasResponded: Bool
}

// MARK: - Timeline Entry

struct CircleWidgetEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
}

// MARK: - Timeline Provider

struct CircleTimelineProvider: TimelineProvider {

    private let suiteName = "group.com.StudioNext.socraticJournal"
    private let widgetDataKey = "circleWidgetData"

    func placeholder(in context: Context) -> CircleWidgetEntry {
        CircleWidgetEntry(date: Date(), widgetData: sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (CircleWidgetEntry) -> Void) {
        let data = readWidgetData()
        let entry = CircleWidgetEntry(date: Date(), widgetData: data ?? sampleData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CircleWidgetEntry>) -> Void) {
        let data = readWidgetData()
        let entry = CircleWidgetEntry(date: Date(), widgetData: data)

        // Refresh again in 1 hour
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Helpers

    private func readWidgetData() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: widgetDataKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(WidgetData.self, from: data)
    }

    private var sampleData: WidgetData {
        WidgetData(
            circleEmoji: "🌿",
            circleName: "Family",
            promptText: "What made you smile today?",
            memberResponses: [
                MemberResponse(displayName: "Mom", transcriptSnippet: "I saw the most beautiful sunset on my walk...", hasResponded: true),
                MemberResponse(displayName: "Dad", transcriptSnippet: nil, hasResponded: false),
                MemberResponse(displayName: "You", transcriptSnippet: "Had a great lunch with an old friend today...", hasResponded: true)
            ],
            respondedCount: 2,
            totalMembers: 3,
            updatedAt: Date()
        )
    }
}

// MARK: - Widget Entry View (delegates to size-specific views)

struct CircleWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CircleWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.widgetData)
        case .systemMedium:
            MediumWidgetView(data: entry.widgetData)
        case .systemLarge:
            LargeWidgetView(data: entry.widgetData)
        default:
            SmallWidgetView(data: entry.widgetData)
        }
    }
}

// MARK: - Small Widget View

/// Compact view: circle emoji, prompt text (2-line truncated), X/Y answered count.
struct SmallWidgetView: View {
    let data: WidgetData?

    var body: some View {
        if let data = data, !data.promptText.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(data.circleEmoji)
                        .font(.title3)
                    Text(data.circleName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 2)

                Text(data.promptText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 2)

                HStack(spacing: 4) {
                    Image(systemName: "mic.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(data.respondedCount)/\(data.totalMembers) answered")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.circle")
                .font(.title)
                .foregroundStyle(.secondary)

            if data == nil {
                Text("Create a circle to get started")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Waiting for today's prompt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget View

/// Wider view: prompt text and horizontal row of member initials with responded checkmarks.
struct MediumWidgetView: View {
    let data: WidgetData?

    var body: some View {
        if let data = data, !data.promptText.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                // Header row
                HStack(spacing: 4) {
                    Text(data.circleEmoji)
                        .font(.body)
                    Text(data.circleName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(data.respondedCount)/\(data.totalMembers)")
                        .font(.caption.weight(.medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                // Prompt text
                Text(data.promptText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                // Member initials row
                HStack(spacing: 10) {
                    ForEach(Array(data.memberResponses.prefix(5).enumerated()), id: \.offset) { _, member in
                        memberBubble(for: member)
                    }

                    Spacer()
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            mediumEmptyState
        }
    }

    private func memberBubble(for member: MemberResponse) -> some View {
        VStack(spacing: 3) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor(for: member.displayName))
                    .frame(width: 32, height: 32)
                    .opacity(member.hasResponded ? 1.0 : 0.4)
                    .overlay(
                        Text(initials(for: member.displayName))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                    )

                if member.hasResponded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.green)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 12, height: 12)
                        )
                }
            }

            Text(firstName(for: member.displayName))
                .font(.system(size: 9))
                .foregroundStyle(member.hasResponded ? .primary : .tertiary)
                .lineLimit(1)
        }
    }

    private var mediumEmptyState: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                if data == nil {
                    Text("Create a circle to get started")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text("Share daily moments with the people you love.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Waiting for today's prompt")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text("Check back soon for a new question.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Large Widget View

/// Full-size view: prompt text and a list of member names with transcript snippets.
struct LargeWidgetView: View {
    let data: WidgetData?

    var body: some View {
        if let data = data, !data.promptText.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 4) {
                    Text(data.circleEmoji)
                        .font(.title3)
                    Text(data.circleName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(data.respondedCount)/\(data.totalMembers) answered")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                // Prompt
                Text(data.promptText)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(3)

                Divider()
                    .padding(.vertical, 2)

                // Member responses list
                VStack(spacing: 8) {
                    ForEach(Array(data.memberResponses.prefix(5).enumerated()), id: \.offset) { _, member in
                        memberRow(for: member)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            largeEmptyState
        }
    }

    private func memberRow(for member: MemberResponse) -> some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor(for: member.displayName))
                    .frame(width: 30, height: 30)
                    .opacity(member.hasResponded ? 1.0 : 0.4)
                    .overlay(
                        Text(initials(for: member.displayName))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                    )

                if member.hasResponded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.green)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 11, height: 11)
                        )
                }
            }

            // Name and snippet
            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(member.hasResponded ? .primary : .secondary)

                if member.hasResponded {
                    if let snippet = member.transcriptSnippet {
                        Text(snippet)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Responded with a voice note")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .italic()
                    }
                } else {
                    Text("Hasn't responded yet")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
    }

    private var largeEmptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                if data == nil {
                    Text("Create a circle to get started")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Share daily moments with\nthe people you love.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Waiting for today's prompt")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Check back soon for a new\nquestion from your circle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Definition

struct CircleWidget: Widget {
    let kind: String = "CircleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CircleTimelineProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                CircleWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CircleWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Circle")
        .description("Stay connected with your circle.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle Entry Point

@main
struct CircleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CircleWidget()
    }
}

// MARK: - Shared Helpers

/// Generate a consistent color from a display name string (for member avatars).
private func avatarColor(for name: String) -> Color {
    let colors: [Color] = [
        .blue, .green, .orange, .pink, .purple, .teal, .indigo, .mint, .cyan
    ]
    let hash = abs(name.hashValue)
    return colors[hash % colors.count]
}

/// Extract the first name from a display name.
private func firstName(for displayName: String) -> String {
    displayName.components(separatedBy: " ").first ?? displayName
}

/// Extract initials from a display name.
private func initials(for displayName: String) -> String {
    let components = displayName.split(separator: " ")
    if components.count >= 2 {
        return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
    }
    return String(displayName.prefix(2)).uppercased()
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CircleWidget()
} timeline: {
    CircleWidgetEntry(date: Date(), widgetData: previewData)
    CircleWidgetEntry(date: Date(), widgetData: nil)
}

#Preview("Medium", as: .systemMedium) {
    CircleWidget()
} timeline: {
    CircleWidgetEntry(date: Date(), widgetData: previewData)
    CircleWidgetEntry(date: Date(), widgetData: nil)
}

#Preview("Large", as: .systemLarge) {
    CircleWidget()
} timeline: {
    CircleWidgetEntry(date: Date(), widgetData: previewData)
    CircleWidgetEntry(date: Date(), widgetData: nil)
}

private let previewData = WidgetData(
    circleEmoji: "🌿",
    circleName: "Family",
    promptText: "What made you smile today?",
    memberResponses: [
        MemberResponse(displayName: "Mom", transcriptSnippet: "I saw the most beautiful sunset on my walk this evening...", hasResponded: true),
        MemberResponse(displayName: "Dad", transcriptSnippet: nil, hasResponded: false),
        MemberResponse(displayName: "You", transcriptSnippet: "Had a great lunch with an old friend today and we talked...", hasResponded: true)
    ],
    respondedCount: 2,
    totalMembers: 3,
    updatedAt: Date()
)
