// WisdomQuote.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A wisdom quote shown at the end of a journal session
public struct WisdomQuote: Codable, Sendable, Equatable {
    public let text: String
    public let author: String
    public let source: String?

    public init(
        text: String,
        author: String,
        source: String? = nil
    ) {
        self.text = text
        self.author = author
        self.source = source
    }

    /// Formatted attribution string
    public var attribution: String {
        if let source = source {
            return "- \(author), \(source)"
        }
        return "- \(author)"
    }
}
