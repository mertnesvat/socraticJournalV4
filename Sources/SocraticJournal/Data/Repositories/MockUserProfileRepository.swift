// MockUserProfileRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of UserProfileRepositoryProtocol
/// Returns an editable current user profile with mock friend profiles
public final class MockUserProfileRepository: UserProfileRepositoryProtocol, @unchecked Sendable {
    private var currentUser: UserProfile
    private var mockUsers: [String: UserProfile] = [:]

    public init() {
        self.currentUser = UserProfile(
            id: "user-current",
            displayName: "Alex",
            username: "@alex_s",
            avatarImageName: "person.crop.circle.fill",
            streakCount: 0,
            joinedAt: Date(),
            friendCount: 4
        )

        let users = Self.loadMockUsers()
        for user in users {
            mockUsers[user.id] = user
        }
    }

    // MARK: - UserProfileRepositoryProtocol

    public func getCurrentUser() async -> UserProfile {
        return currentUser
    }

    public func updateProfile(_ profile: UserProfile) async throws {
        if profile.id == currentUser.id {
            currentUser = profile
        } else {
            mockUsers[profile.id] = profile
        }
    }

    public func getProfile(userId: String) async -> UserProfile? {
        if userId == currentUser.id {
            return currentUser
        }
        return mockUsers[userId]
    }

    // MARK: - Private Helpers

    private static func loadMockUsers() -> [UserProfile] {
        guard let url = Bundle.main.url(forResource: "mock_users", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([UserProfile].self, from: data)
        } catch {
            return []
        }
    }
}
