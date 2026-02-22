// QuestionCardView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Reusable card displaying a DailyQuestion with large text and a category badge pill
public struct QuestionCardView: View {
    public let question: DailyQuestion
    public let hasAnswered: Bool

    public init(question: DailyQuestion, hasAnswered: Bool = false) {
        self.question = question
        self.hasAnswered = hasAnswered
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Category badge
            HStack {
                categoryBadge
                Spacer()
                if hasAnswered {
                    answeredBadge
                }
            }

            // Question text
            Text(question.text)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            // Level indicator
            Text(question.level.displayName)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(categoryColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private var categoryBadge: some View {
        Text(question.category.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(categoryColor)
            )
    }

    private var answeredBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
            Text("Answered")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.green)
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch question.category.colorHint {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .accentColor
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        QuestionCardView(
            question: DailyQuestion(
                text: "What is something you believed as a child that you no longer believe?",
                category: .deep,
                level: .level2
            )
        )

        QuestionCardView(
            question: DailyQuestion(
                text: "If you could have dinner with anyone, who would it be?",
                category: .iceBreaker,
                level: .level1
            ),
            hasAnswered: true
        )
    }
    .padding()
}
#endif
