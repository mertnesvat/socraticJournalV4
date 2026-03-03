// BreathContentServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

public protocol BreathContentServiceProtocol: Sendable {
    func getAllLearningBits() -> [LearningBit]
    func getLearningBitsForCategory(_ category: LearningCategory) -> [LearningBit]
}
