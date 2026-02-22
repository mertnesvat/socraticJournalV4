// UserProfileRepositoryProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining user profile data operations
public protocol UserProfileRepositoryProtocol: Sendable {
    /// Fetches the current user's profile
    func getCurrentUser() async -> UserProfile

    /// Updates the current user's profile
    func updateProfile(_ profile: UserProfile) async throws

    /// Fetches a specific user's profile by ID
    func getProfile(userId: String) async -> UserProfile?
}
