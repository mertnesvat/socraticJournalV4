// LocalPromptService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData
import SwiftUI

/// Local prompt service backed by a bundled JSON file and SwiftData persistence.
/// Selects one deterministic prompt per circle per day, avoiding repeats within 90 days,
/// alternating categories between consecutive days, and applying intelligent depth
/// progression based on circle age, energy alternation, dormancy re-engagement,
/// and user feedback weighting.
@Observable
@MainActor
public final class LocalPromptService: PromptServiceProtocol {
    // MARK: - Types

    /// Lightweight Codable struct matching the bundled prompts.json format.
    private struct PromptData: Codable {
        let id: String
        let text: String
        let category: String
        let depth: Int
    }

    private struct PromptFile: Codable {
        let prompts: [PromptData]
    }

    // MARK: - Constants

    /// Number of days before a prompt can be reused for the same circle.
    private static let repeatWindowDays = 90

    /// Number of consecutive days without responses that triggers dormancy mode.
    private static let dormancyThresholdDays = 3

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    /// Cached prompts loaded from the bundled JSON file.
    private var promptPool: [PromptData] = []

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.promptPool = Self.loadPromptPool()
    }

    // MARK: - PromptServiceProtocol

    public func getTodaysPrompt(for circleId: UUID) async throws -> Prompt {
        let today = Calendar.current.startOfDay(for: Date())

        // Check if a prompt has already been assigned for today
        if let existing = try fetchTodaysAssignedPrompt(circleId: circleId, date: today) {
            return existing
        }

        // Select a new prompt for today
        let selectedData = try selectPrompt(for: circleId, on: today)

        // Create and persist the assigned prompt
        let prompt = Prompt(
            id: UUID(uuidString: selectedData.id) ?? UUID(),
            text: selectedData.text,
            category: PromptCategory(rawValue: selectedData.category) ?? .dailyMoments,
            depth: selectedData.depth,
            dateAssigned: today,
            circleId: circleId,
            isSeen: false
        )

        modelContext.insert(prompt)
        try modelContext.save()

        return prompt
    }

    public func getPromptHistory(for circleId: UUID) async throws -> [Prompt] {
        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId && prompt.dateAssigned != nil
            },
            sortBy: [SortDescriptor(\.dateAssigned, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func markPromptSeen(id: UUID) async throws {
        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.id == id
            }
        )
        guard let prompt = try modelContext.fetch(descriptor).first else { return }
        prompt.isSeen = true
        try modelContext.save()
    }

    // MARK: - Feedback

    /// Submit feedback for a prompt. Creates or updates an existing feedback entry.
    public func submitFeedback(promptId: UUID, circleId: UUID, rating: PromptRating, category: PromptCategory) throws {
        // Check for existing feedback
        let descriptor = FetchDescriptor<PromptFeedback>(
            predicate: #Predicate<PromptFeedback> { feedback in
                feedback.promptId == promptId && feedback.circleId == circleId
            }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            existing.rating = rating
        } else {
            let feedback = PromptFeedback(
                promptId: promptId,
                circleId: circleId,
                rating: rating,
                category: category
            )
            modelContext.insert(feedback)
        }
        try modelContext.save()
    }

    /// Get existing feedback for a prompt in a circle.
    public func getFeedback(promptId: UUID, circleId: UUID) throws -> PromptFeedback? {
        let descriptor = FetchDescriptor<PromptFeedback>(
            predicate: #Predicate<PromptFeedback> { feedback in
                feedback.promptId == promptId && feedback.circleId == circleId
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Streak Computation

    /// Compute the streak data for a given circle by counting consecutive days
    /// (backwards from today) that have at least one VoiceResponse.
    public func computeStreak(for circleId: UUID) throws -> (current: Int, longest: Int, lastActiveDate: Date?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Fetch all voice responses for this circle, sorted by creation date descending
        let descriptor = FetchDescriptor<VoiceResponse>(
            predicate: #Predicate<VoiceResponse> { response in
                response.circleId == circleId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let allResponses = try modelContext.fetch(descriptor)

        guard !allResponses.isEmpty else {
            return (current: 0, longest: 0, lastActiveDate: nil)
        }

        // Build a set of unique active days
        var activeDays: Set<Date> = []
        for response in allResponses {
            let day = calendar.startOfDay(for: response.createdAt)
            activeDays.insert(day)
        }

        let lastActive = activeDays.max()

        // Count current streak: consecutive days backwards from today (or yesterday)
        var currentStreak = 0
        var checkDate = today

        // If today has no activity, start from yesterday
        if !activeDays.contains(today) {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if activeDays.contains(yesterday) {
                checkDate = yesterday
            } else {
                // No activity today or yesterday, current streak is 0
                // Still compute longest streak
                let longest = computeLongestStreak(activeDays: activeDays, calendar: calendar)
                return (current: 0, longest: longest, lastActiveDate: lastActive)
            }
        }

        while activeDays.contains(checkDate) {
            currentStreak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        let longest = computeLongestStreak(activeDays: activeDays, calendar: calendar)

        return (current: currentStreak, longest: max(longest, currentStreak), lastActiveDate: lastActive)
    }

    // MARK: - Private Helpers

    /// Compute the longest streak from a set of active days.
    private func computeLongestStreak(activeDays: Set<Date>, calendar: Calendar) -> Int {
        guard !activeDays.isEmpty else { return 0 }

        let sortedDays = activeDays.sorted()
        var longest = 1
        var current = 1

        for i in 1..<sortedDays.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: sortedDays[i - 1])!
            if calendar.isDate(sortedDays[i], inSameDayAs: expected) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }

    /// Load the prompt pool from the bundled prompts.json resource.
    private static func loadPromptPool() -> [PromptData] {
        guard let url = Bundle.main.url(forResource: "prompts", withExtension: "json") else {
            assertionFailure("prompts.json not found in bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let file = try JSONDecoder().decode(PromptFile.self, from: data)
            return file.prompts
        } catch {
            assertionFailure("Failed to decode prompts.json: \(error)")
            return []
        }
    }

    /// Fetch the prompt already assigned to this circle for the given date.
    private func fetchTodaysAssignedPrompt(circleId: UUID, date: Date) throws -> Prompt? {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date

        let descriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId
                    && prompt.dateAssigned != nil
                    && prompt.dateAssigned! >= date
                    && prompt.dateAssigned! < tomorrow
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    /// Select a prompt using intelligent depth progression, energy alternation,
    /// dormancy detection, category rotation, and feedback weighting.
    private func selectPrompt(for circleId: UUID, on date: Date) throws -> PromptData {
        guard !promptPool.isEmpty else {
            throw PromptServiceError.noPromptsAvailable
        }

        let calendar = Calendar.current

        // --- 1. Get circle age for depth progression ---
        let maxAllowedDepth = try computeMaxDepth(for: circleId, on: date)

        // --- 2. Check dormancy ---
        let isDormant = try checkDormancy(for: circleId, on: date)

        // --- 3. Get yesterday's prompt for energy alternation and category rotation ---
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let yesterdayPrompt = try fetchTodaysAssignedPrompt(circleId: circleId, date: yesterday)
        let yesterdayCategory = yesterdayPrompt?.categoryRaw
        let yesterdayDepth = yesterdayPrompt?.depth ?? 0

        // --- 4. Determine depth range ---
        let depthRange: ClosedRange<Int>
        if isDormant {
            // Dormancy re-engagement: only light prompts
            depthRange = 1...1
        } else if yesterdayDepth >= 4 {
            // Energy alternation: if yesterday was deep, go light today
            depthRange = 1...2
        } else if yesterdayDepth <= 1 {
            // If yesterday was light, allow going up to max allowed depth
            depthRange = 1...maxAllowedDepth
        } else {
            // Normal progression: allow up to max allowed
            depthRange = 1...maxAllowedDepth
        }

        // --- 5. Get recently used prompt IDs ---
        let cutoff = calendar.date(byAdding: .day, value: -Self.repeatWindowDays, to: date) ?? date
        let recentDescriptor = FetchDescriptor<Prompt>(
            predicate: #Predicate<Prompt> { prompt in
                prompt.circleId == circleId
                    && prompt.dateAssigned != nil
                    && prompt.dateAssigned! >= cutoff
            }
        )
        let recentPrompts = try modelContext.fetch(recentDescriptor)
        let recentIds = Set(recentPrompts.map { $0.id.uuidString.lowercased() })

        // --- 6. Get feedback-based category weights ---
        let categoryWeights = try computeCategoryWeights(for: circleId)

        // --- 7. Apply day-of-week weighting ---
        let dayOfWeek = calendar.component(.weekday, from: date)
        let dayWeight = dayOfWeekDepthWeight(dayOfWeek)

        // --- 8. Filter candidates ---
        // Primary filter: not recently used, different category than yesterday, within depth range
        var candidates = promptPool.filter { data in
            !recentIds.contains(data.id.lowercased())
                && data.category != yesterdayCategory
                && depthRange.contains(data.depth)
        }

        // Relax category constraint if needed
        if candidates.isEmpty {
            candidates = promptPool.filter { data in
                !recentIds.contains(data.id.lowercased())
                    && depthRange.contains(data.depth)
            }
        }

        // Relax depth constraint if needed
        if candidates.isEmpty {
            candidates = promptPool.filter { data in
                !recentIds.contains(data.id.lowercased())
                    && data.category != yesterdayCategory
            }
        }

        // Full relaxation if still empty
        if candidates.isEmpty {
            candidates = promptPool.filter { data in
                !recentIds.contains(data.id.lowercased())
            }
        }

        // Use full pool as final fallback
        if candidates.isEmpty {
            candidates = promptPool
        }

        // --- 9. Weighted selection using category feedback and day-of-week depth preference ---
        let seed = Self.deterministicSeed(date: date, circleId: circleId)
        let selected = weightedSelect(
            candidates: candidates,
            categoryWeights: categoryWeights,
            dayDepthWeight: dayWeight,
            targetDepthRange: depthRange,
            seed: seed
        )

        return selected
    }

    /// Compute the maximum allowed depth based on the circle's age.
    private func computeMaxDepth(for circleId: UUID, on date: Date) throws -> Int {
        let calendar = Calendar.current

        // Fetch the circle to get its creation date
        let circleDescriptor = FetchDescriptor<Circle>(
            predicate: #Predicate<Circle> { circle in
                circle.id == circleId
            }
        )
        let circle = try modelContext.fetch(circleDescriptor).first
        let createdAt = circle?.createdAt ?? date

        let ageInDays = calendar.dateComponents([.day], from: calendar.startOfDay(for: createdAt), to: calendar.startOfDay(for: date)).day ?? 0

        switch ageInDays {
        case 0...14:
            return 2   // Week 1-2: light, safe, fun
        case 15...28:
            return 3   // Week 3-4: introduce moderate vulnerability
        case 29...56:
            return 4   // Week 5-8: deeper reflection
        default:
            return 5   // Week 9+: full range
        }
    }

    /// Check if the circle is dormant (3+ consecutive days with no VoiceResponse).
    private func checkDormancy(for circleId: UUID, on date: Date) throws -> Bool {
        let calendar = Calendar.current

        for dayOffset in 1...Self.dormancyThresholdDays {
            guard let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: date) else {
                return false
            }
            let startOfDay = calendar.startOfDay(for: checkDate)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                return false
            }

            let descriptor = FetchDescriptor<VoiceResponse>(
                predicate: #Predicate<VoiceResponse> { response in
                    response.circleId == circleId
                        && response.createdAt >= startOfDay
                        && response.createdAt < endOfDay
                }
            )
            let count = try modelContext.fetchCount(descriptor)
            if count > 0 {
                return false // Found activity within the window, not dormant
            }
        }

        return true
    }

    /// Compute category weights based on feedback history.
    /// Base weight 1.0, -0.1 per thumbs-down, +0.05 per thumbs-up, min 0.2
    private func computeCategoryWeights(for circleId: UUID) throws -> [String: Double] {
        var weights: [String: Double] = [:]

        // Initialize all categories with base weight
        for cat in PromptCategory.allCases {
            weights[cat.rawValue] = 1.0
        }

        let descriptor = FetchDescriptor<PromptFeedback>(
            predicate: #Predicate<PromptFeedback> { feedback in
                feedback.circleId == circleId
            }
        )
        let allFeedback = try modelContext.fetch(descriptor)

        for feedback in allFeedback {
            let key = feedback.categoryRaw
            let current = weights[key] ?? 1.0
            if feedback.rating == .thumbsDown {
                weights[key] = max(0.2, current - 0.1)
            } else {
                weights[key] = current + 0.05
            }
        }

        return weights
    }

    /// Return a depth weighting factor based on day of week.
    /// Lighter on Monday (2) and Friday (6), deeper mid-week.
    private func dayOfWeekDepthWeight(_ weekday: Int) -> Double {
        // Sunday = 1, Monday = 2, ..., Saturday = 7
        switch weekday {
        case 2, 6: // Monday, Friday -- lighter
            return 0.6
        case 3, 5: // Tuesday, Thursday -- moderate
            return 0.9
        case 4:     // Wednesday -- deepest
            return 1.0
        default:    // Weekend -- moderate-light
            return 0.7
        }
    }

    /// Weighted selection from candidates using category feedback weights
    /// and day-of-week depth preference.
    private func weightedSelect(
        candidates: [PromptData],
        categoryWeights: [String: Double],
        dayDepthWeight: Double,
        targetDepthRange: ClosedRange<Int>,
        seed: Int
    ) -> PromptData {
        guard candidates.count > 1 else {
            return candidates.first ?? promptPool[0]
        }

        // Calculate a combined weight for each candidate
        let weights: [Double] = candidates.map { candidate in
            let categoryWeight = categoryWeights[candidate.category] ?? 1.0

            // Prefer depths closer to the middle of the target range, weighted by day factor
            let midDepth = Double(targetDepthRange.lowerBound + targetDepthRange.upperBound) / 2.0
            let targetDepth = midDepth * dayDepthWeight + Double(targetDepthRange.lowerBound) * (1.0 - dayDepthWeight)
            let depthDistance = abs(Double(candidate.depth) - targetDepth)
            let depthWeight = max(0.3, 1.0 - (depthDistance * 0.2))

            return categoryWeight * depthWeight
        }

        // Use deterministic weighted selection
        let totalWeight = weights.reduce(0, +)
        let normalizedSeed = Double(seed % 10000) / 10000.0
        var cumulativeWeight = 0.0
        let target = normalizedSeed * totalWeight

        for (index, weight) in weights.enumerated() {
            cumulativeWeight += weight
            if cumulativeWeight >= target {
                return candidates[index]
            }
        }

        // Fallback to last candidate
        return candidates[candidates.count - 1]
    }

    /// Generate a deterministic integer seed from a date and circle ID.
    /// This ensures the same prompt is selected for the same circle on the same day,
    /// even if the app is restarted.
    private static func deterministicSeed(date: Date, circleId: UUID) -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        // Combine date components with circle ID hash for uniqueness
        let dateValue = year * 10000 + month * 100 + day
        let circleHash = abs(circleId.uuidString.hashValue)
        return abs(dateValue &+ circleHash)
    }
}

// MARK: - Prompt Service Errors

public enum PromptServiceError: LocalizedError {
    case noPromptsAvailable
    case promptNotFound

    public var errorDescription: String? {
        switch self {
        case .noPromptsAvailable:
            return "No prompts are available. Please try again later."
        case .promptNotFound:
            return "Prompt not found."
        }
    }
}
#endif
