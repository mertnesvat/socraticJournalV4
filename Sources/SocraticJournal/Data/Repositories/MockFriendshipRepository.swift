// MockFriendshipRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock implementation of FriendshipRepositoryProtocol
/// Pre-populated with 4 accepted friends and 2 pending requests from mock_users.json
public final class MockFriendshipRepository: FriendshipRepositoryProtocol, @unchecked Sendable {
    private let currentUserId = "user-current"
    private var friendships: [Friendship] = []
    private var allMockUsers: [UserProfile] = []

    public init() {
        allMockUsers = Self.loadMockUsers()
        seedFriendships()
    }

    // MARK: - FriendshipRepositoryProtocol

    public func getFriends() async -> [UserProfile] {
        let acceptedFriendIds = friendships
            .filter { $0.status == .accepted }
            .map { $0.friendId }
        return allMockUsers.filter { acceptedFriendIds.contains($0.id) }
    }

    public func addFriend(userId: String) async throws {
        guard !friendships.contains(where: { $0.friendId == userId }) else {
            return
        }
        let friendship = Friendship(
            userId: currentUserId,
            friendId: userId,
            status: .pending
        )
        friendships.append(friendship)
    }

    public func removeFriend(userId: String) async throws {
        friendships.removeAll { $0.friendId == userId }
    }

    public func getPendingRequests() async -> [Friendship] {
        return friendships.filter { $0.status == .pending }
    }

    public func acceptRequest(friendshipId: String) async throws {
        guard let index = friendships.firstIndex(where: { $0.id == friendshipId }) else {
            return
        }
        friendships[index].status = .accepted
    }

    public func getFriendCount() async -> Int {
        return friendships.filter { $0.status == .accepted }.count
    }

    public func searchUsers(query: String) async -> [UserProfile] {
        guard !query.isEmpty else { return allMockUsers }
        let lowercasedQuery = query.lowercased()
        return allMockUsers.filter { user in
            user.displayName.lowercased().contains(lowercasedQuery) ||
            user.username.lowercased().contains(lowercasedQuery)
        }
    }

    // MARK: - Private Helpers

    private func seedFriendships() {
        // First 4 mock users are accepted friends
        for i in 0..<min(4, allMockUsers.count) {
            let friendship = Friendship(
                id: "friendship-\(i + 1)",
                userId: currentUserId,
                friendId: allMockUsers[i].id,
                status: .accepted,
                createdAt: allMockUsers[i].joinedAt
            )
            friendships.append(friendship)
        }

        // Last 2 mock users are pending requests
        for i in 4..<min(6, allMockUsers.count) {
            let friendship = Friendship(
                id: "friendship-\(i + 1)",
                userId: allMockUsers[i].id,
                friendId: currentUserId,
                status: .pending,
                createdAt: Date()
            )
            friendships.append(friendship)
        }
    }

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
