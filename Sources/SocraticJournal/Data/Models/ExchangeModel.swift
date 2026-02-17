// ExchangeModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// SwiftData persistence model for Exchange (embedded in JournalSession)
@Model
public final class ExchangeModel {
    @Attribute(.unique) public var id: String
    public var question: String
    public var answer: String
    public var timestamp: Date
    public var socratesReaction: String?
    public var clarityMirror: String?
    public var insightCard: String?
    public var skipped: Bool

    public init(
        id: String,
        question: String,
        answer: String,
        timestamp: Date,
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

    /// Converts domain entity to SwiftData model
    public static func from(exchange: Exchange) -> ExchangeModel {
        ExchangeModel(
            id: exchange.id,
            question: exchange.question,
            answer: exchange.answer,
            timestamp: exchange.timestamp,
            socratesReaction: exchange.socratesReaction,
            clarityMirror: exchange.clarityMirror,
            insightCard: exchange.insightCard,
            skipped: exchange.skipped
        )
    }

    /// Converts SwiftData model to domain entity
    public func toDomain() -> Exchange {
        Exchange(
            id: id,
            question: question,
            answer: answer,
            timestamp: timestamp,
            socratesReaction: socratesReaction,
            clarityMirror: clarityMirror,
            insightCard: insightCard,
            skipped: skipped
        )
    }
}
