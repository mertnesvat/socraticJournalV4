// MockAuthService.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Mock authentication service that simulates sign-in with local users
/// Replace with FirebaseAuthService when Firebase is integrated
@MainActor
public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    // MARK: - Mock Users

    public static let mockUsers: [UserProfile] = [
        UserProfile(id: "user-001", displayName: "You", circleIds: ["circle-001"]),
        UserProfile(id: "user-002", displayName: "Sarah", circleIds: ["circle-001"]),
        UserProfile(id: "user-003", displayName: "Mike", circleIds: ["circle-001"]),
    ]

    // MARK: - State

    private var currentProfile: UserProfile?
    private var authContinuation: AsyncStream<UserProfile?>.Continuation?
    public let authStateStream: AsyncStream<UserProfile?>

    private let defaults: UserDefaults
    private static let currentUserKey = "circle_current_user_id"

    // MARK: - Init

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        var continuation: AsyncStream<UserProfile?>.Continuation?
        authStateStream = AsyncStream { cont in
            continuation = cont
        }
        authContinuation = continuation

        // Restore persisted user
        if let savedId = defaults.string(forKey: Self.currentUserKey),
           let profile = Self.mockUsers.first(where: { $0.id == savedId }) {
            currentProfile = profile
        }
    }

    // MARK: - AuthServiceProtocol

    public nonisolated func signIn() async throws -> UserProfile {
        let profile = await MainActor.run {
            let user = Self.mockUsers[0] // Auto-sign-in as "You"
            currentProfile = user
            defaults.set(user.id, forKey: Self.currentUserKey)
            authContinuation?.yield(user)
            return user
        }
        return profile
    }

    public nonisolated func signOut() async throws {
        await MainActor.run {
            currentProfile = nil
            defaults.removeObject(forKey: Self.currentUserKey)
            authContinuation?.yield(nil)
        }
    }

    public nonisolated func currentUser() async -> UserProfile? {
        await MainActor.run {
            currentProfile
        }
    }

    // MARK: - Mock Helpers

    /// Auto-sign-in on app launch if no user is signed in
    public func autoSignInIfNeeded() async {
        if currentProfile == nil {
            _ = try? await signIn()
        } else {
            authContinuation?.yield(currentProfile)
        }
    }
}
