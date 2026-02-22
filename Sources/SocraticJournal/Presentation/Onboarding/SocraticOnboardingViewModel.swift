// SocraticOnboardingViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// ViewModel managing the 5-page new onboarding flow state and actions
@Observable
@MainActor
public final class SocraticOnboardingViewModel {
    // MARK: - State

    /// Current page index (0-4 for the 5 onboarding pages)
    public var currentPage: Int = 0

    /// User-entered display name for profile setup
    public var displayName: String = ""

    /// User-entered username for profile setup
    public var username: String = ""

    /// Selected SF Symbol avatar name
    public var selectedAvatar: String = "person.circle.fill"

    /// Number of friends the user has invited during onboarding
    public private(set) var friendsInvited: Int = 0

    /// Today's daily question loaded for the teaser page
    public private(set) var todaysQuestion: DailyQuestion?

    /// Whether onboarding is fully complete (triggers dismissal)
    public private(set) var isComplete: Bool = false

    /// Validation error message for display name field
    public var nameError: String?

    /// Validation error message for username field
    public var usernameError: String?

    /// Whether a profile save operation is in progress
    public private(set) var isSaving: Bool = false

    /// Whether the user tapped "Record Your First Answer" on the last page
    public private(set) var shouldOpenRecording: Bool = false

    // MARK: - Constants

    /// Total number of onboarding pages
    public let totalPages: Int = 5

    /// Available SF Symbol options for avatar selection (matches EditProfileSheet)
    public let avatarOptions: [String] = [
        "person.circle.fill",
        "person.circle",
        "face.smiling",
        "star.circle.fill",
        "heart.circle.fill",
        "bolt.circle.fill",
        "moon.circle.fill",
        "sun.max.circle.fill"
    ]

    // MARK: - Dependencies

    private let settingsRepository: SettingsRepositoryProtocol
    private let userProfileRepository: UserProfileRepositoryProtocol
    private let friendshipRepository: FriendshipRepositoryProtocol
    private let questionRepository: QuestionRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // MARK: - Init

    public init(
        settingsRepository: SettingsRepositoryProtocol,
        userProfileRepository: UserProfileRepositoryProtocol,
        friendshipRepository: FriendshipRepositoryProtocol,
        questionRepository: QuestionRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol = FirebaseAnalyticsService.shared
    ) {
        self.settingsRepository = settingsRepository
        self.userProfileRepository = userProfileRepository
        self.friendshipRepository = friendshipRepository
        self.questionRepository = questionRepository
        self.analyticsService = analyticsService
    }

    // MARK: - Navigation

    /// Advances to the next page after validating the current page
    /// For page 2 (profile setup), validates and saves the profile before advancing
    public func nextPage() async {
        guard currentPage < totalPages - 1 else { return }

        // Page 2 requires validation before advancing
        if currentPage == 2 {
            guard validateProfileFields() else { return }
            await saveProfile()
            if isSaving { return } // Still saving, don't advance yet
        }

        currentPage += 1
    }

    /// Returns to the previous page
    public func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }

    // MARK: - Profile

    /// Validates profile fields and returns whether they pass
    private func validateProfileFields() -> Bool {
        nameError = nil
        usernameError = nil

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        var isValid = true

        if trimmedName.isEmpty {
            nameError = "Display name is required."
            isValid = false
        }

        if trimmedUsername.count < 3 {
            usernameError = "Username must be at least 3 characters."
            isValid = false
        }

        return isValid
    }

    /// Saves the user profile to the repository
    public func saveProfile() async {
        isSaving = true
        defer { isSaving = false }

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        var currentUser = await userProfileRepository.getCurrentUser()
        currentUser.displayName = trimmedName
        currentUser.username = "@\(trimmedUsername)"
        currentUser.avatarImageName = selectedAvatar

        do {
            try await userProfileRepository.updateProfile(currentUser)
        } catch {
            // Profile save failed - log but allow continuing
            print("Failed to save profile during onboarding: \(error)")
        }
    }

    // MARK: - Onboarding Completion

    /// Marks onboarding as complete and persists the setting
    public func completeOnboarding() async {
        do {
            var settings = try await settingsRepository.getSettings()
            settings.hasCompletedOnboarding = true
            try await settingsRepository.saveSettings(settings)
            analyticsService.logEvent(.onboardingCompleted, parameters: nil)
        } catch {
            // Log error but still mark complete so user isn't stuck
            print("Failed to save onboarding completion: \(error)")
        }
        isComplete = true
    }

    /// Marks onboarding complete when user taps "Record Your First Answer"
    public func completeAndOpenRecording() async {
        shouldOpenRecording = true
        await completeOnboarding()
    }

    /// Skips directly to the app, marking onboarding as complete
    public func skipToApp() async {
        analyticsService.logEvent(.onboardingSkipped, parameters: nil)
        await completeOnboarding()
    }

    // MARK: - Friends

    /// Increments the friends invited counter (mock action)
    public func inviteFriend() {
        friendsInvited += 1
    }

    // MARK: - Question Loading

    /// Loads today's question for the teaser page
    public func loadTodaysQuestion() async {
        todaysQuestion = await questionRepository.getTodaysQuestion()
    }
}
