// QuestionCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The hero card displaying today's daily question — editorial left-aligned, massive type on cream
public struct QuestionCard: View {
    let question: DailyQuestion

    @State private var isVisible: Bool = false

    public init(question: DailyQuestion) {
        self.question = question
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category badge — ALL-CAPS with tracking, category color
            categoryBadge

            // Question text — the hero element, MASSIVE left-aligned
            Text(question.text)
                .font(AppTypography.displayMedium)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Level intensity dots — simplified small circles
            levelIndicator
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }

    // MARK: - Subviews

    private var categoryBadge: some View {
        Text(question.category.displayName.uppercased())
            .font(AppTypography.sectionHeader)
            .tracking(AppTypography.sectionHeaderTracking)
            .foregroundStyle(categoryColor)
    }

    private var levelIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1...4, id: \.self) { level in
                Circle()
                    .fill(level <= question.level ? categoryColor : AppColors.border)
                    .frame(width: 8, height: 8)
            }
        }
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch question.category {
        case .iceBreaker:
            return AppColors.iceBreaker
        case .gettingSpicy:
            return AppColors.gettingSpicy
        case .deepDive:
            return AppColors.deepDive
        case .debateTrigger:
            return AppColors.debateTrigger
        }
    }
}

#Preview {
    QuestionCard(
        question: DailyQuestion(
            id: "preview_1",
            text: "Could you forgive cheating if everything else was perfect?",
            category: .debateTrigger,
            level: 4,
            createdAt: Date(),
            globalResponseCount: 1203,
            disagreementRatio: 0.81
        )
    )
    .padding(.horizontal, AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
