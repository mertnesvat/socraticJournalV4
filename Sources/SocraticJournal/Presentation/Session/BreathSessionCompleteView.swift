// BreathSessionCompleteView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Completion screen shown after a breath session finishes.
/// Displays session stats, a random affirming message, and saves the session.
struct BreathSessionCompleteView: View {
    let session: BreathSession
    let repository: BreathSessionRepositoryProtocol
    let onDismiss: () -> Void

    @State private var streak: Int = 0
    @State private var hasSaved = false
    @State private var affirmation: String = ""
    @State private var isLoading = true
    @State private var error: Error?

    private static let affirmations: [String] = [
        "Your nervous system thanks you.",
        "Each breath builds resilience.",
        "Presence is a practice. You showed up.",
        "Stillness is strength.",
        "A calmer you ripples outward.",
        "You just invested in yourself.",
        "The body remembers this kindness.",
        "Consistency compounds. Well done.",
        "You chose peace over noise.",
        "This is what self-care looks like."
    ]

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if isLoading {
                ProgressView("Saving...")
                    .foregroundStyle(AppColors.textSecondary)
            } else if let error {
                errorContent(error)
            } else {
                completionContent
            }
        }
        .task {
            await saveAndLoad()
        }
    }

    // MARK: - Completion Content

    private var completionContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Checkmark
            Image(systemName: "checkmark.circle")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(AppColors.accent)
                .padding(.bottom, AppSpacing.lg)

            // Title
            Text("Session Complete")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, AppSpacing.xs)

            // Technique name
            Text(session.techniqueName)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.bottom, AppSpacing.sectionGap)

            // Stats
            HStack(spacing: AppSpacing.xl) {
                statColumn(value: formattedDuration, label: "Duration")
                statColumn(value: "\(session.cyclesCompleted)", label: "Breaths")
                statColumn(value: "\(streak)", label: streak == 1 ? "Day" : "Days")
            }
            .padding(.bottom, AppSpacing.sectionGap)

            // Affirmation
            Text(affirmation)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xxl)

            Spacer()

            // Done button
            AccentPillButton("Done") {
                onDismiss()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    // MARK: - Error Content

    private func errorContent(_ error: Error) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textTertiary)

            Text("Could not save session")
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            Text(error.localizedDescription)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            Button("Try Again") {
                Task { await saveAndLoad() }
            }
            .font(AppTypography.bodyBold)
            .foregroundStyle(AppColors.accent)
            .padding(.top, AppSpacing.xs)

            Button("Dismiss") {
                onDismiss()
            }
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.top, AppSpacing.xxs)
        }
    }

    // MARK: - Stat Column

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.statSmall)
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - Data Loading

    private func saveAndLoad() async {
        isLoading = true
        error = nil

        // Pick a random affirmation
        affirmation = Self.affirmations.randomElement() ?? Self.affirmations[0]

        do {
            // Save the session
            if !hasSaved {
                try await repository.saveSession(session)
                hasSaved = true
            }

            // Fetch current streak
            streak = try await repository.getCurrentStreak()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let totalSeconds = Int(session.actualDuration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

#Preview {
    BreathSessionCompleteView(
        session: BreathSession(
            techniqueId: "resonance",
            techniqueName: "Resonance Breathing",
            startedAt: Date().addingTimeInterval(-300),
            completedAt: Date(),
            targetDuration: 300,
            cyclesCompleted: 27
        ),
        repository: UserDefaultsBreathSessionRepository(),
        onDismiss: {}
    )
}
#endif
