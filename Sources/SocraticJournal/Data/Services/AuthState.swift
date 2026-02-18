// AuthState.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Observable auth state that drives the root navigation decision.
/// Wraps AuthServiceProtocol so the service can be swapped (local -> Firebase).
@Observable
@MainActor
public final class AuthState {
    // MARK: - State

    public private(set) var currentUser: CircleUser?
    public private(set) var isLoading: Bool = false

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Dependencies

    private let service: AuthServiceProtocol

    // MARK: - Init

    public init(service: AuthServiceProtocol) {
        self.service = service
    }

    // MARK: - Actions

    /// Load the currently persisted user from the auth service.
    public func loadCurrentUser() async {
        isLoading = true
        currentUser = service.currentUser
        isLoading = false
    }

    /// Create a new local profile with the given display name.
    public func createProfile(name: String) async {
        isLoading = true
        do {
            let user = try await service.signUp(name: name, email: nil, password: nil)
            currentUser = user
        } catch {
            // Local auth should not fail — surface in debug only
            #if DEBUG
            print("[AuthState] createProfile failed: \(error)")
            #endif
        }
        isLoading = false
    }

    /// Sign out the current user.
    public func signOut() async {
        isLoading = true
        do {
            try await service.signOut()
            currentUser = nil
        } catch {
            #if DEBUG
            print("[AuthState] signOut failed: \(error)")
            #endif
        }
        isLoading = false
    }
}
#endif
