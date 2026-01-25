// FirebaseFunctionsServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

// MARK: - Service Protocol

/// Protocol defining Firebase Functions cloud function invocations
public protocol FirebaseFunctionsServiceProtocol: Sendable {
    /// Generate a clarity mirror reflection for a user's answer
    /// - Parameter request: The clarity mirror request with question and answer
    /// - Returns: The AI-generated reflection mirror text
    func generateClarityMirror(request: ClarityMirrorRequest) async throws -> String

    /// Generate a follow-up Socratic question based on the conversation
    /// - Parameter request: The follow-up question request with context
    /// - Returns: The AI-generated follow-up question
    func generateFollowUpQuestion(request: FollowUpQuestionRequest) async throws -> String

    /// Generate Socrates' reaction to a user's answer
    /// - Parameter request: The reaction request with question and answer
    /// - Returns: The AI-generated Socrates reaction description
    func generateSocratesReaction(request: SocratesReactionRequest) async throws -> String

    /// Analyze personality from journal entries
    /// - Parameter request: The personality analysis request with journal entries
    /// - Returns: The AI-generated Big Five personality profile
    func analyzePersonality(request: PersonalityAnalysisRequest) async throws -> BigFiveProfile

    /// Check the health of the Firebase Functions backend
    /// - Returns: The health check response with status and version
    func healthCheck() async throws -> HealthCheckResponse

    /// Generate a contextual wisdom quote based on journal themes
    /// - Parameter request: The wisdom quote request with recent themes and optional mood
    /// - Returns: The AI-generated wisdom quote with text, author, source, and relevance
    func generateWisdomQuote(request: WisdomQuoteRequest) async throws -> AIWisdomQuote

    /// Generate a summary of a completed journal session
    /// - Parameter request: The session summary request with all exchanges
    /// - Returns: The AI-generated 2-3 sentence summary of the session
    func generateSessionSummary(request: SessionSummaryRequest) async throws -> String

    /// Enhance a future letter with AI-generated reflection prompts
    /// - Parameter request: The letter enhancement request with letter content
    /// - Returns: AI-generated prompts and encouragement to help deepen the letter
    func enhanceFutureLetter(request: LetterEnhancementRequest) async throws -> LetterEnhancementResponse
}

// MARK: - Request Types

/// Request data for generating a clarity mirror reflection
public struct ClarityMirrorRequest: Codable, Sendable {
    /// The Socratic question being answered
    public let question: String
    /// The user's answer to the question
    public let answer: String
    /// Optional array of previous Q&A exchanges in the session
    public let previousExchanges: [ExchangeData]?

    public init(question: String, answer: String, previousExchanges: [ExchangeData]? = nil) {
        self.question = question
        self.answer = answer
        self.previousExchanges = previousExchanges
    }
}

/// Represents a single question-answer exchange
public struct ExchangeData: Codable, Sendable {
    /// The question that was asked
    public let question: String
    /// The user's answer
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}

/// Request data for generating a follow-up question
public struct FollowUpQuestionRequest: Codable, Sendable {
    /// The current question being answered
    public let currentQuestion: String
    /// The user's current answer
    public let currentAnswer: String
    /// Optional array of previous Q&A exchanges
    public let previousExchanges: [ExchangeData]?
    /// The current question index (0-based)
    public let questionIndex: Int

    public init(
        currentQuestion: String,
        currentAnswer: String,
        previousExchanges: [ExchangeData]? = nil,
        questionIndex: Int
    ) {
        self.currentQuestion = currentQuestion
        self.currentAnswer = currentAnswer
        self.previousExchanges = previousExchanges
        self.questionIndex = questionIndex
    }
}

/// Request data for generating a Socrates reaction
public struct SocratesReactionRequest: Codable, Sendable {
    /// The question being answered
    public let question: String
    /// The user's answer
    public let answer: String

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}

/// Request data for personality analysis
public struct PersonalityAnalysisRequest: Codable, Sendable {
    /// Array of journal entries to analyze
    public let journalEntries: [JournalEntryData]

    public init(journalEntries: [JournalEntryData]) {
        self.journalEntries = journalEntries
    }
}

/// Data representing a single journal entry for analysis
public struct JournalEntryData: Codable, Sendable {
    /// The Socratic question
    public let question: String
    /// The user's answer
    public let answer: String
    /// Optional clarity mirror reflection for this exchange
    public let clarityMirror: String?

    public init(question: String, answer: String, clarityMirror: String? = nil) {
        self.question = question
        self.answer = answer
        self.clarityMirror = clarityMirror
    }
}

/// Request data for generating a contextual wisdom quote
public struct WisdomQuoteRequest: Codable, Sendable {
    /// Array of recent journal themes to base the quote on
    public let recentThemes: [String]
    /// Optional current mood to influence quote selection
    public let mood: String?

    public init(recentThemes: [String], mood: String? = nil) {
        self.recentThemes = recentThemes
        self.mood = mood
    }
}

/// Request data for generating a session summary
public struct SessionSummaryRequest: Codable, Sendable {
    /// Array of exchanges from the completed session
    public let exchanges: [SessionExchangeData]

    public init(exchanges: [SessionExchangeData]) {
        self.exchanges = exchanges
    }
}

/// Data representing a single exchange for session summary generation
public struct SessionExchangeData: Codable, Sendable {
    /// The Socratic question
    public let question: String
    /// The user's answer
    public let answer: String
    /// Optional clarity mirror reflection for this exchange
    public let clarityMirror: String?

    public init(question: String, answer: String, clarityMirror: String? = nil) {
        self.question = question
        self.answer = answer
        self.clarityMirror = clarityMirror
    }
}

/// Request data for enhancing a future letter with AI prompts
public struct LetterEnhancementRequest: Codable, Sendable {
    /// The current letter content
    public let letterContent: String
    /// Optional theme for the letter
    public let letterTheme: String?
    /// Optional delivery date string
    public let deliveryDate: String?

    public init(letterContent: String, letterTheme: String? = nil, deliveryDate: String? = nil) {
        self.letterContent = letterContent
        self.letterTheme = letterTheme
        self.deliveryDate = deliveryDate
    }
}

// MARK: - Response Types

/// AI-generated wisdom quote response from Firebase function
public struct AIWisdomQuote: Codable, Sendable, Equatable {
    /// The quote text
    public let text: String
    /// The philosopher/author name
    public let author: String
    /// Optional source work (book, speech, etc.)
    public let source: String?
    /// Brief explanation of why this quote is relevant to the themes
    public let relevance: String

    public init(text: String, author: String, source: String?, relevance: String) {
        self.text = text
        self.author = author
        self.source = source
        self.relevance = relevance
    }

    /// Formatted attribution string
    public var attribution: String {
        if let source = source {
            return "- \(author), \(source)"
        }
        return "- \(author)"
    }

    /// Convert to domain WisdomQuote entity
    public func toWisdomQuote(theme: QuoteTheme = .universal) -> WisdomQuote {
        WisdomQuote(
            text: text,
            author: author,
            source: source,
            theme: theme
        )
    }
}

/// Response from the health check endpoint
public struct HealthCheckResponse: Codable, Sendable {
    /// The status of the service (e.g., "ok")
    public let status: String
    /// ISO8601 timestamp of the health check
    public let timestamp: String
    /// Version of the backend service
    public let version: String

    public init(status: String, timestamp: String, version: String) {
        self.status = status
        self.timestamp = timestamp
        self.version = version
    }
}

/// AI-generated letter enhancement response from Firebase function
public struct LetterEnhancementResponse: Codable, Sendable, Equatable {
    /// Array of reflection prompts to help deepen the letter
    public let prompts: [String]
    /// Brief word of encouragement about the writing journey
    public let encouragement: String

    public init(prompts: [String], encouragement: String) {
        self.prompts = prompts
        self.encouragement = encouragement
    }
}

// MARK: - Error Types

/// Errors that can occur when calling Firebase Functions
public enum FirebaseFunctionsError: Error, Sendable {
    /// Network connectivity error
    case networkError(Error)
    /// Request timed out
    case timeout
    /// Invalid argument provided to the function
    case invalidArgument(String)
    /// Backend service is unavailable
    case serviceUnavailable
    /// Internal server error
    case internalError(String)
    /// Failed to decode the response
    case decodingError(Error)
    /// User is not authenticated (if required)
    case unauthenticated
    /// Resource quota exhausted (rate limit)
    case resourceExhausted
    /// Unknown error
    case unknown(String)
}

extension FirebaseFunctionsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidArgument(let message):
            return "Invalid request: \(message)"
        case .serviceUnavailable:
            return "Service temporarily unavailable. Please try again later."
        case .internalError(let message):
            return "Server error: \(message)"
        case .decodingError(let error):
            return "Failed to process response: \(error.localizedDescription)"
        case .unauthenticated:
            return "Authentication required."
        case .resourceExhausted:
            return "Too many requests. Please wait and try again."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
}
