// SessionHistoryList.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Date-grouped session history list
struct SessionHistoryList: View {
    let dateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RECENT SESSIONS")
                .font(.system(size: 11))
                .tracking(1.0)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.sm)

            if dateGroups.isEmpty {
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
                ForEach(dateGroups) { group in
                    // Date header
                    Text(group.label)
                        .font(.system(size: 11))
                        .tracking(1.0)
                        .foregroundStyle(AppColors.textTertiary)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xs)

                    ForEach(group.sessions) { session in
                        sessionRow(session)

                        if session.id != group.sessions.last?.id {
                            HairlineDivider()
                        }
                    }

                    if group.id != dateGroups.last?.id {
                        HairlineDivider()
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
    }

    private func sessionRow(_ session: BreathSession) -> some View {
        HStack(spacing: 14) {
            // Pattern initial circle
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

            Text(viewModel.sessionTimeFormatted(session))
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, 10)
    }
}
#endif
