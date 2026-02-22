// MockUserProfileService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of UserProfileServiceProtocol using static mock data
@MainActor
final class MockUserProfileService: UserProfileServiceProtocol {
    nonisolated init() {}

    nonisolated func getCurrentUser() async throws -> User {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.currentUser
    }

    nonisolated func updateProfile(user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 300_000_000)
        // Return the updated user as-is for mock purposes
        return user
    }

    nonisolated func getUser(id: String) async throws -> User {
        try await Task.sleep(nanoseconds: 300_000_000)
        guard let user = MockDataProvider.allUsers.first(where: { $0.id == id }) else {
            throw MockServiceError.notFound
        }
        return user
    }

    nonisolated func getStreak() async throws -> QuestionStreak {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.currentUserStreak
    }

    nonisolated func getAwards() async throws -> [SpicyTakeAward] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.awards
    }
}
