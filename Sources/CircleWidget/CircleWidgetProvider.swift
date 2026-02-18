// CircleWidgetProvider.swift
// CircleWidget
// Copyright 2024 StudioNext

import WidgetKit
import Foundation

/// Timeline provider that reads widget data from the App Group shared container.
/// No SwiftData or network calls -- reads a static JSON file only.
struct CircleWidgetProvider: TimelineProvider {

    /// The App Group identifier shared with the main app.
    private static let appGroupIdentifier = "group.com.StudioNext.socraticJournal"
    private static let fileName = "widget-data.json"

    // MARK: - TimelineProvider

    func placeholder(in context: Context) -> CircleWidgetEntry {
        CircleWidgetEntry(date: Date(), widgetData: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (CircleWidgetEntry) -> Void) {
        let data = readWidgetData() ?? .preview
        let entry = CircleWidgetEntry(date: Date(), widgetData: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CircleWidgetEntry>) -> Void) {
        let data = readWidgetData() ?? .empty
        let entry = CircleWidgetEntry(date: Date(), widgetData: data)

        // Refresh every 30 minutes, though the main app also triggers reloads.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // MARK: - Data Reading

    /// Read widget data JSON from the App Group shared container.
    private func readWidgetData() -> WidgetData? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        ) else {
            return nil
        }

        let fileURL = containerURL.appendingPathComponent(Self.fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(WidgetData.self, from: data)
        } catch {
            return nil
        }
    }
}
