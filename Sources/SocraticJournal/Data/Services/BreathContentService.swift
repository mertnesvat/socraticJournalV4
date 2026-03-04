// BreathContentService.swift
// Breathe
// Copyright 2024 StudioNext

import Foundation

/// Hardcoded educational content about breathing science
public final class BreathContentService: BreathContentServiceProtocol, @unchecked Sendable {

    private let learningBits: [LearningBit] = [
        LearningBit(
            id: "nose-medicine",
            title: "Your Nose Makes Medicine",
            body: "Your nasal sinuses produce nitric oxide — a molecule that opens blood vessels, fights bacteria, and helps your lungs absorb 10-15% more oxygen. Mouth breathing bypasses this entirely. Humming increases nasal nitric oxide by 15x. Every breath through your nose is a dose of your body's own pharmacy.",
            category: .nasal,
            sourceNote: "Lundberg et al. 1995, Weitzberg & Lundberg 2002"
        ),
        LearningBit(
            id: "perfect-breath",
            title: "The Perfect Breath is 5.5 Seconds",
            body: "Researchers found that breathing at 5.5 breaths per minute creates 'coherence' — when heart, lungs, and circulation synchronize for peak efficiency. Buddhist monks chanting Om Mani Padme Hum and Catholics reciting the rosary in Latin both breathe at exactly this rate. These traditions developed independently, yet converged on the same optimal rhythm.",
            category: .science,
            sourceNote: "Bernardi et al. 2001, James Nestor \"Breath\""
        ),
        LearningBit(
            id: "worst-breathers",
            title: "We Are the Worst Breathers on Earth",
            body: "No other species suffers from chronic snoring, sleep apnea, or breathing dysfunction at the rates humans do. The shift to soft processed foods over millennia shrank our jaws and narrowed our airways. When James Nestor plugged his nose for 10 days, his blood pressure hit stage 2 hypertension, snoring increased 4,800%, and he averaged 25 sleep apnea events per night. Switching back to nasal breathing reversed it all.",
            category: .science,
            sourceNote: "James Nestor \"Breath\", Stanford experiment"
        )
    ]

    public init() {}

    public func getAllLearningBits() -> [LearningBit] {
        learningBits
    }

    public func getLearningBitsForCategory(_ category: LearningCategory) -> [LearningBit] {
        learningBits.filter { $0.category == category }
    }
}
