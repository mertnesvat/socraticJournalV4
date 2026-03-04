// LearnFeedViewModel.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Learn tab
@Observable
@MainActor
public final class LearnFeedViewModel {
    private(set) var allBits: [LearningBit] = []
    private(set) var filteredBits: [LearningBit] = []
    var selectedCategory: LearningCategory? = nil {
        didSet { applyFilter() }
    }

    private let contentService: BreathContentServiceProtocol

    public init(contentService: BreathContentServiceProtocol) {
        self.contentService = contentService
    }

    public func loadContent() {
        allBits = contentService.getAllLearningBits()
        applyFilter()
    }

    private func applyFilter() {
        if let category = selectedCategory {
            filteredBits = contentService.getLearningBitsForCategory(category)
        } else {
            filteredBits = allBits
        }
    }
}
#endif
