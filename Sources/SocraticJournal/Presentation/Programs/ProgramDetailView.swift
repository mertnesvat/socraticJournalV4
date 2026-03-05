// ProgramDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Detail view for a single breathing program showing description and daily schedule
struct ProgramDetailView: View {
    let program: BreathProgram

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                HairlineDivider()

                // Description
                descriptionSection
                HairlineDivider()

                // Begin button
                beginButtonSection

                // Daily schedule
                dailyScheduleSection
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(program.title)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            // Tag + duration + difficulty row
            HStack(spacing: 8) {
                Text(program.difficultyLabel.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(hex: program.tagColorHex))
                    )

                Text("\(program.durationDays) days")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)

                Text("\u{00B7}")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)

                Text(program.difficultyLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.cardPadding)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        Text(program.description)
            .font(.system(size: 13))
            .foregroundStyle(AppColors.textSecondary)
            .lineSpacing(13 * 0.75) // line-height 1.75 approximation
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Begin Button

    private var beginButtonSection: some View {
        Button {
            // Functionality added in Feature 10
        } label: {
            Text("BEGIN PROGRAM")
                .font(.system(size: 12, weight: .bold, design: .serif))
                .tracking(1.2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(AppColors.accent)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.cardPadding)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Daily Schedule

    private var dailyScheduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Text("DAILY SCHEDULE")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

            HairlineDivider()

            // Day rows
            ForEach(program.days) { day in
                dayRow(day)
                HairlineDivider()
            }
        }
    }

    private func dayRow(_ day: ProgramDay) -> some View {
        HStack(spacing: 14) {
            // Circle indicator (gray border, not started)
            Circle()
                .stroke(AppColors.border, lineWidth: 1.5)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                // Day number + title
                Text("Day \(day.dayNumber): \(day.title)")
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                // Pattern + duration
                Text("\(BreathProgram.patternName(for: day.patternId)) \u{00B7} \(day.durationMinutes) min")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.cardPadding)
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(program: .nasalBreathingReset)
    }
}
#endif
