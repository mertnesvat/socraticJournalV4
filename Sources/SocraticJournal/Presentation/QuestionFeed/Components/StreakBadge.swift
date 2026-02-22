// StreakBadge.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Displays the user's current question streak with a fire icon in a capsule badge
public struct StreakBadge: View {
    let streak: QuestionStreak

    @State private var animateBounce: Bool = false

    public init(streak: QuestionStreak) {
        self.streak = streak
    }

    public var body: some View {
        HStack(spacing: 6) {
            Text("\u{1F525}")
                .font(isHighStreak ? .title2 : .title3)

            Text("\(streak.currentStreak)")
                .font(.system(size: isHighStreak ? 20 : 17, weight: .bold, design: .rounded))
                .foregroundStyle(streakTextColor)
                .scaleEffect(animateBounce ? 1.15 : 1.0)

            Text("day streak")
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isHighStreak ? Color.yellow.opacity(0.4) : Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(
                .interpolatingSpring(stiffness: 300, damping: 8)
                .delay(0.3)
            ) {
                animateBounce = true
            }
            // Reset after bounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 8)) {
                    animateBounce = false
                }
            }
        }
    }

    // MARK: - Helpers

    /// Streaks of 7 or more get a gold treatment
    private var isHighStreak: Bool {
        streak.currentStreak >= 7
    }

    private var streakTextColor: Color {
        isHighStreak ? Color.yellow : Color.white
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            StreakBadge(streak: QuestionStreak(
                userId: "preview",
                currentStreak: 3,
                longestStreak: 5
            ))

            StreakBadge(streak: QuestionStreak(
                userId: "preview",
                currentStreak: 12,
                longestStreak: 20
            ))
        }
    }
}
#endif
