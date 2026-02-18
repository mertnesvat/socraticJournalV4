// AuthServiceProtocol.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining local authentication and user profile management.
/// No network calls -- this is local-only auth backed by SwiftData.
@MainActor
public protocol AuthServiceProtocol: AnyObject {
    /// The currently signed-in user, or nil if not authenticated.
    var currentUser: User? { get }

    /// Whether a user is currently signed in.
    var isAuthenticated: Bool { get }

    /// Create a local user profile and sign in.
    /// - Parameters:
    ///   - name: The user's display name (required, non-empty).
    ///   - avatarData: Optional JPEG/PNG image data for the user's avatar.
    func signIn(name: String, avatarData: Data?) async throws

    /// Update the current user's profile information.
    /// - Parameters:
    ///   - name: Updated display name.
    ///   - avatarData: Updated avatar image data (nil to remove).
    func updateProfile(name: String, avatarData: Data?) async throws

    /// Sign out the current user. Profile data is retained for re-login.
    func signOut() async throws

    /// Permanently delete the user account and all associated data.
    func deleteAccount() async throws
}
