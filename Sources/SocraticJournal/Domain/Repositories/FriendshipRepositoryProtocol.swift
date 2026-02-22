// FriendshipRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining friendship and social connection data operations
public protocol FriendshipRepositoryProtocol: Sendable {
    /// Fetches the current user's accepted friends
    func getFriends() async -> [UserProfile]

    /// Sends a friend request to a user
    func addFriend(userId: String) async throws

    /// Removes a friend connection
    func removeFriend(userId: String) async throws

    /// Fetches pending incoming friend requests
    func getPendingRequests() async -> [Friendship]

    /// Accepts a pending friend request
    func acceptRequest(friendshipId: String) async throws

    /// Returns the current user's friend count
    func getFriendCount() async -> Int

    /// Searches for users by query string
    func searchUsers(query: String) async -> [UserProfile]
}
