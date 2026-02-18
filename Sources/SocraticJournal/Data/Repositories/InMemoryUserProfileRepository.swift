// InMemoryUserProfileRepository.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// In-memory user profile repository with mock data
/// Replace with FirestoreUserProfileRepository when Firebase is integrated
public final class InMemoryUserProfileRepository: UserProfileRepositoryProtocol, @unchecked Sendable {
    private var profiles: [String: UserProfile]

    public init() {
        // Pre-seed with mock users matching MockAuthService
        var initial: [String: UserProfile] = [:]
        for user in MockAuthService.mockUsers {
            initial[user.id] = user
        }
        self.profiles = initial
    }

    public func getProfile(id: String) async throws -> UserProfile? {
        profiles[id]
    }

    public func saveProfile(_ profile: UserProfile) async throws {
        profiles[profile.id] = profile
    }

    public func deleteProfile(id: String) async throws {
        profiles.removeValue(forKey: id)
    }

    public func getProfiles(ids: [String]) async throws -> [UserProfile] {
        ids.compactMap { profiles[$0] }
    }
}
