// Exchange.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a single question-answer exchange in a Socratic dialogue session
public struct Exchange: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let question: String
    public let answer: String
    public let timestamp: Date

    /// AI-generated emotional response from Socrates (e.g., "Socrates nods slowly...")
    public var socratesReaction: String?

    /// AI-generated reflection of user's insights
    public var clarityMirror: String?

    /// 3-4 word summary of the insight (e.g., "Growth through challenge")
    public var insightCard: String?

    /// Whether the user skipped this question
    public var skipped: Bool

    public init(
        id: String = UUID().uuidString,
        question: String,
        answer: String,
        timestamp: Date = Date(),
        socratesReaction: String? = nil,
        clarityMirror: String? = nil,
        insightCard: String? = nil,
        skipped: Bool = false
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.timestamp = timestamp
        self.socratesReaction = socratesReaction
        self.clarityMirror = clarityMirror
        self.insightCard = insightCard
        self.skipped = skipped
    }
}
