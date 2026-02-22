// QuestionCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// The hero card displaying today's daily question with category badge and intensity dots
public struct QuestionCard: View {
    let question: DailyQuestion

    @State private var isVisible: Bool = false

    public init(question: DailyQuestion) {
        self.question = question
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Category badge
            categoryBadge

            // Question text -- the hero element
            Text(question.text)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Level intensity dots
            levelIndicator
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }

    // MARK: - Subviews

    private var categoryBadge: some View {
        Text(question.category.displayName.uppercased())
            .font(.system(size: 12, weight: .heavy, design: .default))
            .tracking(1.2)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(categoryColor)
            )
    }

    private var levelIndicator: some View {
        HStack(spacing: 6) {
            ForEach(1...4, id: \.self) { level in
                Circle()
                    .fill(level <= question.level ? categoryColor : Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
    }

    // MARK: - Helpers

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
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

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
    }
}
#endif
