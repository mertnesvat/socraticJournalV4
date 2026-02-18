// CircleWidget.swift
// Circle
// Copyright 2024 StudioNext

import WidgetKit
import SwiftUI

// MARK: - Shared Widget Data (duplicated from main app to avoid framework dependency)

struct WidgetData: Codable {
    let circleName: String
    let circleEmoji: String
    let promptQuestion: String
    let promptCategory: String
    let responseCount: Int
    let memberCount: Int
    let hasResponded: Bool
    let updatedAt: Date

    static let placeholder = WidgetData(
        circleName: "Family Circle",
        circleEmoji: "👨‍👩‍👧",
        promptQuestion: "What made you smile today?",
        promptCategory: "Reflective",
        responseCount: 2,
        memberCount: 4,
        hasResponded: false,
        updatedAt: Date()
    )
}

// MARK: - Timeline Provider

struct CircleWidgetProvider: TimelineProvider {
    private let suiteName = "group.com.StudioNext.socraticJournal"
    private let widgetDataKey = "circle_widget_data"

    func placeholder(in context: Context) -> CircleWidgetEntry {
        CircleWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (CircleWidgetEntry) -> Void) {
        let entry = CircleWidgetEntry(date: Date(), data: readData() ?? .placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CircleWidgetEntry>) -> Void) {
        let entry = CircleWidgetEntry(date: Date(), data: readData())

        // Refresh at midnight for new daily prompt
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func readData() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data)
        else { return nil }
        return decoded
    }
}

// MARK: - Entry

struct CircleWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData?
}

// MARK: - Small Widget View

struct CircleWidgetSmallView: View {
    let entry: CircleWidgetEntry

    var body: some View {
        if let data = entry.data {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(data.circleEmoji)
                        .font(.title3)
                    Text(data.circleName)
                        .font(.caption.bold())
                        .lineLimit(1)
                }

                Text(data.promptQuestion)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundStyle(.primary)

                Spacer()

                if data.hasResponded {
                    Text("\(data.responseCount)/\(data.memberCount) responded")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Tap to respond")
                        .font(.caption2.bold())
                        .foregroundStyle(.blue)
                }
            }
            .padding(12)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "circle.hexagongrid")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Open Circle\nto get started")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget View

struct CircleWidgetMediumView: View {
    let entry: CircleWidgetEntry

    var body: some View {
        if let data = entry.data {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(data.circleEmoji)
                            .font(.title3)
                        Text(data.circleName)
                            .font(.caption.bold())
                            .lineLimit(1)
                    }

                    Text(data.promptQuestion)
                        .font(.subheadline)
                        .lineLimit(3)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.caption)
                        Text("\(data.responseCount) of \(data.memberCount) responded")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                VStack {
                    Spacer()
                    if !data.hasResponded {
                        VStack(spacing: 4) {
                            Image(systemName: "mic.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)
                            Text("Record")
                                .font(.caption2.bold())
                                .foregroundStyle(.blue)
                        }
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.green)
                            Text("Done")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .padding(14)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "circle.hexagongrid")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Create a circle to see today's prompt here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
        }
    }
}

// MARK: - Widget Definition

struct CirclePromptWidget: Widget {
    let kind = "CirclePromptWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CircleWidgetProvider()) { entry in
            Group {
                if #available(iOSApplicationExtension 17.0, *) {
                    CircleWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    CircleWidgetEntryView(entry: entry)
                        .padding()
                        .background()
                }
            }
        }
        .configurationDisplayName("Today's Prompt")
        .description("See today's question and who has responded in your circle.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CircleWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: CircleWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            CircleWidgetSmallView(entry: entry)
        case .systemMedium:
            CircleWidgetMediumView(entry: entry)
        default:
            CircleWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct CircleWidgetBundle: WidgetBundle {
    var body: some Widget {
        CirclePromptWidget()
    }
}
