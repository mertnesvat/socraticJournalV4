// UserProfile.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents a user's profile in the Circle app
public struct UserProfile: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public var displayName: String
    public var avatarURL: String?
    public var circleIds: [String]
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        displayName: String,
        avatarURL: String? = nil,
        circleIds: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.circleIds = circleIds
        self.createdAt = createdAt
    }

    /// First initial for avatar placeholder
    public var initial: String {
        String(displayName.prefix(1)).uppercased()
    }
}
