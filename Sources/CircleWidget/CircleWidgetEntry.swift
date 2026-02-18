// CircleWidgetEntry.swift
// CircleWidget
// Copyright 2024 StudioNext

import WidgetKit
import Foundation

/// The data model for a single widget timeline entry.
struct CircleWidgetEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData
}

// MARK: - Widget Data Models (mirrored from main app for widget target)

/// A single response preview for the widget.
struct WidgetResponse: Codable {
    let memberName: String
    let transcriptSnippet: String
    let timestamp: Date
}

/// The data structure shared between the main app and the widget extension via App Group.
struct WidgetData: Codable {
    let circleName: String
    let circleIcon: String
    let promptText: String
    let responses: [WidgetResponse]
    let updatedAt: Date

    /// Empty placeholder data when no data is available.
    static let empty = WidgetData(
        circleName: "Circle",
        circleIcon: "heart",
        promptText: "Create a circle to get started",
        responses: [],
        updatedAt: Date()
    )

    /// Preview data for widget gallery.
    static let preview = WidgetData(
        circleName: "Family",
        circleIcon: "house.fill",
        promptText: "What made you smile today?",
        responses: [
            WidgetResponse(
                memberName: "Mom",
                transcriptSnippet: "I saw the most beautiful sunset on my walk today...",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            WidgetResponse(
                memberName: "Dad",
                transcriptSnippet: "Had a great lunch with an old friend downtown...",
                timestamp: Date().addingTimeInterval(-7200)
            ),
            WidgetResponse(
                memberName: "Sarah",
                transcriptSnippet: "My project at work finally came together and the team was...",
                timestamp: Date().addingTimeInterval(-10800)
            )
        ],
        updatedAt: Date()
    )
}
