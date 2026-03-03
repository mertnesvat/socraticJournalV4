// LearningBit.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

enum LearningCategory: String, Codable, Sendable, CaseIterable {
    case science = "The Science"
    case nasal = "Nasal Breathing"
    case ancient = "Ancient Wisdom"
    case techniques = "Techniques"
    case facts = "Surprising Facts"
}

struct LearningBit: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let body: String
    let category: LearningCategory
    let sourceNote: String?
}
