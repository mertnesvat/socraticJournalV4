// LearnFeedViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation

/// ViewModel for the Learn feed — manages category filtering
@Observable
@MainActor
final class LearnFeedViewModel {
    private let contentService: BreathContentServiceProtocol

    var selectedCategory: LearningCategory?

    var filteredBits: [LearningBit] {
        if let category = selectedCategory {
            return contentService.getLearningBitsForCategory(category)
        }
        return contentService.getAllLearningBits()
    }

    init(contentService: BreathContentServiceProtocol = BreathContentService()) {
        self.contentService = contentService
    }

    func selectCategory(_ category: LearningCategory?) {
        selectedCategory = category
    }
}
#endif
