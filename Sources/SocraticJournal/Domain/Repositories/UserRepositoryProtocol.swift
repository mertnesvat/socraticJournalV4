// UserRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Repository for persisting and retrieving user profiles
public protocol UserRepositoryProtocol: Sendable {
    /// Saves a user to the data store
    func saveUser(_ user: User) async throws

    /// Retrieves a user by their ID
    func getUser(id: String) async throws -> User?

    /// Searches for users matching the query string
    func searchUsers(query: String) async throws -> [User]

    /// Returns the currently authenticated user, if available
    func getCurrentUser() async throws -> User?
}
