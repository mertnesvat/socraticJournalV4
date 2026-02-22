// OnboardingFriendsPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 4: "Add your crew" page.
/// Shows placeholder friend circles with + icons and action buttons.
public struct OnboardingFriendsPage: View {
    // MARK: - Callbacks

    let onFindFriends: () -> Void
    let onSkipForNow: () -> Void

    // MARK: - Animation State

    @State private var circlesVisible: Bool = false

    // MARK: - Init

    public init(
        onFindFriends: @escaping () -> Void,
        onSkipForNow: @escaping () -> Void
    ) {
        self.onFindFriends = onFindFriends
        self.onSkipForNow = onSkipForNow
    }

    // MARK: - Body

    public var body: some View {
        OnboardingPageView(
            title: "Add your crew",
            subtitle: "Add 3 friends to get started"
        ) {
            friendCircles
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                circlesVisible = true
            }
        }
    }

    // MARK: - Friend Circles

    private var friendCircles: some View {
        ZStack {
            // Three overlapping circles with + icons
            HStack(spacing: -16) {
                friendPlaceholder(color: .purple, offset: 0)
                friendPlaceholder(color: .blue, offset: 1)
                friendPlaceholder(color: .cyan, offset: 2)
            }
            .scaleEffect(circlesVisible ? 1 : 0.5)
            .opacity(circlesVisible ? 1 : 0)
        }
    }

    private func friendPlaceholder(color: Color, offset: Int) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 80, height: 80)

            Circle()
                .strokeBorder(color.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .frame(width: 80, height: 80)

            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(color)
        }
        .zIndex(Double(3 - offset))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            OnboardingFriendsPage(
                onFindFriends: { print("Find friends") },
                onSkipForNow: { print("Skip") }
            )

            // Simulated buttons
            VStack(spacing: 12) {
                Button("Find Friends") {}
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button("Skip for now") {}
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
#endif
