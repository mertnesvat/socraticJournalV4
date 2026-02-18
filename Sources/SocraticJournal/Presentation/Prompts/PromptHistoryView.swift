// PromptHistoryView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Shows a list of past daily prompts for a circle with response counts.
/// Tapping a row navigates to the detail view showing the prompt and its voice notes.
struct PromptHistoryView: View {
    @State private var viewModel: DailyPromptViewModel
    let circleId: UUID
    let circleMemberCount: Int

    init(viewModel: DailyPromptViewModel, circleId: UUID, circleMemberCount: Int) {
        _viewModel = State(initialValue: viewModel)
        self.circleId = circleId
        self.circleMemberCount = circleMemberCount
    }

    var body: some View {
        content
            .navigationTitle("Prompt History")
            .task {
                await viewModel.loadHistory(circleId: circleId)
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.promptHistory.isEmpty {
            ContentUnavailableView(
                "No Prompts Yet",
                systemImage: "text.bubble",
                description: Text("Daily prompts will appear here once they start.")
            )
        } else {
            List(viewModel.promptHistory) { prompt in
                NavigationLink(value: prompt.id) {
                    PromptHistoryRow(
                        prompt: prompt,
                        memberCount: circleMemberCount
                    )
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Prompt History Row

struct PromptHistoryRow: View {
    let prompt: DailyPrompt
    let memberCount: Int

    private var respondedCount: Int {
        prompt.respondedUserIds.count
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(prompt.generatedAt) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(prompt.generatedAt) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: prompt.generatedAt)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                ResponseBadge(
                    responded: respondedCount,
                    total: memberCount
                )
            }

            Text(prompt.promptText)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Response Badge

struct ResponseBadge: View {
    let responded: Int
    let total: Int

    private var allResponded: Bool {
        responded >= total && total > 0
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: allResponded ? "checkmark.circle.fill" : "person.2")
                .font(.caption2)

            Text("\(responded)/\(total)")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(allResponded ? .green : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(allResponded ? Color.green.opacity(0.12) : Color.secondary.opacity(0.12))
        )
    }
}
#endif
