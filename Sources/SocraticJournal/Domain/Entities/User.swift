// User.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// User entity representing a local user profile.
/// Persisted via SwiftData for local-only authentication.
@Model
public final class User {
    @Attribute(.unique) public var id: UUID
    public var displayName: String
    @Attribute(.externalStorage) public var avatarImageData: Data?
    public var createdAt: Date

    /// First letter of first and last name (e.g., "JD" for "John Doe").
    /// Falls back to first character of display name if only one word.
    public var initials: String {
        let components = displayName
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        guard let first = components.first else { return "?" }

        if components.count >= 2, let last = components.last {
            let firstInitial = first.prefix(1).uppercased()
            let lastInitial = last.prefix(1).uppercased()
            return "\(firstInitial)\(lastInitial)"
        }

        return first.prefix(1).uppercased()
    }

    public init(
        id: UUID = UUID(),
        displayName: String,
        avatarImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarImageData = avatarImageData
        self.createdAt = createdAt
    }
}
