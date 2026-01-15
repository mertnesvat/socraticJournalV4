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

    public init(
        id: String = UUID().uuidString,
        question: String,
        answer: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.timestamp = timestamp
    }
}
