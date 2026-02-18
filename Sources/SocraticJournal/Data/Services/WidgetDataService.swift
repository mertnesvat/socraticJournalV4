// WidgetDataService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Writes circle feed data to App Group shared container for the widget to read.
/// This is the bridge between the main app and the widget extension.
public enum WidgetDataService {
    private static let suiteName = "group.com.StudioNext.socraticJournal"
    private static let widgetDataKey = "circle_widget_data"

    /// Data structure shared between app and widget
    public struct WidgetData: Codable {
        public let circleName: String
        public let circleEmoji: String
        public let promptQuestion: String
        public let promptCategory: String
        public let responseCount: Int
        public let memberCount: Int
        public let hasResponded: Bool
        public let updatedAt: Date

        public init(
            circleName: String,
            circleEmoji: String,
            promptQuestion: String,
            promptCategory: String,
            responseCount: Int,
            memberCount: Int,
            hasResponded: Bool
        ) {
            self.circleName = circleName
            self.circleEmoji = circleEmoji
            self.promptQuestion = promptQuestion
            self.promptCategory = promptCategory
            self.responseCount = responseCount
            self.memberCount = memberCount
            self.hasResponded = hasResponded
            self.updatedAt = Date()
        }
    }

    /// Write widget data from the main app
    public static func write(_ data: WidgetData) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: widgetDataKey)
        }
    }

    /// Read widget data (used by widget extension)
    public static func read() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data)
        else { return nil }
        return decoded
    }
}
