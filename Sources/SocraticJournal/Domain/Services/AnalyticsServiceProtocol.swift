// AnalyticsServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining analytics tracking capabilities
public protocol AnalyticsServiceProtocol: Sendable {
    /// Log a custom analytics event
    /// - Parameter event: The event to log (contains name and parameters)
    func logEvent(_ event: AnalyticsEvent)

    /// Set a user property for analytics segmentation
    /// - Parameters:
    ///   - name: Property name
    ///   - value: Property value (nil to clear)
    func setUserProperty(_ name: String, value: String?)
}

/// Analytics events tracked in the Circle app
public enum AnalyticsEvent: Sendable {
    // Profile
    case profileCreated
    case profileEdited

    // Circle
    case circleCreated(memberCount: Int)
    case circleMemberAdded
    case circleLeft
    case circleDeleted

    // Prompts
    case promptGenerated(tier: String)
    case promptViewed(circleId: String)
    case promptResponded(circleId: String)
    case promptSkipped(circleId: String)

    // Voice
    case voiceNoteRecorded(duration: TimeInterval)
    case voiceNotePlayed
    case voiceNoteReplayed
    case voiceNotePlayAll(count: Int)

    // Transcript
    case transcriptViewed
    case transcriptExpanded

    // Widget
    case widgetTapped
    case widgetConfigured

    // Onboarding
    case onboardingStepViewed(step: Int)
    case onboardingCompleted
    case onboardingSkipped

    // Notifications
    case notificationPermissionGranted
    case notificationPermissionDenied
    case notificationTapped

    // Subscription events (kept from existing paywall)
    case paywallViewed
    case paywallDismissed
    case paywallProductsLoaded
    case paywallProductsLoadFailed
    case paywallProductSelected
    case paywallPurchaseStarted
    case paywallPurchaseCompleted
    case paywallPurchaseFailed
    case paywallPurchaseCancelled
    case paywallRestoreStarted
    case paywallRestoreCompleted
    case paywallRestoreFailed

    /// The string event name sent to Firebase Analytics
    public var name: String {
        switch self {
        // Profile
        case .profileCreated: return "profile_created"
        case .profileEdited: return "profile_edited"

        // Circle
        case .circleCreated: return "circle_created"
        case .circleMemberAdded: return "circle_member_added"
        case .circleLeft: return "circle_left"
        case .circleDeleted: return "circle_deleted"

        // Prompts
        case .promptGenerated: return "prompt_generated"
        case .promptViewed: return "prompt_viewed"
        case .promptResponded: return "prompt_responded"
        case .promptSkipped: return "prompt_skipped"

        // Voice
        case .voiceNoteRecorded: return "voice_note_recorded"
        case .voiceNotePlayed: return "voice_note_played"
        case .voiceNoteReplayed: return "voice_note_replayed"
        case .voiceNotePlayAll: return "voice_note_play_all"

        // Transcript
        case .transcriptViewed: return "transcript_viewed"
        case .transcriptExpanded: return "transcript_expanded"

        // Widget
        case .widgetTapped: return "widget_tapped"
        case .widgetConfigured: return "widget_configured"

        // Onboarding
        case .onboardingStepViewed: return "onboarding_step_viewed"
        case .onboardingCompleted: return "onboarding_completed"
        case .onboardingSkipped: return "onboarding_skipped"

        // Notifications
        case .notificationPermissionGranted: return "notification_permission_granted"
        case .notificationPermissionDenied: return "notification_permission_denied"
        case .notificationTapped: return "notification_tapped"

        // Subscription
        case .paywallViewed: return "paywall_viewed"
        case .paywallDismissed: return "paywall_dismissed"
        case .paywallProductsLoaded: return "paywall_products_loaded"
        case .paywallProductsLoadFailed: return "paywall_products_load_failed"
        case .paywallProductSelected: return "paywall_product_selected"
        case .paywallPurchaseStarted: return "paywall_purchase_started"
        case .paywallPurchaseCompleted: return "paywall_purchase_completed"
        case .paywallPurchaseFailed: return "paywall_purchase_failed"
        case .paywallPurchaseCancelled: return "paywall_purchase_cancelled"
        case .paywallRestoreStarted: return "paywall_restore_started"
        case .paywallRestoreCompleted: return "paywall_restore_completed"
        case .paywallRestoreFailed: return "paywall_restore_failed"
        }
    }

    /// Associated parameters dictionary for the event
    public var parameters: [String: Any] {
        switch self {
        // Circle
        case .circleCreated(let memberCount):
            return ["member_count": memberCount]

        // Prompts
        case .promptGenerated(let tier):
            return ["tier": tier]
        case .promptViewed(let circleId):
            return ["circle_id": circleId]
        case .promptResponded(let circleId):
            return ["circle_id": circleId]
        case .promptSkipped(let circleId):
            return ["circle_id": circleId]

        // Voice
        case .voiceNoteRecorded(let duration):
            return ["duration_seconds": duration]
        case .voiceNotePlayAll(let count):
            return ["count": count]

        // Onboarding
        case .onboardingStepViewed(let step):
            return ["step": step]

        // All events with no associated parameters
        default:
            return [:]
        }
    }
}

/// User property keys for analytics segmentation
public enum AnalyticsUserProperty: String, Sendable {
    case circleCount = "circle_count"
    case totalVoiceNotesSent = "total_voice_notes_sent"
    case currentStreakDays = "current_streak_days"
}
