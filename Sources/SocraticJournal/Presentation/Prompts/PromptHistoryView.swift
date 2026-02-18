// PromptHistoryView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the history of past prompts assigned to a circle,
/// grouped by week with category badges and dates.
struct PromptHistoryView: View {
    @State private var viewModel: PromptHistoryViewModel

    init(viewModel: PromptHistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.groupedPrompts.isEmpty {
                ProgressView("Loading history...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.groupedPrompts.isEmpty {
                ContentUnavailableView(
                    "No Prompts Yet",
                    systemImage: "text.bubble",
                    description: Text("Past prompts will appear here once your circle gets started.")
                )
            } else {
                promptList
            }
        }
        .navigationTitle("Prompt History")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadHistory() }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Prompt List

    private var promptList: some View {
        List {
            ForEach(viewModel.groupedPrompts, id: \.title) { group in
                Section(group.title) {
                    ForEach(group.prompts) { prompt in
                        promptRow(prompt)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Row

    private func promptRow(_ prompt: Prompt) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: prompt.category.iconName)
                        .font(.caption2)
                    Text(prompt.category.displayName)
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(CircleTheme.warmAmber)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    CircleTheme.warmAmber.opacity(0.12),
                    in: Capsule()
                )

                Spacer()

                // Depth dots
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { level in
                        SwiftUI.Circle()
                            .fill(level <= prompt.depth
                                  ? CircleTheme.warmAmber
                                  : CircleTheme.warmAmber.opacity(0.2))
                            .frame(width: 4, height: 4)
                    }
                }
            }

            Text(prompt.text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            if let date = prompt.dateAssigned {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - PromptHistoryViewModel

/// ViewModel for the prompt history screen.
/// Groups past prompts by week for easy browsing.
@Observable
@MainActor
public final class PromptHistoryViewModel {
    // MARK: - Types

    struct PromptGroup: Equatable {
        let title: String
        let prompts: [Prompt]

        static func == (lhs: PromptGroup, rhs: PromptGroup) -> Bool {
            lhs.title == rhs.title && lhs.prompts.map(\.id) == rhs.prompts.map(\.id)
        }
    }

    // MARK: - State

    private(set) var groupedPrompts: [PromptGroup] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Dependencies

    private let promptService: PromptServiceProtocol
    private let circleId: UUID

    // MARK: - Init

    public init(promptService: PromptServiceProtocol, circleId: UUID) {
        self.promptService = promptService
        self.circleId = circleId
    }

    // MARK: - Actions

    func loadHistory() async {
        isLoading = true
        error = nil
        do {
            let history = try await promptService.getPromptHistory(for: circleId)
            groupedPrompts = groupByWeek(history)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func clearError() {
        error = nil
    }

    // MARK: - Grouping

    private func groupByWeek(_ prompts: [Prompt]) -> [PromptGroup] {
        let calendar = Calendar.current
        var groups: [String: [Prompt]] = [:]
        var groupOrder: [String] = []

        for prompt in prompts {
            guard let date = prompt.dateAssigned else { continue }

            let weekTitle: String
            if calendar.isDateInToday(date) {
                weekTitle = "Today"
            } else if calendar.isDateInYesterday(date) {
                weekTitle = "Yesterday"
            } else {
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
                let weekFormatter = DateFormatter()
                weekFormatter.dateFormat = "MMM d"
                let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
                weekTitle = "Week of \(weekFormatter.string(from: startOfWeek)) - \(weekFormatter.string(from: endOfWeek))"
            }

            if groups[weekTitle] == nil {
                groupOrder.append(weekTitle)
            }
            groups[weekTitle, default: []].append(prompt)
        }

        return groupOrder.map { title in
            PromptGroup(title: title, prompts: groups[title] ?? [])
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PromptHistoryView(
            viewModel: PromptHistoryViewModel(
                promptService: MockPromptService(),
                circleId: UUID()
            )
        )
    }
}
#endif
