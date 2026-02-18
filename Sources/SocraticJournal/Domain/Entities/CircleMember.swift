// CircleMember.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Role of a member within a circle
public enum CircleMemberRole: String, Codable, Sendable {
    case creator
    case member
}

/// Represents a member within a circle
public struct CircleMember: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID { userId }
    public let userId: UUID
    public var displayName: String
    public var avatarPath: String?
    public let joinedAt: Date
    public let role: CircleMemberRole
    /// Whether this is a simulated/mock member (for local-only mode)
    public var isSimulated: Bool

    public init(
        userId: UUID = UUID(),
        displayName: String,
        avatarPath: String? = nil,
        joinedAt: Date = Date(),
        role: CircleMemberRole = .member,
        isSimulated: Bool = false
    ) {
        self.userId = userId
        self.displayName = displayName
        self.avatarPath = avatarPath
        self.joinedAt = joinedAt
        self.role = role
        self.isSimulated = isSimulated
    }
}
