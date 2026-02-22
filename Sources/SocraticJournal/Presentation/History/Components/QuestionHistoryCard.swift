// QuestionHistoryCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Compact card for a single history item showing question, date, category, status, and friend count
public struct QuestionHistoryCard: View {
    let question: DailyQuestion
    let isAnswered: Bool
    let friendCount: Int

    @State private var isVisible: Bool = false

    public init(question: DailyQuestion, isAnswered: Bool, friendCount: Int) {
        self.question = question
        self.isAnswered = isAnswered
        self.friendCount = friendCount
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Category color indicator -- left border strip
            categoryStrip

            // Main card content
            HStack(spacing: 12) {
                // Left: question text and friend count
                VStack(alignment: .leading, spacing: 6) {
                    Text(question.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        // Status chip
                        statusChip

                        // Friend count
                        if friendCount > 0 {
                            Label("\(friendCount) friends answered", systemImage: "person.2")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 8)

                // Right: date and chevron
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                isVisible = true
            }
        }
    }

    // MARK: - Subviews

    /// Thin vertical color strip on the left edge indicating question category
    private var categoryStrip: some View {
        Rectangle()
            .fill(categoryColor)
            .frame(width: 4)
    }

    /// Answered/Skipped status chip
    private var statusChip: some View {
        Text(isAnswered ? "Answered" : "Skipped")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(isAnswered ? Color.green : Color.gray)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(isAnswered
                        ? Color.green.opacity(0.15)
                        : Color.gray.opacity(0.15)
                    )
            )
    }

    // MARK: - Helpers

    /// Category-specific accent color matching QuestionCard conventions
    private var categoryColor: Color {
        switch question.category {
        case .iceBreaker:
            return .blue
        case .gettingSpicy:
            return .orange
        case .deepDive:
            return .purple
        case .debateTrigger:
            return .red
        }
    }

    /// Formats the question date as "Today", "Yesterday", or abbreviated month+day
    private var formattedDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(question.createdAt) {
            return "Today"
        } else if calendar.isDateInYesterday(question.createdAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: question.createdAt)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        QuestionHistoryCard(
            question: DailyQuestion(
                id: "preview_1",
                text: "Could you forgive cheating if everything else was perfect?",
                category: .debateTrigger,
                level: 4,
                createdAt: Date(),
                globalResponseCount: 1203,
                disagreementRatio: 0.81
            ),
            isAnswered: true,
            friendCount: 5
        )

        QuestionHistoryCard(
            question: DailyQuestion(
                id: "preview_2",
                text: "What's something you pretend to like because everyone around you does?",
                category: .iceBreaker,
                level: 1,
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                globalResponseCount: 1987,
                disagreementRatio: 0.48
            ),
            isAnswered: false,
            friendCount: 3
        )

        QuestionHistoryCard(
            question: DailyQuestion(
                id: "preview_3",
                text: "What's the most selfish thing you've done that you'd do again?",
                category: .deepDive,
                level: 3,
                createdAt: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                globalResponseCount: 1876,
                disagreementRatio: 0.45
            ),
            isAnswered: true,
            friendCount: 7
        )
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
    .preferredColorScheme(.dark)
}
#endif
