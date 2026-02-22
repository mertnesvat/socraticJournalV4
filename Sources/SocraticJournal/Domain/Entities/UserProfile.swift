// UserProfile.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a user's public profile
public struct UserProfile: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public var displayName: String
    public var username: String
    public var avatarImageName: String?
    public var streakCount: Int
    public let joinedAt: Date
    public var friendCount: Int

    public init(
        id: String = UUID().uuidString,
        displayName: String,
        username: String,
        avatarImageName: String? = nil,
        streakCount: Int = 0,
        joinedAt: Date = Date(),
        friendCount: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarImageName = avatarImageName
        self.streakCount = streakCount
        self.joinedAt = joinedAt
        self.friendCount = friendCount
    }
}
