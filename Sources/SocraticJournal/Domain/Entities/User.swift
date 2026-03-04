// User.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

public struct User: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var displayName: String
    public let createdAt: Date

    public init(id: String, displayName: String, createdAt: Date) {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
    }
}
