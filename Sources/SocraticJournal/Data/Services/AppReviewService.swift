// AppReviewService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import StoreKit

/// Service for managing App Store review prompts
/// Uses intelligent triggers to request reviews at optimal moments
public final class AppReviewService: @unchecked Sendable {
    /// Shared instance
    public static let shared = AppReviewService()

    // MARK: - Constants

    /// Minimum completed sessions before showing review prompt
    private static let minimumSessionsForReview = 3

    /// Minimum days between review prompts
    private static let daysBetweenPrompts = 30

    /// Minimum clarity score to trigger review (out of 100)
    private static let minimumScoreForReview = 60

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let completedSessionCount = "appReview_completedSessionCount"
        static let lastReviewPromptDate = "appReview_lastPromptDate"
        static let hasEverReviewed = "appReview_hasEverReviewed"
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Init

    public init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
    }

    // MARK: - Session Tracking

    /// Increment the completed session count
    public func incrementSessionCount() {
        let currentCount = completedSessionCount
        userDefaults.set(currentCount + 1, forKey: Keys.completedSessionCount)
    }

    /// Get the current completed session count
    public var completedSessionCount: Int {
        userDefaults.integer(forKey: Keys.completedSessionCount)
    }

    /// Last date when review prompt was shown
    private var lastReviewPromptDate: Date? {
        get {
            userDefaults.object(forKey: Keys.lastReviewPromptDate) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastReviewPromptDate)
        }
    }

    /// Whether user has ever completed a review
    private var hasEverReviewed: Bool {
        get {
            userDefaults.bool(forKey: Keys.hasEverReviewed)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.hasEverReviewed)
        }
    }

    // MARK: - Review Eligibility

    /// Check if the user is eligible for a review prompt
    /// - Parameter clarityScore: The clarity score from the current session (optional)
    /// - Returns: Whether to show the review prompt
    public func shouldRequestReview(clarityScore: Int? = nil) -> Bool {
        // Check minimum session count
        guard completedSessionCount >= Self.minimumSessionsForReview else {
            return false
        }

        // Check if enough time has passed since last prompt
        if let lastDate = lastReviewPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents(
                [.day],
                from: lastDate,
                to: Date()
            ).day ?? 0

            guard daysSinceLastPrompt >= Self.daysBetweenPrompts else {
                return false
            }
        }

        // If clarity score provided, check minimum threshold
        if let score = clarityScore {
            guard score >= Self.minimumScoreForReview else {
                return false
            }
        }

        return true
    }

    // MARK: - Request Review

    /// Request an App Store review if eligible
    /// Call this after a positive user action (e.g., session completion with good score)
    /// - Parameter clarityScore: Optional clarity score to factor into eligibility
    @MainActor
    public func requestReviewIfAppropriate(clarityScore: Int? = nil) {
        guard shouldRequestReview(clarityScore: clarityScore) else {
            return
        }

        // Update last prompt date
        lastReviewPromptDate = Date()

        // Request the review
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    /// Force request a review (for testing or manual triggers)
    /// Does not check eligibility criteria
    @MainActor
    public func forceRequestReview() {
        lastReviewPromptDate = Date()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    // MARK: - Reset (for testing)

    /// Reset all review tracking data
    public func reset() {
        userDefaults.removeObject(forKey: Keys.completedSessionCount)
        userDefaults.removeObject(forKey: Keys.lastReviewPromptDate)
        userDefaults.removeObject(forKey: Keys.hasEverReviewed)
    }
}
#endif
