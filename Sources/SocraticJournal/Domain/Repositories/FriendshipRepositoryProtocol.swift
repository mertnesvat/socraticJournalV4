// FriendshipRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Repository for persisting and retrieving friendships
public protocol FriendshipRepositoryProtocol: Sendable {
    /// Saves a friendship to the data store
    func saveFriendship(_ friendship: Friendship) async throws

    /// Retrieves a friendship by its ID
    func getFriendship(id: String) async throws -> Friendship?

    /// Returns all friendships for a given user
    func getFriendships(userId: String) async throws -> [Friendship]

    /// Updates the status of a friendship
    func updateStatus(id: String, status: FriendshipStatus) async throws

    /// Deletes a friendship by its ID
    func deleteFriendship(id: String) async throws
}
