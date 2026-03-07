// RecentSessionsSection.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Shows last 3 sessions with a "See All" NavigationLink
struct RecentSessionsSection: View {
    let sessions: [BreathSession]
    let allDateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                Text("RECENT SESSIONS")
                    .font(.system(size: 11))
                    .tracking(1.0)
                    .foregroundStyle(AppColors.textTertiary)

                Spacer()

                if !allDateGroups.isEmpty {
                    NavigationLink {
                        AllSessionsView(dateGroups: allDateGroups, viewModel: viewModel)
                    } label: {
                        Text("See All")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.sm)

            if sessions.isEmpty {
                VStack(spacing: 4) {
                    Text("No sessions yet")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)

                    Text("Head to Breathe to start")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
            } else {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    sessionRow(session)
                    if index < sessions.count - 1 {
                        HairlineDivider()
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 22, height: 22)

                Text(viewModel.patternInitial(for: session.patternId))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.patternName(for: session.patternId))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.sessionDurationFormatted(session))
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.sessionTimeFormatted(session))
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.textTertiary)

                Text(sessionDateFormatted(session))
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.textTertiary.opacity(0.7))
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, 10)
    }

    private func sessionDateFormatted(_ session: BreathSession) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(session.startedAt) { return "Today" }
        if calendar.isDateInYesterday(session.startedAt) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: session.startedAt)
    }
}
#endif
