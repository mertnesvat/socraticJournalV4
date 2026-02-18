// AuthServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol defining authentication capabilities
/// Local implementation stores in UserDefaults; Firebase implementation uses Firebase Auth
public protocol AuthServiceProtocol: Sendable {
    /// Create a new user profile
    /// - Parameters:
    ///   - name: Display name (required)
    ///   - email: Email address (optional, used by Firebase implementation)
    ///   - password: Password (optional, used by Firebase implementation)
    /// - Returns: The created user
    func signUp(name: String, email: String?, password: String?) async throws -> CircleUser

    /// Sign in with existing credentials
    /// - Parameters:
    ///   - email: Email address
    ///   - password: Password
    /// - Returns: The signed-in user
    func signIn(email: String, password: String) async throws -> CircleUser

    /// Sign out the current user
    func signOut() async throws

    /// Get the currently authenticated user, if any
    var currentUser: CircleUser? { get }

    /// Stream of auth state changes
    var authStateStream: AsyncStream<CircleUser?> { get }

    /// Update the current user's profile
    func updateProfile(displayName: String?, avatarPath: String?) async throws -> CircleUser
}

/// Errors that can occur during authentication
public enum AuthError: Error, LocalizedError, Sendable {
    case notAuthenticated
    case invalidCredentials
    case accountAlreadyExists
    case weakPassword
    case networkError
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You are not signed in"
        case .invalidCredentials:
            return "Invalid email or password"
        case .accountAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network connection error"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
