// SessionHistoryList.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Date-grouped session history list (shows 3 most recent groups, with "See All" navigation)
struct SessionHistoryList: View {
    let dateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel

    private var displayedGroups: [ProgressViewModel.DateGroup] {
        Array(dateGroups.prefix(3))
    }

    private var hasMore: Bool {
        dateGroups.count > 3
    }

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
                ForEach(displayedGroups) { group in
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

                    if group.id != displayedGroups.last?.id || hasMore {
                        HairlineDivider()
                    }
                }

                if hasMore {
                    NavigationLink(destination: AllSessionsView(dateGroups: dateGroups, viewModel: viewModel)) {
                        HStack {
                            Text("See All Sessions")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.accent)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
    }

    func sessionRow(_ session: BreathSession) -> some View {
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
