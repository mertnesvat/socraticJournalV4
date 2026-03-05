// OnboardingAssessmentData.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// How the user typically breathes
public enum BreathingStyle: String, CaseIterable, Sendable {
    case nose
    case mouth
    case unsure
}

/// The user's primary breathing goal
public enum BreathingGoal: String, CaseIterable, Sendable {
    case stress
    case sleep
    case wellness
    case focus
}

/// The user's experience level with breathwork
public enum ExperienceLevel: String, CaseIterable, Sendable {
    case regular
    case occasional
    case beginner
}

/// Collects answers from the onboarding quick assessment
public struct OnboardingAssessment {
    public var breathingStyle: BreathingStyle?
    public var mainGoal: BreathingGoal?
    public var experience: ExperienceLevel?

    public var isComplete: Bool {
        breathingStyle != nil && mainGoal != nil && experience != nil
    }

    /// Returns the recommended BreathPattern based on assessment answers
    public var recommendedPattern: BreathPattern {
        // Beginners always get Coherent regardless of goal
        if experience == .beginner {
            return .coherent
        }

        switch mainGoal {
        case .stress:
            return .box
        case .sleep:
            return .fourSevenEight
        case .wellness:
            return .resonance
        case .focus:
            return .box
        case .none:
            return .coherent
        }
    }

    /// Recommended session duration based on experience
    public var recommendedMinutes: Int {
        switch experience {
        case .regular:
            return 10
        default:
            return 5
        }
    }

    /// Human-readable goal label
    public var goalLabel: String {
        switch mainGoal {
        case .stress: return "Less stress"
        case .sleep: return "Better sleep"
        case .wellness: return "General wellness"
        case .focus: return "Focus & performance"
        case .none: return "wellness"
        }
    }

    /// Default assessment used when user skips
    public static let defaults = OnboardingAssessment(
        breathingStyle: .nose,
        mainGoal: .wellness,
        experience: .beginner
    )
}
#endif
