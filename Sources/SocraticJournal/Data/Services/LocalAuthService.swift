// LocalAuthService.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftData
import SwiftUI

/// Local authentication service backed by SwiftData.
/// Persists a single user profile on-device with no network calls.
@Observable
@MainActor
public final class LocalAuthService: AuthServiceProtocol {
    // MARK: - State

    public private(set) var currentUser: User?

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Dependencies

    private let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Init

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        loadExistingUser()
    }

    // MARK: - Private

    private func loadExistingUser() {
        let descriptor = FetchDescriptor<User>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        do {
            let users = try modelContext.fetch(descriptor)
            currentUser = users.first
        } catch {
            #if DEBUG
            print("[LocalAuthService] Failed to load user: \(error)")
            #endif
            currentUser = nil
        }
    }

    // MARK: - AuthServiceProtocol

    public func signIn(name: String, avatarData: Data?) async throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw AuthError.invalidName
        }

        let user = User(
            displayName: trimmedName,
            avatarImageData: avatarData
        )

        modelContext.insert(user)
        try modelContext.save()
        currentUser = user
    }

    public func updateProfile(name: String, avatarData: Data?) async throws {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw AuthError.invalidName
        }

        user.displayName = trimmedName
        user.avatarImageData = avatarData
        try modelContext.save()
    }

    public func signOut() async throws {
        currentUser = nil
    }

    public func deleteAccount() async throws {
        // Delete all users from SwiftData
        let descriptor = FetchDescriptor<User>()
        let users = try modelContext.fetch(descriptor)
        for user in users {
            modelContext.delete(user)
        }
        try modelContext.save()
        currentUser = nil
    }
}

// MARK: - Auth Errors

public enum AuthError: LocalizedError {
    case invalidName
    case notAuthenticated
    case persistenceFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Please enter a valid name."
        case .notAuthenticated:
            return "No user is currently signed in."
        case .persistenceFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}
#endif
