// Circle.swift
// Circle
// Copyright 2024 StudioNext

import Foundation

/// Represents a circle of 2-5 close people who share daily voice notes
public struct Circle: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var emoji: String
    public var colorHex: String
    public let createdBy: String
    public let createdAt: Date
    public var inviteCode: String
    public var memberIds: [String]

    public init(
        id: String = UUID().uuidString,
        name: String,
        emoji: String = "💬",
        colorHex: String = "#007AFF",
        createdBy: String,
        createdAt: Date = Date(),
        inviteCode: String = Circle.generateInviteCode(),
        memberIds: [String] = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.inviteCode = inviteCode
        self.memberIds = memberIds
    }

    /// Whether the circle has reached its maximum size
    public var isFull: Bool {
        memberIds.count >= Circle.maxMembers
    }

    /// Current number of members
    public var memberCount: Int {
        memberIds.count
    }

    public static let minMembers = 2
    public static let maxMembers = 5

    /// Generate a 6-character alphanumeric invite code
    public static func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
