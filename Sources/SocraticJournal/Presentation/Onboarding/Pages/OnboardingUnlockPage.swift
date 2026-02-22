// OnboardingUnlockPage.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen 2: "Answer first, then listen" — teal background with bold left-aligned typography.
/// Subtle lock icon as a detail, not the hero. Typography IS the visual.
public struct OnboardingUnlockPage: View {
    // MARK: - Animation State

    @State private var isUnlocked: Bool = false

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Teal background
            AppColors.cardTeal
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                    .frame(height: AppSpacing.heroTopPadding)

                // Subtle lock icon — NOT the hero
                Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                    .padding(.bottom, 4)

                // Massive headline
                Text("Answer first,\nthen listen")
                    .font(AppTypography.displayLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(2)

                // Body copy
                Text("Record your take on today's question. Then unlock what everyone else said.")
                    .font(AppTypography.bodyLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    isUnlocked = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingUnlockPage()
}
#endif
