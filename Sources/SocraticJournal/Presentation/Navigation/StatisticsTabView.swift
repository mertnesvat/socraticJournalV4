// StatisticsTabView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Statistics view adapted for tab navigation (no dismiss button)
/// Uses the same StatisticsViewModel and maintains all statistics functionality
public struct StatisticsTabView: View {
    @State private var viewModel: StatisticsViewModel

    public init(viewModel: StatisticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Statistics")
                .navigationBarTitleDisplayMode(.large)
                .task { await viewModel.loadData() }
                .refreshable { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.sessions.isEmpty {
            loadingView
        } else if let error = viewModel.error, viewModel.sessions.isEmpty {
            errorView(error)
        } else if viewModel.stats.totalEntries == 0 {
            emptyStateView
        } else {
            mainContent
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading statistics...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Unable to Load",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Statistics Yet",
            systemImage: "chart.bar",
            description: Text("Complete your first journal session to start tracking your progress.")
        )
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Streak Progress Section
                StreakProgressView(
                    currentStreak: viewModel.stats.currentStreak,
                    longestStreak: viewModel.stats.longestStreak,
                    nextMilestone: viewModel.nextStreakMilestone,
                    progress: viewModel.streakProgress
                )

                // Quick Stats Overview
                quickStatsSection

                // Weekly Trend Chart
                TrendChartView(data: viewModel.trendData)

                // Weekly Comparison
                WeeklyComparisonView(
                    thisWeekCount: viewModel.thisWeekSessionCount,
                    lastWeekCount: viewModel.lastWeekSessionCount,
                    thisWeekAverage: viewModel.thisWeekAverageScore,
                    lastWeekAverage: viewModel.lastWeekAverageScore,
                    percentChange: viewModel.weekOverWeekChange
                )

                // Milestones Section
                milestonesSection

                // Extra bottom padding to account for tab bar
                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                QuickStatCardTab(
                    title: "Total Entries",
                    value: "\(viewModel.stats.totalEntries)",
                    icon: "book.closed.fill",
                    color: .blue
                )

                QuickStatCardTab(
                    title: "Average Score",
                    value: String(format: "%.0f", viewModel.averageScore),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                QuickStatCardTab(
                    title: "This Week",
                    value: "\(viewModel.stats.thisWeekEntries)",
                    icon: "calendar",
                    color: .orange
                )

                QuickStatCardTab(
                    title: "Days Active",
                    value: "\(viewModel.stats.sessionCountByDate.count)",
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
            }
        }
    }

    private var milestonesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()

                let unlockedCount = viewModel.milestones.filter { $0.isUnlocked }.count
                Text("\(unlockedCount)/\(viewModel.milestones.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.milestones) { milestone in
                    MilestoneView(milestone: milestone)
                }
            }
        }
    }
}

/// Quick stat card for overview section (tab version)
private struct QuickStatCardTab: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatisticsTabView(
        viewModel: StatisticsViewModel(repository: InMemoryJournalRepository())
    )
}
#endif
