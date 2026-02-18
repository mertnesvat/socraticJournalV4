// SettingsViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// ViewModel for the Settings & Profile screen.
/// Manages user profile, circle list, preferences, and data clearing.
@Observable
@MainActor
public final class SettingsViewModel {
    // MARK: - State

    /// Editable display name for the user
    var displayName: String = ""

    /// The user's circles
    private(set) var circles: [CircleGroup] = []

    /// Voice recording quality preference
    var voiceQuality: VoiceQuality {
        didSet {
            saveVoiceQuality()
        }
    }

    /// Loading indicator
    private(set) var isLoading: Bool = false

    /// Error message for display
    private(set) var error: String?

    /// Controls the "Clear All Data" confirmation alert
    var showClearDataConfirmation: Bool = false

    /// App version string from the main bundle
    let appVersion: String

    /// Current subscription status display text
    private(set) var subscriptionStatusText: String = "Free"

    // MARK: - Dependencies

    private let authState: AuthState
    private let settingsRepository: SettingsRepositoryProtocol
    private let circleRepository: CircleRepositoryProtocol
    private let notificationScheduler: CircleNotificationScheduler?
    private let subscriptionService: SubscriptionServiceProtocol?

    // MARK: - Constants

    private static let voiceQualityKey = "circle_voice_quality"

    // MARK: - Init

    public init(
        authState: AuthState,
        settingsRepository: SettingsRepositoryProtocol,
        circleRepository: CircleRepositoryProtocol,
        notificationScheduler: CircleNotificationScheduler? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil
    ) {
        self.authState = authState
        self.settingsRepository = settingsRepository
        self.circleRepository = circleRepository
        self.notificationScheduler = notificationScheduler
        self.subscriptionService = subscriptionService

        // Load voice quality from UserDefaults
        let storedRaw = UserDefaults.standard.string(forKey: Self.voiceQualityKey) ?? ""
        self.voiceQuality = VoiceQuality(rawValue: storedRaw) ?? .standard

        // App version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        self.appVersion = "\(version) (\(build))"

        // Pre-populate display name from current user
        self.displayName = authState.currentUser?.displayName ?? ""
    }

    // MARK: - Computed Properties

    /// Initials derived from the current user's display name
    var userInitials: String {
        let name = authState.currentUser?.displayName ?? displayName
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    /// Whether the display name has been changed from the current user's name
    var hasNameChanged: Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed != authState.currentUser?.displayName
    }

    // MARK: - Actions

    /// Fetch circles, subscription status, and load preferences
    func loadData() async {
        isLoading = true
        error = nil

        // Load display name from auth state
        displayName = authState.currentUser?.displayName ?? ""

        // Fetch circles
        if let userId = authState.currentUser?.id {
            do {
                circles = try await circleRepository.fetchAll(userId: userId)
            } catch {
                self.error = "Failed to load circles: \(error.localizedDescription)"
            }
        }

        // Fetch subscription status
        if let service = subscriptionService {
            let status = await service.currentStatus()
            subscriptionStatusText = status.displayName
        }

        isLoading = false
    }

    /// Save the updated display name via AuthState/LocalAuthService
    func updateDisplayName() async {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        do {
            // Use the auth service to update the profile
            // AuthState wraps the service, but we need the service's updateProfile
            // We'll sign out and back in approach won't work -- instead create a new profile
            // The AuthState wraps AuthServiceProtocol which has updateProfile
            // But AuthState doesn't expose updateProfile directly, so we call createProfile
            // Actually looking at the code, AuthState only has createProfile and signOut.
            // We need to add updateProfile or use the service directly.
            // For now, the simplest approach: re-create profile with the new name.
            // But that changes the user ID which would break circles.
            // Best approach: just update the current user through the auth service.
            // Since AuthState doesn't expose the service, we'll update via the auth state pattern:
            // Let's just update the local auth service directly through the same pattern.

            // Actually, we can call createProfile which will persist a new user.
            // But that creates a new UUID. Instead, let's use a workaround:
            // Persist the display name change to UserDefaults directly (matching LocalAuthService pattern)

            if let currentUser = authState.currentUser {
                let updatedUser = CircleUser(
                    id: currentUser.id,
                    displayName: trimmed,
                    email: currentUser.email,
                    avatarPath: currentUser.avatarPath,
                    createdAt: currentUser.createdAt
                )
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(updatedUser)
                UserDefaults.standard.set(data, forKey: "circle_current_user")

                // Reload the auth state to pick up the change
                await authState.loadCurrentUser()
            }
        } catch {
            self.error = "Failed to update name: \(error.localizedDescription)"
        }
    }

    /// Leave a circle and update notification schedule
    func leaveCircle(id: UUID) async {
        guard let userId = authState.currentUser?.id else { return }

        do {
            try await circleRepository.removeMember(userId: userId, from: id)
            try await circleRepository.delete(id: id)
            circles.removeAll { $0.id == id }

            // Cancel notifications for the removed circle
            await notificationScheduler?.cancelForCircle(circleId: id)

            // Reschedule remaining circles
            if let scheduler = notificationScheduler {
                await scheduler.rescheduleAll(circles: circles)
            }
        } catch {
            self.error = "Failed to leave circle: \(error.localizedDescription)"
        }
    }

    /// Delete all local data: circles, prompts, voice notes, settings, then sign out
    func clearAllLocalData() async {
        isLoading = true
        error = nil

        do {
            // 1. Clear files from documents directory
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileManager = FileManager.default

            // Delete circles directory
            let circlesDir = documentsDir.appendingPathComponent("circles", isDirectory: true)
            if fileManager.fileExists(atPath: circlesDir.path) {
                try fileManager.removeItem(at: circlesDir)
            }

            // Delete prompts directory
            let promptsDir = documentsDir.appendingPathComponent("prompts", isDirectory: true)
            if fileManager.fileExists(atPath: promptsDir.path) {
                try fileManager.removeItem(at: promptsDir)
            }

            // Delete voice notes directory
            let voiceNotesDir = documentsDir.appendingPathComponent("voice_notes", isDirectory: true)
            if fileManager.fileExists(atPath: voiceNotesDir.path) {
                try fileManager.removeItem(at: voiceNotesDir)
            }

            // Delete audio recordings directory
            let recordingsDir = documentsDir.appendingPathComponent("recordings", isDirectory: true)
            if fileManager.fileExists(atPath: recordingsDir.path) {
                try fileManager.removeItem(at: recordingsDir)
            }

            // Delete LocalContent directory
            let localContentDir = documentsDir.appendingPathComponent("LocalContent", isDirectory: true)
            if fileManager.fileExists(atPath: localContentDir.path) {
                try fileManager.removeItem(at: localContentDir)
            }

            // 2. Clear UserDefaults keys
            try await settingsRepository.clearAllData()

            // Remove voice quality preference
            UserDefaults.standard.removeObject(forKey: Self.voiceQualityKey)

            // Remove onboarding flag
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

            // 3. Cancel all notifications
            await notificationScheduler?.rescheduleAll(circles: [])

            // 4. Sign out
            await authState.signOut()
        } catch {
            self.error = "Failed to clear data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Clear the error message
    func clearError() {
        error = nil
    }

    // MARK: - Private

    private func saveVoiceQuality() {
        UserDefaults.standard.set(voiceQuality.rawValue, forKey: Self.voiceQualityKey)
    }
}
#endif
