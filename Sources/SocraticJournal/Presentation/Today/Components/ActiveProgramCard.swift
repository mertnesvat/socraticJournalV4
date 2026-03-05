// ActiveProgramCard.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Card showing active program progress on the Today dashboard
public struct ActiveProgramCard: View {
    let program: BreathProgram
    let progress: ProgramProgress
    let todayCompleted: Bool
    let onStartSession: () -> Void

    public init(
        program: BreathProgram,
        progress: ProgramProgress,
        todayCompleted: Bool,
        onStartSession: @escaping () -> Void
    ) {
        self.program = program
        self.progress = progress
        self.todayCompleted = todayCompleted
        self.onStartSession = onStartSession
    }

    /// The current day's schedule entry
    private var currentDayEntry: ProgramDay? {
        program.days.first { $0.dayNumber == progress.currentDay }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Header
            Text("ACTIVE PROGRAM")
                .font(.system(size: 11))
                .tracking(1.2)
                .foregroundStyle(AppColors.textTertiary)

            // Program name
            Text(program.title)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            // Day progress text
            Text("Day \(progress.currentDay) of \(progress.totalDays)")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.surface)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.accent)
                        .frame(width: geo.size.width * progress.progressFraction, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.vertical, 2)

            HairlineDivider()
                .padding(.vertical, 4)

            if todayCompleted {
                // Day complete state
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.accent)

                    Text("Day \(max(progress.currentDay - 1, 1)) Complete")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.accent)
                }
                .padding(.vertical, 4)
            } else if let dayEntry = currentDayEntry {
                // Today's practice info
                VStack(alignment: .leading, spacing: 6) {
                    Text("TODAY'S PRACTICE")
                        .font(.system(size: 10))
                        .tracking(0.8)
                        .foregroundStyle(AppColors.textTertiary)

                    HStack(spacing: 6) {
                        Text(BreathProgram.patternName(for: dayEntry.patternId))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)

                        Text("\u{00B7}")
                            .foregroundStyle(AppColors.textTertiary)

                        Text("\(dayEntry.durationMinutes) min")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Text(dayEntry.focusNote)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                // Start session button
                Button(action: onStartSession) {
                    Text("Start Today's Session")
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.accent)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(AppSpacing.cardPadding)
    }
}

#Preview {
    VStack(spacing: 0) {
        ActiveProgramCard(
            program: .nasalBreathingReset,
            progress: ProgramProgress(
                programId: "calm-foundation",
                currentDay: 3,
                completedDays: [1, 2],
                totalDays: 7
            ),
            todayCompleted: false,
            onStartSession: {}
        )

        HairlineDivider()

        ActiveProgramCard(
            program: .nasalBreathingReset,
            progress: ProgramProgress(
                programId: "calm-foundation",
                currentDay: 4,
                completedDays: [1, 2, 3],
                totalDays: 7
            ),
            todayCompleted: true,
            onStartSession: {}
        )
    }
    .background(AppColors.background)
}
#endif
