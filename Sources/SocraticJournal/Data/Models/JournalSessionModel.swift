// JournalSessionModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// SwiftData persistence model for JournalSession
@Model
public final class JournalSessionModel {
    @Attribute(.unique) public var id: String
    public var createdAt: Date
    public var exchanges: [ExchangeModel]
    public var clarityScoreData: Data?
    public var wisdomQuoteData: Data?
    public var summary: String?
    public var isComplete: Bool

    public init(
        id: String,
        createdAt: Date,
        exchanges: [ExchangeModel] = [],
        clarityScoreData: Data? = nil,
        wisdomQuoteData: Data? = nil,
        summary: String? = nil,
        isComplete: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.exchanges = exchanges
        self.clarityScoreData = clarityScoreData
        self.wisdomQuoteData = wisdomQuoteData
        self.summary = summary
        self.isComplete = isComplete
    }

    /// Converts domain entity to SwiftData model
    public static func from(session: JournalSession) -> JournalSessionModel {
        let exchanges = session.exchanges.map { ExchangeModel.from(exchange: $0) }
        let clarityData = session.clarityScore.flatMap { try? JSONEncoder().encode($0) }
        let quoteData = session.wisdomQuote.flatMap { try? JSONEncoder().encode($0) }

        return JournalSessionModel(
            id: session.id,
            createdAt: session.createdAt,
            exchanges: exchanges,
            clarityScoreData: clarityData,
            wisdomQuoteData: quoteData,
            summary: session.summary,
            isComplete: session.isComplete
        )
    }

    /// Converts SwiftData model to domain entity
    public func toDomain() -> JournalSession {
        let exchanges = exchanges.map { $0.toDomain() }
        let clarityScore = clarityScoreData.flatMap { try? JSONDecoder().decode(ClarityScore.self, from: $0) }
        let wisdomQuote = wisdomQuoteData.flatMap { try? JSONDecoder().decode(WisdomQuote.self, from: $0) }

        return JournalSession(
            id: id,
            createdAt: createdAt,
            exchanges: exchanges,
            clarityScore: clarityScore,
            wisdomQuote: wisdomQuote,
            summary: summary,
            isComplete: isComplete
        )
    }
}
