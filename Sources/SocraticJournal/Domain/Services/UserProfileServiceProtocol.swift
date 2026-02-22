// UserProfileServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Service for managing user profiles, streaks, and awards
public protocol UserProfileServiceProtocol: Sendable {
    /// Returns the currently authenticated user
    func getCurrentUser() async throws -> User

    /// Updates the current user's profile and returns the updated user
    func updateProfile(user: User) async throws -> User

    /// Returns a user by their ID
    func getUser(id: String) async throws -> User

    /// Returns the current user's question streak
    func getStreak() async throws -> QuestionStreak

    /// Returns the current user's spicy take awards
    func getAwards() async throws -> [SpicyTakeAward]
}
