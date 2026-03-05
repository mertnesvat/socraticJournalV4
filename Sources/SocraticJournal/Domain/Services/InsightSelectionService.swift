// InsightSelectionService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Selects breath insights with pattern-weighted randomization.
///
/// Algorithm:
/// - 70% chance to show a pattern-specific insight (related to the pattern just used)
/// - 30% chance to show a general insight (applicable to all patterns)
/// - If no pattern-specific insights are available, falls back to any random insight
/// - Never shows the same insight twice in a row
public final class InsightSelectionService: Sendable {

    private let insights: [BreathInsight]

    /// Key used to persist last shown insight ID
    private static let lastShownKey = "InsightSelectionService.lastShownInsightId"

    public init(insights: [BreathInsight] = BreathInsight.allInsights) {
        self.insights = insights
    }

    // MARK: - Public API

    /// Select an insight weighted toward the given pattern.
    /// - Parameters:
    ///   - patternId: The ID of the breath pattern just completed
    ///   - lastShownId: The ID of the last shown insight (to avoid repeats)
    /// - Returns: A selected `BreathInsight`, or `nil` if no insights exist
    public func selectInsight(forPatternId patternId: String, lastShownId: String? = nil) -> BreathInsight? {
        guard !insights.isEmpty else { return nil }

        let patternSpecific = insights.filter { $0.relatedPatternIds.contains(patternId) }
        let general = insights.filter { $0.isGeneral }

        let resolvedLastId = lastShownId ?? loadLastShownId()

        // Decide pool: 70% pattern-specific, 30% general
        let usePatternSpecific = !patternSpecific.isEmpty && Double.random(in: 0..<1) < 0.7
        let pool = usePatternSpecific ? patternSpecific : (general.isEmpty ? insights : general)

        // Pick from pool, avoiding last shown
        let filtered = pool.filter { $0.id != resolvedLastId }
        let candidates = filtered.isEmpty ? pool : filtered

        guard let selected = candidates.randomElement() else {
            return insights.first
        }

        saveLastShownId(selected.id)
        return selected
    }

    /// Select the next insight (for "tap for another" rotation).
    /// - Parameters:
    ///   - patternId: The pattern ID for weighting
    ///   - currentId: The currently displayed insight ID
    /// - Returns: A different `BreathInsight`
    public func selectNextInsight(forPatternId patternId: String, currentId: String) -> BreathInsight? {
        return selectInsight(forPatternId: patternId, lastShownId: currentId)
    }

    // MARK: - Persistence

    private func loadLastShownId() -> String? {
        UserDefaults.standard.string(forKey: Self.lastShownKey)
    }

    private func saveLastShownId(_ id: String) {
        UserDefaults.standard.set(id, forKey: Self.lastShownKey)
    }
}
