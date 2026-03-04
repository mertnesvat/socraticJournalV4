// SessionHistorySection.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// All sessions in reverse chronological order, grouped by day
struct SessionHistorySection: View {
    let sessionsByDate: [(date: Date, sessions: [BreathSession])]

    var body: some View {
        if sessionsByDate.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                ForEach(Array(sessionsByDate.enumerated()), id: \.element.date) { _, group in
                    dateHeader(group.date)

                    ForEach(Array(group.sessions.enumerated()), id: \.element.id) { index, session in
                        SessionHistoryRow(session: session)

                        if index < group.sessions.count - 1 {
                            HairlineDivider()
                                .padding(.horizontal, AppSpacing.screenPadding)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Date Header

    private func dateHeader(_ date: Date) -> some View {
        HStack {
            Text(formattedDateHeader(date))
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textTertiary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xxs)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "clock")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.textTertiary)

            Text("Complete your first session to see your history here")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppSpacing.xl)
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Date Formatting

    private func formattedDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: date)
    }
}

#Preview("Session History Section") {
    let now = Date()
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

    let groups: [(date: Date, sessions: [BreathSession])] = [
        (date: calendar.startOfDay(for: now), sessions: [
            BreathSession(techniqueId: "resonance", techniqueName: "Resonance Breathing",
                          startedAt: now, completedAt: now.addingTimeInterval(300),
                          targetDuration: 300, cyclesCompleted: 5),
            BreathSession(techniqueId: "box", techniqueName: "Box Breathing",
                          startedAt: now.addingTimeInterval(-3600),
                          completedAt: now.addingTimeInterval(-3600 + 180),
                          targetDuration: 300, cyclesCompleted: 3)
        ]),
        (date: calendar.startOfDay(for: yesterday), sessions: [
            BreathSession(techniqueId: "478", techniqueName: "4-7-8 Breathing",
                          startedAt: yesterday, completedAt: yesterday.addingTimeInterval(600),
                          targetDuration: 600, cyclesCompleted: 10)
        ])
    ]

    ScrollView {
        SessionHistorySection(sessionsByDate: groups)
    }
    .background(AppColors.background)
}

#Preview("Session History - Empty") {
    SessionHistorySection(sessionsByDate: [])
        .background(AppColors.background)
}
#endif
