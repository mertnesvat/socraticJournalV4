// FutureLetter.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Status of a letter to future self
public enum FutureLetterStatus: String, Codable, Sendable, CaseIterable {
    case sealed      // Letter is sealed and waiting
    case ready       // Letter is ready to be read (delivery date reached)
    case read        // Letter has been read
    case archived    // Letter has been archived
}

/// A letter written to one's future self
public struct FutureLetter: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let content: String
    public let createdAt: Date
    public let deliveryDate: Date
    public var status: FutureLetterStatus
    public var readAt: Date?

    public init(
        id: String = UUID().uuidString,
        content: String,
        createdAt: Date = Date(),
        deliveryDate: Date,
        status: FutureLetterStatus = .sealed,
        readAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.deliveryDate = deliveryDate
        self.status = status
        self.readAt = readAt
    }

    /// Whether the letter is ready to be read
    public var isReadyToOpen: Bool {
        Date() >= deliveryDate && status == .sealed
    }

    /// Time remaining until the letter can be opened
    public var timeRemaining: String? {
        guard status == .sealed else { return nil }

        let now = Date()
        if now >= deliveryDate {
            return nil
        }

        let components = Calendar.current.dateComponents(
            [.day, .hour],
            from: now,
            to: deliveryDate
        )

        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        return "Soon"
    }
}
