// Circle.swift
// Circle
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// A Circle represents a small group of people (2-5) who share daily voice prompts.
/// Each circle has a name, emoji icon, and members.
@Model
public final class Circle {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var emojiIcon: String
    public var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CircleMember.circle)
    public var members: [CircleMember]

    // MARK: - Computed Properties

    /// Number of members in this circle.
    public var memberCount: Int {
        members.count
    }

    /// Display title combining emoji and name (e.g., "heart Family").
    public var displayTitle: String {
        "\(emojiIcon) \(name)"
    }

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        name: String,
        emojiIcon: String = "heart",
        createdAt: Date = Date(),
        members: [CircleMember] = []
    ) {
        self.id = id
        self.name = name
        self.emojiIcon = emojiIcon
        self.createdAt = createdAt
        self.members = members
    }
}
