// FirebaseAnalyticsService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import FirebaseAnalytics

/// Firebase Analytics implementation of AnalyticsServiceProtocol
public final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    /// Shared instance for analytics operations
    public static let shared = FirebaseAnalyticsService()

    private init() {}

    // MARK: - AnalyticsServiceProtocol

    public func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        #if DEBUG
        print("[Analytics] Event: \(event.rawValue), params: \(parameters ?? [:])")
        #endif
    }

    public func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        #if DEBUG
        print("[Analytics] User property: \(name) = \(value ?? "nil")")
        #endif
    }

    // MARK: - Convenience Methods

    /// Log question viewed event
    /// - Parameters:
    ///   - questionId: The question identifier
    ///   - category: The question category
    public func logQuestionViewed(questionId: String, category: String) {
        logEvent(.questionViewed, parameters: [
            AnalyticsParameter.questionId.rawValue: questionId,
            AnalyticsParameter.questionCategory.rawValue: category
        ])
    }

    /// Log question answered event
    /// - Parameters:
    ///   - questionId: The question identifier
    ///   - durationSeconds: Recording duration in seconds
    public func logQuestionAnswered(questionId: String, durationSeconds: Double) {
        logEvent(.questionAnswered, parameters: [
            AnalyticsParameter.questionId.rawValue: questionId,
            AnalyticsParameter.recordingDurationSeconds.rawValue: durationSeconds
        ])
    }

    /// Log recording completed event
    /// - Parameters:
    ///   - questionId: The question identifier
    ///   - durationSeconds: Recording duration in seconds
    ///   - fileSize: Recording file size in bytes
    public func logRecordingCompleted(questionId: String, durationSeconds: Double, fileSize: Int) {
        logEvent(.recordingCompleted, parameters: [
            AnalyticsParameter.questionId.rawValue: questionId,
            AnalyticsParameter.recordingDurationSeconds.rawValue: durationSeconds,
            AnalyticsParameter.recordingFileSize.rawValue: fileSize
        ])
    }

    /// Log friend answer unlocked event
    /// - Parameters:
    ///   - friendId: The friend identifier
    ///   - questionId: The question identifier
    public func logFriendAnswerUnlocked(friendId: String, questionId: String) {
        logEvent(.friendAnswerUnlocked, parameters: [
            AnalyticsParameter.friendId.rawValue: friendId,
            AnalyticsParameter.questionId.rawValue: questionId
        ])
    }

    /// Log friend request sent event
    /// - Parameter friendId: The friend identifier
    public func logFriendRequestSent(friendId: String) {
        logEvent(.friendRequestSent, parameters: [
            AnalyticsParameter.friendId.rawValue: friendId
        ])
    }

    /// Log streak milestone event
    /// - Parameter days: The milestone day count
    public func logStreakMilestone(days: Int) {
        logEvent(.streakMilestone, parameters: [
            AnalyticsParameter.milestoneDays.rawValue: days
        ])
    }

    /// Log onboarding completed event
    public func logOnboardingCompleted() {
        logEvent(.onboardingCompleted, parameters: nil)
    }

    /// Log notification preference change
    /// - Parameter enabled: Whether notifications are enabled
    public func logNotificationPreferenceChanged(enabled: Bool) {
        logEvent(enabled ? .notificationEnabled : .notificationDisabled, parameters: nil)
    }

    /// Log theme change
    /// - Parameter theme: The new theme mode
    public func logThemeChanged(theme: String) {
        logEvent(.themeChanged, parameters: [
            AnalyticsParameter.themeMode.rawValue: theme
        ])
    }

    /// Log share card generated event
    /// - Parameters:
    ///   - questionId: The question identifier
    ///   - style: The share card style
    public func logShareCardGenerated(questionId: String, style: String) {
        logEvent(.shareCardGenerated, parameters: [
            AnalyticsParameter.questionId.rawValue: questionId,
            AnalyticsParameter.shareCardStyle.rawValue: style
        ])
    }

    // MARK: - User Properties

    /// Set current streak as user property
    /// - Parameter days: Current streak in days
    public func setStreakDays(_ days: Int) {
        setUserProperty(AnalyticsParameter.streakDays.rawValue, value: "\(days)")
    }

    /// Set friend count as user property
    /// - Parameter count: Total friend count
    public func setFriendCount(_ count: Int) {
        setUserProperty(AnalyticsParameter.friendCount.rawValue, value: "\(count)")
    }
}
#endif
