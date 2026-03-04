// BreathContentServiceProtocol.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Protocol for accessing educational breathing content
public protocol BreathContentServiceProtocol: Sendable {
    /// Get all available learning bits
    func getAllLearningBits() -> [LearningBit]

    /// Get learning bits filtered by category
    func getLearningBitsForCategory(_ category: LearningCategory) -> [LearningBit]
}
