// MockAuthService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData

/// Mock authentication service for SwiftUI previews and testing.
/// Returns a sample user without requiring SwiftData persistence.
@Observable
@MainActor
public final class MockAuthService: AuthServiceProtocol {
    // MARK: - State

    public private(set) var currentUser: User?

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Init

    /// Creates a mock auth service.
    /// - Parameter isSignedIn: If true, starts with a sample user already signed in.
    public init(isSignedIn: Bool = true) {
        if isSignedIn {
            self.currentUser = User(
                displayName: "Jack",
                avatarImageData: nil,
                createdAt: Date()
            )
        }
    }

    // MARK: - AuthServiceProtocol

    public func signIn(name: String, avatarData: Data?) async throws {
        currentUser = User(
            displayName: name,
            avatarImageData: avatarData,
            createdAt: Date()
        )
    }

    public func updateProfile(name: String, avatarData: Data?) async throws {
        currentUser?.displayName = name
        currentUser?.avatarImageData = avatarData
    }

    public func signOut() async throws {
        currentUser = nil
    }

    public func deleteAccount() async throws {
        currentUser = nil
    }
}
#endif
