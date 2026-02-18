// PromptFeedbackView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftData
import SwiftUI

/// Simple thumbs up / thumbs down feedback buttons displayed below the daily prompt.
/// Stores feedback locally in SwiftData to influence future prompt category weighting.
struct PromptFeedbackView: View {
    @State private var viewModel: PromptFeedbackViewModel

    init(viewModel: PromptFeedbackViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        HStack(spacing: 16) {
            Text("How was this prompt?")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            // Thumbs up
            Button {
                viewModel.submitFeedback(.thumbsUp)
            } label: {
                Image(systemName: viewModel.currentRating == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.body)
                    .foregroundStyle(viewModel.currentRating == .thumbsUp ? CircleTheme.warmAmber : .secondary)
            }
            .buttonStyle(.plain)

            // Thumbs down
            Button {
                viewModel.submitFeedback(.thumbsDown)
            } label: {
                Image(systemName: viewModel.currentRating == .thumbsDown ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.body)
                    .foregroundStyle(viewModel.currentRating == .thumbsDown ? CircleTheme.warmOrange : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .task {
            viewModel.loadExistingFeedback()
        }
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class PromptFeedbackViewModel {
    // MARK: - State

    private(set) var currentRating: PromptRating?
    private(set) var error: Error?

    // MARK: - Dependencies

    private let promptService: PromptServiceProtocol
    private let promptId: UUID
    private let circleId: UUID
    private let category: PromptCategory

    // MARK: - Init

    init(
        promptService: PromptServiceProtocol,
        promptId: UUID,
        circleId: UUID,
        category: PromptCategory
    ) {
        self.promptService = promptService
        self.promptId = promptId
        self.circleId = circleId
        self.category = category
    }

    // MARK: - Actions

    func loadExistingFeedback() {
        do {
            let feedback = try promptService.getFeedback(promptId: promptId, circleId: circleId)
            currentRating = feedback?.rating
        } catch {
            self.error = error
        }
    }

    func submitFeedback(_ rating: PromptRating) {
        // Toggle off if same rating tapped again
        if currentRating == rating {
            currentRating = nil
            return
        }

        do {
            try promptService.submitFeedback(
                promptId: promptId,
                circleId: circleId,
                rating: rating,
                category: category
            )
            currentRating = rating
        } catch {
            self.error = error
        }
    }
}

// MARK: - Preview

#Preview {
    PromptFeedbackView(
        viewModel: PromptFeedbackViewModel(
            promptService: MockPromptService(),
            promptId: UUID(),
            circleId: UUID(),
            category: .dailyMoments
        )
    )
    .padding()
}
#endif
