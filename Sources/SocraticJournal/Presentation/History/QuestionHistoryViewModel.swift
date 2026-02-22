// QuestionHistoryViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Filter options for the question history list
public enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case answered = "Answered"
    case skipped = "Skipped"
}

/// ViewModel managing the question history screen with filter and mock answer tracking
@Observable
@MainActor
public final class QuestionHistoryViewModel {

    // MARK: - State

    public private(set) var questions: [DailyQuestion] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    public var selectedFilter: HistoryFilter = .all

    /// Mock set of question IDs the user has answered
    public private(set) var answeredQuestionIds: Set<String> = []

    /// Mock friend counts per question (questionId -> count)
    private var friendCounts: [String: Int] = [:]

    // MARK: - Dependencies

    private let questionFeedService: QuestionFeedServiceProtocol

    // MARK: - Computed

    /// Questions filtered by the selected history filter, newest first
    public var filteredQuestions: [DailyQuestion] {
        switch selectedFilter {
        case .all:
            return questions
        case .answered:
            return questions.filter { answeredQuestionIds.contains($0.id) }
        case .skipped:
            return questions.filter { !answeredQuestionIds.contains($0.id) }
        }
    }

    // MARK: - Init

    public init(questionFeedService: QuestionFeedServiceProtocol) {
        self.questionFeedService = questionFeedService
    }

    // MARK: - Actions

    /// Loads question history and generates mock answer data
    public func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let history = try await questionFeedService.getQuestionHistory()
            questions = history.sorted { $0.createdAt > $1.createdAt }

            // Generate mock answered set -- roughly 70% of questions answered
            var answered: Set<String> = []
            for (index, question) in questions.enumerated() {
                if index % 3 != 2 {
                    answered.insert(question.id)
                }
            }
            answeredQuestionIds = answered

            // Generate mock friend counts for each question
            var counts: [String: Int] = [:]
            for question in questions {
                counts[question.id] = Int.random(in: 2...8)
            }
            friendCounts = counts
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Returns whether the user has answered a given question
    public func isAnswered(_ question: DailyQuestion) -> Bool {
        answeredQuestionIds.contains(question.id)
    }

    /// Returns mock friend count for a given question
    public func friendCount(for question: DailyQuestion) -> Int {
        friendCounts[question.id] ?? 0
    }
}
#endif
