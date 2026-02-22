// User.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a user of the social voice-opinion platform
public struct User: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var displayName: String
    public var username: String
    public var avatarURL: String?
    public let createdAt: Date
    public var streakCount: Int
    public var friendCount: Int

    public init(
        id: String,
        displayName: String,
        username: String,
        avatarURL: String? = nil,
        createdAt: Date,
        streakCount: Int = 0,
        friendCount: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.username = username
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.streakCount = streakCount
        self.friendCount = friendCount
    }
}
