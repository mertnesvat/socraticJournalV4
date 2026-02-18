// CircleUser.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a user in the Circle app
public struct CircleUser: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var displayName: String
    public var email: String?
    public var avatarPath: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        displayName: String,
        email: String? = nil,
        avatarPath: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarPath = avatarPath
        self.createdAt = createdAt
    }
}
