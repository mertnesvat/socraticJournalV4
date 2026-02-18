// CircleMember.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// A member within a Circle. Each member has a display name and optional avatar.
/// The `isCurrentUser` flag distinguishes the local device user from other members.
@Model
public final class CircleMember {
    @Attribute(.unique) public var id: UUID
    public var displayName: String
    @Attribute(.externalStorage) public var avatarImageData: Data?
    public var joinedAt: Date
    public var isCurrentUser: Bool

    /// Inverse relationship to the parent Circle.
    public var circle: Circle?

    // MARK: - Computed Properties

    /// First letter of first and last name (e.g., "JD" for "John Doe").
    /// Falls back to first character if only one word.
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

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        displayName: String,
        avatarImageData: Data? = nil,
        joinedAt: Date = Date(),
        isCurrentUser: Bool = false,
        circle: Circle? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarImageData = avatarImageData
        self.joinedAt = joinedAt
        self.isCurrentUser = isCurrentUser
        self.circle = circle
    }
}
