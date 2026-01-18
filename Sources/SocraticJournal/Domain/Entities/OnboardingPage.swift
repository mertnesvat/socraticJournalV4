// OnboardingPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents an onboarding screen in the app
public enum OnboardingPage: Int, CaseIterable, Sendable, Identifiable {
    case welcome = 0
    case journaling = 1
    case reflection = 2
    case getStarted = 3

    public var id: Int { rawValue }

    /// Title displayed on the onboarding page
    public var title: String {
        switch self {
        case .welcome:
            return "Welcome to Socratic Journal"
        case .journaling:
            return "Thoughtful Journaling"
        case .reflection:
            return "Deep Reflection"
        case .getStarted:
            return "Begin Your Journey"
        }
    }

    /// Description displayed on the onboarding page
    public var description: String {
        switch self {
        case .welcome:
            return "A space for self-discovery through the art of questioning."
        case .journaling:
            return "Express your thoughts freely and explore your inner world through guided prompts."
        case .reflection:
            return "Gain insights about yourself with Socratic questioning techniques."
        case .getStarted:
            return "Start your journey toward greater self-understanding today."
        }
    }

    /// SF Symbol name for the page illustration
    public var systemImageName: String {
        switch self {
        case .welcome:
            return "book.pages"
        case .journaling:
            return "pencil.and.outline"
        case .reflection:
            return "brain.head.profile"
        case .getStarted:
            return "arrow.right.circle.fill"
        }
    }

    /// Whether this is the final onboarding page
    public var isFinalPage: Bool {
        self == .getStarted
    }

    /// The next page in the onboarding flow, if any
    public var nextPage: OnboardingPage? {
        OnboardingPage(rawValue: rawValue + 1)
    }

    /// The previous page in the onboarding flow, if any
    public var previousPage: OnboardingPage? {
        rawValue > 0 ? OnboardingPage(rawValue: rawValue - 1) : nil
    }
}
