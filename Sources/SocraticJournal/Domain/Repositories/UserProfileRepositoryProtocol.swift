// UserProfileRepositoryProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining user profile data operations
public protocol UserProfileRepositoryProtocol: Sendable {
    /// Fetch a user profile by ID
    func getProfile(id: String) async throws -> UserProfile?

    /// Create or update a user profile
    func saveProfile(_ profile: UserProfile) async throws

    /// Delete a user profile
    func deleteProfile(id: String) async throws

    /// Fetch multiple profiles by IDs (for circle member display)
    func getProfiles(ids: [String]) async throws -> [UserProfile]
}
