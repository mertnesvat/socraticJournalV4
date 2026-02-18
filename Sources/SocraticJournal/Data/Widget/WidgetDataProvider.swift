// WidgetDataProvider.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import WidgetKit

// MARK: - Widget Data Models

/// A single response preview for the widget.
public struct WidgetResponse: Codable, Sendable {
    public let memberName: String
    public let transcriptSnippet: String
    public let timestamp: Date

    public init(memberName: String, transcriptSnippet: String, timestamp: Date) {
        self.memberName = memberName
        self.transcriptSnippet = transcriptSnippet
        self.timestamp = timestamp
    }
}

/// The data structure shared between the main app and the widget extension via App Group.
public struct WidgetData: Codable, Sendable {
    public let circleName: String
    public let circleIcon: String
    public let promptText: String
    public let responses: [WidgetResponse]
    public let updatedAt: Date

    public init(
        circleName: String,
        circleIcon: String,
        promptText: String,
        responses: [WidgetResponse],
        updatedAt: Date = Date()
    ) {
        self.circleName = circleName
        self.circleIcon = circleIcon
        self.promptText = promptText
        self.responses = responses
        self.updatedAt = updatedAt
    }

    /// Empty placeholder data when no circles exist.
    public static let empty = WidgetData(
        circleName: "Circle",
        circleIcon: "heart",
        promptText: "Create a circle to get started",
        responses: [],
        updatedAt: Date()
    )
}

// MARK: - Widget Data Provider

/// Writes widget data as JSON to the App Group shared container.
/// Called by the main app whenever feed state changes (new response saved, feed loaded, etc.).
public final class WidgetDataProvider: Sendable {
    public static let shared = WidgetDataProvider()

    /// The App Group identifier shared between the main app and widget extension.
    public static let appGroupIdentifier = "group.com.StudioNext.socraticJournal"

    /// The filename for widget data in the shared container.
    private static let fileName = "widget-data.json"

    private init() {}

    // MARK: - Write

    /// Write widget data to the App Group container and reload widget timelines.
    /// Call this after saving a new response or loading the feed.
    @MainActor
    public func writeWidgetData(_ data: WidgetData) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        ) else {
            return
        }

        let fileURL = containerURL.appendingPathComponent(Self.fileName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL, options: .atomic)

            // Notify WidgetKit to reload timelines
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Widget data is non-critical; log but do not throw.
            #if DEBUG
            print("[WidgetDataProvider] Failed to write widget data: \(error)")
            #endif
        }
    }

    /// Build and write widget data from the current feed state.
    /// Extracts relevant information from SwiftData entities.
    @MainActor
    public func updateWidgetData(
        circle: Circle?,
        prompt: Prompt?,
        responses: [VoiceResponse],
        members: [CircleMember],
        transcripts: [UUID: String]
    ) {
        guard let circle = circle else {
            writeWidgetData(.empty)
            return
        }

        let widgetResponses: [WidgetResponse] = responses.compactMap { response in
            guard let member = members.first(where: { $0.id == response.memberId }) else {
                return nil
            }

            let transcript = transcripts[response.voiceNoteId] ?? ""
            let snippet = Self.snippetFromTranscript(transcript)

            return WidgetResponse(
                memberName: member.displayName,
                transcriptSnippet: snippet,
                timestamp: response.createdAt
            )
        }
        // Sort by most recent first, take top 3
        .sorted { $0.timestamp > $1.timestamp }
        .prefix(3)
        .map { $0 }

        let data = WidgetData(
            circleName: circle.name,
            circleIcon: circle.emojiIcon,
            promptText: prompt?.text ?? "No prompt today",
            responses: widgetResponses
        )

        writeWidgetData(data)
    }

    // MARK: - Read (used by widget extension)

    /// Read widget data from the App Group container.
    /// Returns nil if no data exists or decoding fails.
    public static func readWidgetData() -> WidgetData? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }

        let fileURL = containerURL.appendingPathComponent(fileName)

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

    // MARK: - Helpers

    /// Extract first ~10 words from a transcript string.
    private static func snippetFromTranscript(_ transcript: String) -> String {
        guard !transcript.isEmpty else { return "" }

        let words = transcript.split(separator: " ")
        let snippetWords = words.prefix(10)
        var snippet = snippetWords.joined(separator: " ")

        if words.count > 10 {
            snippet += "..."
        }

        return snippet
    }
}
#endif
