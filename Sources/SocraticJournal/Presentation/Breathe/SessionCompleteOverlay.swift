// SessionCompleteOverlay.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Full-screen overlay celebrating a completed breath session
public struct SessionCompleteOverlay: View {
    let session: BreathSession
    let pattern: BreathPattern
    let previousDailyTotal: Double
    let dailyGoalMinutes: Int
    let settingsRepository: SettingsRepositoryProtocol?
    let healthKitService: HealthKitServiceProtocol?
    let onDismiss: () -> Void

    @State private var showCheckmark = false
    @State private var autoDismissTask: Task<Void, Never>?
    @State private var showHealthKitPrompt = false

    private var sessionMinutes: Double {
        session.totalDuration / 60.0
    }

    private var newDailyTotal: Double {
        previousDailyTotal + sessionMinutes
    }

    private var goalCrossed: Bool {
        previousDailyTotal < Double(dailyGoalMinutes) &&
        newDailyTotal >= Double(dailyGoalMinutes)
    }

    private var goalProgress: Double {
        min(newDailyTotal / Double(dailyGoalMinutes), 1.0)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top section
                topSection
                    .padding(.top, 80)
                    .padding(.bottom, AppSpacing.lg)

                HairlineDivider()
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Stats grid
                SessionStatsGrid(
                    durationFormatted: SessionStatsGrid.formatDuration(session.totalDuration),
                    cycleCount: session.cyclesCompleted
                )
                .padding(.vertical, AppSpacing.lg)

                // Pattern name
                Text(pattern.name)
                    .font(.system(size: 15, design: .serif))
                    .italic()
                    .foregroundStyle(AppColors.accent)

                Text("Best for: \(pattern.bestFor)")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.top, 4)
                    .padding(.bottom, AppSpacing.lg)

                HairlineDivider()
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Daily progress
                dailyProgressSection
                    .padding(.vertical, AppSpacing.lg)

                HairlineDivider()
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Insight card
                InsightCard(patternId: pattern.id)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.lg)

                // HealthKit prompt (one-time)
                healthKitPromptSection

                // Done button
                Button(action: dismiss) {
                    Text("DONE")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1)
                        .foregroundStyle(AppColors.buttonPrimaryForeground)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.buttonPrimaryBackground)
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .background(
            ZStack {
                AppColors.background
                RadialGradient(
                    colors: [AppColors.accent.opacity(0.05), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                showCheckmark = true
            }
            autoDismissTask = Task {
                try? await Task.sleep(for: .seconds(30))
                dismiss()
            }
            Task { await checkHealthKitPrompt() }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }

    // MARK: - HealthKit Prompt

    @ViewBuilder
    var healthKitPromptSection: some View {
        if showHealthKitPrompt, let hkService = healthKitService {
            VStack(spacing: 8) {
                HairlineDivider()
                    .padding(.horizontal, AppSpacing.screenPadding)

                HStack(spacing: 12) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Save to Apple Health?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Log sessions as Mindful Minutes")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button("Allow") {
                            Task {
                                try? await hkService.requestAuthorization()
                                await markHealthKitPromptSeen()
                                showHealthKitPrompt = false
                            }
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.accent)

                        Button("Not Now") {
                            Task {
                                await markHealthKitPromptSeen()
                                showHealthKitPrompt = false
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.sm)
            }
        }
    }

    private func checkHealthKitPrompt() async {
        guard let hkService = healthKitService,
              let settingsRepo = settingsRepository,
              hkService.isHealthDataAvailable() else { return }
        guard let settings = try? await settingsRepo.getSettings(),
              !settings.hasSeenHealthKitPrompt else { return }
        showHealthKitPrompt = true
    }

    private func markHealthKitPromptSeen() async {
        guard let settingsRepo = settingsRepository,
              var settings = try? await settingsRepo.getSettings() else { return }
        settings.hasSeenHealthKitPrompt = true
        try? await settingsRepo.saveSettings(settings)
    }

    // MARK: - Top Section

    private var topSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 24, height: 24)

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(showCheckmark ? 1.0 : 0.6)

            Text("SESSION COMPLETE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.accent)
        }
    }

    // MARK: - Daily Progress

    private var dailyProgressSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("TODAY'S PROGRESS")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            GeometricRing(
                progress: goalProgress,
                size: 56,
                lineWidth: 7,
                accentColor: goalCrossed ? AppColors.accent : AppColors.accent
            )

            Text(String(format: "%.1f / %d min", newDailyTotal, dailyGoalMinutes))
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            if goalCrossed {
                Text("Goal reached!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.accent)
            } else if newDailyTotal >= Double(dailyGoalMinutes) {
                Text("Goal reached!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.accent)
            } else {
                let remaining = Double(dailyGoalMinutes) - newDailyTotal
                Text(String(format: "%.1f min to go", remaining))
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private func dismiss() {
        autoDismissTask?.cancel()
        onDismiss()
    }
}
#endif
