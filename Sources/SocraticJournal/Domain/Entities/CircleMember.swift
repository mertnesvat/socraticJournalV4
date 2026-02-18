// CircleMember.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents a member within a circle
public struct CircleMember: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public var displayName: String
    public var avatarURL: String?
    public let joinedAt: Date
    public var role: CircleRole

    public init(
        id: String = UUID().uuidString,
        userId: String,
        displayName: String,
        avatarURL: String? = nil,
        joinedAt: Date = Date(),
        role: CircleRole = .member
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.joinedAt = joinedAt
        self.role = role
    }
}

/// Role within a circle
public enum CircleRole: String, Codable, Sendable, Equatable {
    case owner
    case member
}
