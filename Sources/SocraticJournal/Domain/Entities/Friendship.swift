// Friendship.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Status of a friendship between two users
public enum FriendshipStatus: String, Codable, Sendable, Hashable, CaseIterable {
    case pending
    case accepted
    case blocked
}

/// Represents a friendship connection between two users
public struct Friendship: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    public let userId: String
    public let friendId: String
    public var status: FriendshipStatus
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        userId: String,
        friendId: String,
        status: FriendshipStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.friendId = friendId
        self.status = status
        self.createdAt = createdAt
    }
}
