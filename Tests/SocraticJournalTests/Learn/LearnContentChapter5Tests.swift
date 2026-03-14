// LearnContentChapter5Tests.swift
// SocraticJournalTests
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

@Suite("LearnContent Chapter 5 Tests")
struct LearnContentChapter5Tests {

    @Test("Chapter 5 exists with id 5")
    func chapter5Exists() {
        let chapter = LearnContent.chapters.first { $0.id == 5 }
        #expect(chapter != nil)
    }

    @Test("Chapter 5 has exactly 4 articles")
    func chapter5ArticleCount() {
        let chapter = LearnContent.chapters.first { $0.id == 5 }!
        #expect(chapter.articles.count == 4)
    }

    @Test("Article IDs are sequential (12, 13, 14, 15)")
    func articleIDsSequential() {
        let chapter = LearnContent.chapters.first { $0.id == 5 }!
        let ids = chapter.articles.map(\.id)
        #expect(ids == [12, 13, 14, 15])
    }

    @Test("All Chapter 5 articles have non-empty required fields")
    func articleFieldsNonEmpty() {
        let chapter = LearnContent.chapters.first { $0.id == 5 }!
        for article in chapter.articles {
            #expect(!article.title.isEmpty, "Article \(article.id) has empty title")
            #expect(!article.subtitle.isEmpty, "Article \(article.id) has empty subtitle")
            #expect(!article.tag.isEmpty, "Article \(article.id) has empty tag")
            #expect(!article.tagColorHex.isEmpty, "Article \(article.id) has empty tagColorHex")
            #expect(!article.readTime.isEmpty, "Article \(article.id) has empty readTime")
            #expect(!article.body.isEmpty, "Article \(article.id) has empty body")
        }
    }

    @Test("Total article count is 16 (12 existing + 4 new)")
    func totalArticleCount() {
        #expect(LearnContent.allArticles.count == 16)
    }

    @Test("All article IDs across all chapters are globally unique")
    func articleIDsGloballyUnique() {
        let allIDs = LearnContent.allArticles.map(\.id)
        let uniqueIDs = Set(allIDs)
        #expect(allIDs.count == uniqueIDs.count)
    }

    @Test("All tagColorHex values are valid 6-character hex strings")
    func tagColorHexValid() {
        let hexChars = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        for article in LearnContent.allArticles {
            #expect(article.tagColorHex.count == 6,
                    "Article \(article.id) tagColorHex is not 6 chars: \(article.tagColorHex)")
            #expect(article.tagColorHex.unicodeScalars.allSatisfy { hexChars.contains($0) },
                    "Article \(article.id) has invalid hex chars: \(article.tagColorHex)")
        }
    }

    @Test("Quick facts count is 12 (8 existing + 4 new)")
    func quickFactsCount() {
        #expect(LearnContent.quickFacts.count == 12)
    }
}
