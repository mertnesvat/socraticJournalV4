// MockFriendService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of FriendServiceProtocol using static mock data
@MainActor
final class MockFriendService: FriendServiceProtocol {
    nonisolated init() {}

    nonisolated func getFriends() async throws -> [User] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.friends
    }

    nonisolated func sendFriendRequest(userId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // No-op for mock
    }

    nonisolated func acceptFriendRequest(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // No-op for mock
    }

    nonisolated func removeFriend(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // No-op for mock
    }

    nonisolated func searchUsers(query: String) async throws -> [User] {
        try await Task.sleep(nanoseconds: 300_000_000)
        let lowered = query.lowercased()
        return MockDataProvider.allUsers.filter { user in
            user.displayName.lowercased().contains(lowered) ||
            user.username.lowercased().contains(lowered)
        }
    }

    nonisolated func getIncomingRequests() async throws -> [Friendship] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.incomingRequests
    }

    nonisolated func getSentRequests() async throws -> [Friendship] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return MockDataProvider.sentRequests
    }
}
