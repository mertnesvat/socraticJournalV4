// WidgetDataProvider.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import WidgetKit

// MARK: - Shared Data Models (duplicated in CircleWidget target)

/// Data model shared between the main app and the widget via UserDefaults JSON.
/// This struct is duplicated in the widget target — keep both in sync.
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
/// This struct is duplicated in the widget target — keep both in sync.
struct MemberResponse: Codable, Sendable {
    let displayName: String
    let transcriptSnippet: String?
    let hasResponded: Bool
}

// MARK: - Widget Data Provider

/// Writes circle data to shared UserDefaults so the WidgetKit extension can read it.
/// Uses App Group: group.com.StudioNext.socraticJournal
@MainActor
final class WidgetDataProvider {

    static let shared = WidgetDataProvider()

    private let suiteName = "group.com.StudioNext.socraticJournal"
    private let widgetDataKey = "circleWidgetData"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

    // MARK: - Public API

    /// Serialize the latest circle state to shared UserDefaults and reload widget timelines.
    func updateWidgetData(
        circle: CircleGroup,
        prompt: DailyPrompt?,
        members: [CircleMember],
        voiceNotes: [VoiceNote]
    ) {
        let memberResponses: [MemberResponse] = members.map { member in
            let hasResponded = prompt?.respondedUserIds.contains(member.userId) ?? false
            let matchingNote = voiceNotes.first(where: { $0.userId == member.userId })
            let snippet = truncateToWords(matchingNote?.transcript, wordCount: 15)

            return MemberResponse(
                displayName: member.displayName,
                transcriptSnippet: snippet,
                hasResponded: hasResponded
            )
        }

        let respondedCount = prompt?.respondedUserIds.count ?? 0

        let widgetData = WidgetData(
            circleEmoji: circle.emoji,
            circleName: circle.name,
            promptText: prompt?.promptText ?? "",
            memberResponses: memberResponses,
            respondedCount: respondedCount,
            totalMembers: members.count,
            updatedAt: Date()
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(widgetData)
            sharedDefaults?.set(data, forKey: widgetDataKey)
        } catch {
            // Widget data is non-critical; silently fail
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Remove all widget data from shared UserDefaults.
    func clearWidgetData() {
        sharedDefaults?.removeObject(forKey: widgetDataKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Helpers

    /// Truncate a string to approximately the given number of words.
    private func truncateToWords(_ text: String?, wordCount: Int) -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        let words = text.split(separator: " ")
        if words.count <= wordCount { return text }
        return words.prefix(wordCount).joined(separator: " ") + "..."
    }
}
#endif
