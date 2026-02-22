// FriendServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service for managing friendships and friend discovery
public protocol FriendServiceProtocol: Sendable {
    /// Returns the current user's accepted friends
    func getFriends() async throws -> [User]

    /// Sends a friend request to another user
    func sendFriendRequest(userId: String) async throws

    /// Accepts an incoming friend request
    func acceptFriendRequest(id: String) async throws

    /// Removes a friend connection
    func removeFriend(id: String) async throws

    /// Searches for users by query string (username or display name)
    func searchUsers(query: String) async throws -> [User]

    /// Returns incoming friend requests awaiting acceptance
    func getIncomingRequests() async throws -> [Friendship]

    /// Returns friend requests sent by the current user
    func getSentRequests() async throws -> [Friendship]
}
