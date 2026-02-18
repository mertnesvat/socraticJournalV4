// OnboardingViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI
import UserNotifications

/// ViewModel that drives the 4-screen onboarding flow.
/// Manages page navigation, optional circle creation, notification permission,
/// and persists the onboarding-completed flag in UserDefaults.
@Observable
@MainActor
public final class OnboardingViewModel {
    // MARK: - Page State

    var currentPage: Int = 0

    // MARK: - Circle Creation State (Screen 3)

    var circleName: String = ""
    var circleEmoji: String = "\u{1F4AC}" // speech balloon
    var newMemberName: String = ""
    var memberNames: [String] = []
    var isCreatingCircle: Bool = false
    var circleCreationError: String?

    // MARK: - Dependencies

    private let circleRepository: CircleRepositoryProtocol
    private let authState: AuthState

    // MARK: - Constants

    static let totalPages = 4

    let emojis = [
        "\u{1F4AC}", "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}", "\u{1F3E0}", "\u{2764}\u{FE0F}", "\u{1F3AF}",
        "\u{1F31F}", "\u{1F389}", "\u{1F3C3}", "\u{1F3B5}", "\u{1F4DA}",
        "\u{1F355}", "\u{1F30D}", "\u{1F43E}", "\u{2708}\u{FE0F}", "\u{1F4AA}",
        "\u{1F338}", "\u{1F3AE}", "\u{1F91D}", "\u{1F308}", "\u{2600}\u{FE0F}"
    ]

    // MARK: - Computed Properties

    var isCircleNameValid: Bool {
        circleName.trimmingCharacters(in: .whitespaces).count >= 2
    }

    var hasCircleDetails: Bool {
        isCircleNameValid
    }

    var currentUserId: UUID? {
        authState.currentUser?.id
    }

    // MARK: - Init

    public init(circleRepository: CircleRepositoryProtocol, authState: AuthState) {
        self.circleRepository = circleRepository
        self.authState = authState
    }

    // MARK: - Actions

    func advancePage() {
        guard currentPage < Self.totalPages - 1 else { return }
        currentPage += 1
    }

    func addMember() {
        let name = newMemberName.trimmingCharacters(in: .whitespaces)
        guard name.count >= 2 else { return }
        guard memberNames.count < 4 else { return } // Max 4 additional members (creator + 4 = 5 total)
        memberNames.append(name)
        newMemberName = ""
    }

    func removeMember(at index: Int) {
        guard memberNames.indices.contains(index) else { return }
        memberNames.remove(at: index)
    }

    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    /// Creates a circle if user filled in details on page 3, then marks onboarding complete.
    func completeOnboarding() async {
        if hasCircleDetails {
            await createCircleIfNeeded()
        }

        // Request notification permission on final step
        await requestNotificationPermission()

        // Mark onboarding as completed in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    // MARK: - Private

    private func createCircleIfNeeded() async {
        guard let userId = currentUserId else { return }

        isCreatingCircle = true
        circleCreationError = nil

        do {
            let name = circleName.trimmingCharacters(in: .whitespaces)
            let circle = try await circleRepository.create(
                name: name,
                emoji: circleEmoji,
                creatorId: userId
            )

            // Add simulated members
            for memberName in memberNames {
                let member = CircleMember(
                    userId: UUID(),
                    displayName: memberName,
                    joinedAt: Date(),
                    role: .member,
                    isSimulated: true
                )
                try await circleRepository.addMember(member, to: circle.id)
            }
        } catch {
            circleCreationError = error.localizedDescription
        }

        isCreatingCircle = false
    }
}
#endif
