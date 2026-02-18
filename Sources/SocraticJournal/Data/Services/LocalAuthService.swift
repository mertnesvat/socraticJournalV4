// LocalAuthService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Local UserDefaults-backed implementation of AuthServiceProtocol
/// Stores the current user as JSON-encoded CircleUser
/// Email/password are accepted but ignored — local mode only
public final class LocalAuthService: AuthServiceProtocol, @unchecked Sendable {
    // MARK: - Constants

    private static let userDefaultsKey = "circle_current_user"

    // MARK: - Private

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let lock = NSLock()
    private var _currentUser: CircleUser?
    private var continuations: [UUID: AsyncStream<CircleUser?>.Continuation] = [:]

    // MARK: - Init

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Load persisted user at init time
        self._currentUser = Self.loadUser(from: defaults, decoder: decoder)
    }

    // MARK: - AuthServiceProtocol

    public var currentUser: CircleUser? {
        lock.lock()
        defer { lock.unlock() }
        return _currentUser
    }

    public var authStateStream: AsyncStream<CircleUser?> {
        AsyncStream { continuation in
            let id = UUID()
            lock.lock()
            let user = _currentUser
            continuations[id] = continuation
            lock.unlock()

            // Yield current value immediately
            continuation.yield(user)

            continuation.onTermination = { [weak self] _ in
                self?.lock.lock()
                self?.continuations.removeValue(forKey: id)
                self?.lock.unlock()
            }
        }
    }

    public func signUp(name: String, email: String?, password: String?) async throws -> CircleUser {
        let user = CircleUser(
            id: UUID(),
            displayName: name,
            email: email,
            avatarPath: nil,
            createdAt: Date()
        )
        try persist(user)
        return user
    }

    public func signIn(email: String, password: String) async throws -> CircleUser {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }
        return user
    }

    public func signOut() async throws {
        lock.lock()
        _currentUser = nil
        let conts = continuations
        lock.unlock()

        defaults.removeObject(forKey: Self.userDefaultsKey)
        for cont in conts.values {
            cont.yield(nil)
        }
    }

    public func updateProfile(displayName: String?, avatarPath: String?) async throws -> CircleUser {
        guard var user = currentUser else {
            throw AuthError.notAuthenticated
        }
        if let displayName {
            user.displayName = displayName
        }
        if let avatarPath {
            user.avatarPath = avatarPath
        }
        try persist(user)
        return user
    }

    // MARK: - Private Helpers

    private func persist(_ user: CircleUser) throws {
        let data = try encoder.encode(user)
        defaults.set(data, forKey: Self.userDefaultsKey)

        lock.lock()
        _currentUser = user
        let conts = continuations
        lock.unlock()

        for cont in conts.values {
            cont.yield(user)
        }
    }

    private static func loadUser(from defaults: UserDefaults, decoder: JSONDecoder) -> CircleUser? {
        guard let data = defaults.data(forKey: userDefaultsKey) else { return nil }
        return try? decoder.decode(CircleUser.self, from: data)
    }
}
