// FriendGroup.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A named group of friends for organized social interactions
public struct FriendGroup: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var name: String
    public var memberIds: [String]
    public let createdAt: Date

    public init(
        id: String,
        name: String,
        memberIds: [String],
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.memberIds = memberIds
        self.createdAt = createdAt
    }
}
