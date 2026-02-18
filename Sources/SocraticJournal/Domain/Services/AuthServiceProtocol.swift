// AuthServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining authentication operations
/// Abstract enough for any auth provider (Firebase, mock, etc.)
public protocol AuthServiceProtocol: Sendable {
    /// Sign in (provider-specific implementation)
    func signIn() async throws -> UserProfile

    /// Sign out the current user
    func signOut() async throws

    /// Get the currently signed-in user, nil if not signed in
    func currentUser() async -> UserProfile?

    /// Stream of auth state changes
    var authStateStream: AsyncStream<UserProfile?> { get }
}
