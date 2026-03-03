// LearningBit.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

public enum LearningCategory: String, Codable, Sendable, CaseIterable {
    case science = "The Science"
    case nasal = "Nasal Breathing"
    case ancient = "Ancient Wisdom"
    case techniques = "Techniques"
    case facts = "Surprising Facts"
}

public struct LearningBit: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let category: LearningCategory
    public let sourceNote: String?
}
