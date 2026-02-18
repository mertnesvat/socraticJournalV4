// CircleGroup.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a circle of close people who share daily prompts
/// Named CircleGroup to avoid conflict with SwiftUI's Circle shape
public struct CircleGroup: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var emoji: String
    public let creatorId: UUID
    public var memberIds: [UUID]
    public let createdAt: Date
    /// Hour and minute for daily prompt delivery
    public var promptHour: Int
    public var promptMinute: Int
    /// Invite code for joining this circle
    public var inviteCode: String?

    public init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "💬",
        creatorId: UUID,
        memberIds: [UUID] = [],
        createdAt: Date = Date(),
        promptHour: Int = 18,
        promptMinute: Int = 0,
        inviteCode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.creatorId = creatorId
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.promptHour = promptHour
        self.promptMinute = promptMinute
        self.inviteCode = inviteCode
    }

    /// Number of weeks since circle was created
    public var weekNumber: Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: createdAt, to: Date()).weekOfYear ?? 0
        return max(1, weeks + 1)
    }

    /// Maximum allowed members per circle
    public static let maxMembers = 5
}
