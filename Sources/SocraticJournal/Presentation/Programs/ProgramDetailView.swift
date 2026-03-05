// ProgramDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Detailed view of a breath program with day-by-day schedule and progress
public struct ProgramDetailView: View {
    @State private var viewModel: ProgramDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(
        program: BreathProgram,
        progressRepository: ProgramProgressRepositoryProtocol
    ) {
        _viewModel = State(initialValue: ProgramDetailViewModel(
            program: program,
            progressRepository: progressRepository
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                HairlineDivider()

                // Progress overview (if active)
                if viewModel.isActiveProgram, let progress = viewModel.progress {
                    progressOverview(progress)
                    HairlineDivider()
                }

                // Description
                descriptionSection
                HairlineDivider()

                // Day-by-day schedule
                dayScheduleSection
                HairlineDivider()

                // Action buttons
                actionSection

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
        .alert("Abandon Program", isPresented: $viewModel.showAbandonConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Abandon", role: .destructive) {
                Task { await viewModel.abandonProgram() }
            }
        } message: {
            Text("Your progress in \(viewModel.program.title) will be lost. This cannot be undone.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: viewModel.program.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 44, height: 44)
                    .background(AppColors.accentLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.program.title)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                        .tracking(-0.3)

                    Text(viewModel.program.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppSpacing.md) {
                Label("\(viewModel.program.durationDays) days", systemImage: "calendar")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)

                let totalMinutes = viewModel.program.days.reduce(0) { $0 + $1.durationMinutes }
                Label("\(totalMinutes) min total", systemImage: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.cardPadding)
    }

    // MARK: - Progress Overview

    private func progressOverview(_ progress: ProgramProgress) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("PROGRESS")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Day \(progress.currentDay) of \(progress.totalDays)")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("\(progress.completedDays.count) days completed")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                GeometricRing(
                    progress: progress.progressFraction,
                    size: 44,
                    lineWidth: 5
                )
            }

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
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.cardPadding)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("ABOUT")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)

            Text(viewModel.program.description)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.cardPadding)
    }

    // MARK: - Day Schedule

    private var dayScheduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SCHEDULE")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.cardPadding)
                .padding(.bottom, AppSpacing.sm)

            ForEach(viewModel.program.days) { day in
                dayRow(day)
                if day.id != viewModel.program.days.last?.id {
                    HairlineDivider()
                        .padding(.leading, AppSpacing.screenPadding + 36)
                }
            }
        }
    }

    private func dayRow(_ day: ProgramDay) -> some View {
        let isCompleted = viewModel.isDayCompleted(day.dayNumber)
        let isCurrent = viewModel.isCurrentDay(day.dayNumber)

        return HStack(spacing: AppSpacing.sm) {
            // Day number / status indicator
            ZStack {
                Circle()
                    .fill(isCompleted ? AppColors.accent : (isCurrent ? AppColors.accentLight : AppColors.surface))
                    .frame(width: 28, height: 28)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(day.id)")
                        .font(.system(size: 12, weight: isCurrent ? .bold : .regular))
                        .foregroundStyle(isCurrent ? AppColors.accent : AppColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Day \(day.id)")
                        .font(.system(size: 13, weight: isCurrent ? .bold : .semibold))
                        .foregroundStyle(isCurrent ? AppColors.accent : AppColors.textPrimary)

                    if isCurrent {
                        Text("TODAY")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(0.6)
                            .foregroundStyle(AppColors.accent)
                    }
                }

                Text("\(BreathProgram.patternName(for: day.patternId)) \u{00B7} \(day.durationMinutes) min")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)

                Text(day.focusNote)
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
        .background(isCurrent ? AppColors.accentLight.opacity(0.3) : Color.clear)
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: AppSpacing.sm) {
            if viewModel.isActiveProgram {
                // Abandon button
                Button {
                    viewModel.showAbandonConfirmation = true
                } label: {
                    Text("Abandon Program")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.accent2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.accent2.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            } else {
                // Start Program button
                Button {
                    Task { await viewModel.startProgram() }
                } label: {
                    Text(viewModel.hasDifferentActiveProgram ? "Replace Active Program" : "Start Program")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.accent)
                        )
                }
                .buttonStyle(.plain)

                if viewModel.hasDifferentActiveProgram {
                    Text("This will replace your current active program")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.cardPadding)
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(
            program: .nasalBreathingReset,
            progressRepository: UserDefaultsProgramProgressRepository()
        )
    }
}
#endif
