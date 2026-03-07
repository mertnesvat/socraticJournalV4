// SessionHistoryList.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

private let kCollapsedSessionLimit = 3

/// Date-grouped session history list.
/// When `showAll` is false (default), shows the last 3 sessions with a "See All" NavigationLink.
struct SessionHistoryList: View {
    let dateGroups: [ProgressViewModel.DateGroup]
    let viewModel: ProgressViewModel
    var showAll: Bool = false

    // Flatten all sessions across groups, newest first
    private var allSessions: [BreathSession] {
        dateGroups.flatMap { $0.sessions }
    }

    // Date groups limited to the last 3 individual sessions
    private var collapsedGroups: [ProgressViewModel.DateGroup] {
        let limited = Array(allSessions.prefix(kCollapsedSessionLimit))
        return regroupSessions(limited)
    }

    private var hasMore: Bool {
        allSessions.count > kCollapsedSessionLimit
    }

    private var visibleGroups: [ProgressViewModel.DateGroup] {
        showAll ? dateGroups : collapsedGroups
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
                ForEach(visibleGroups) { group in
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

                    if group.id != visibleGroups.last?.id {
                        HairlineDivider()
                    }
                }

                // "See All" button when collapsed and there are more sessions
                if !showAll && hasMore {
                    HairlineDivider()
                    NavigationLink(destination: AllSessionsView(dateGroups: dateGroups, viewModel: viewModel)) {
                        HStack {
                            Text("SEE ALL SESSIONS")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(1.0)
                                .foregroundStyle(AppColors.accent)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(AppColors.accent)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, 12)
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

    /// Regroups a flat list of sessions back into DateGroups (preserving existing group labels).
    private func regroupSessions(_ sessions: [BreathSession]) -> [ProgressViewModel.DateGroup] {
        var result: [ProgressViewModel.DateGroup] = []
        var processed = Set<String>()

        for group in dateGroups {
            let matching = group.sessions.filter { session in
                sessions.contains(where: { $0.id == session.id }) && !processed.contains(session.id)
            }
            if !matching.isEmpty {
                matching.forEach { processed.insert($0.id) }
                result.append(ProgressViewModel.DateGroup(
                    id: group.id,
                    label: group.label,
                    sessions: matching
                ))
            }
        }
        return result
    }
}
#endif
