// StreakCalendarView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Grid calendar for the current month showing days with breathing sessions
struct StreakCalendarView: View {
    let sessionsByDay: [Date: [BreathSession]]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private var today: Date { calendar.startOfDay(for: Date()) }

    private var currentMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    /// Number of days in the current month
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }

    /// Weekday index of the first day (0 = Monday in our grid)
    private var firstWeekdayOffset: Int {
        let firstDay = currentMonth
        // Calendar.current.component(.weekday) returns 1=Sun, 2=Mon, ..., 7=Sat
        let weekday = calendar.component(.weekday, from: firstDay)
        // Convert to Monday-based: Mon=0, Tue=1, ..., Sun=6
        return (weekday + 5) % 7
    }

    /// All cell indices: offset blanks + actual days
    private var calendarCells: [CalendarCell] {
        var cells: [CalendarCell] = []

        // Leading blank cells
        for _ in 0..<firstWeekdayOffset {
            cells.append(.blank)
        }

        // Day cells
        for day in 1...daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: currentMonth) else {
                cells.append(.blank)
                continue
            }
            let dayDate = calendar.startOfDay(for: date)
            cells.append(.day(number: day, date: dayDate))
        }

        return cells
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Month + Year header
            HStack {
                Text(monthYearTitle)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            // Day-of-week headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(calendarCells.enumerated()), id: \.offset) { _, cell in
                    calendarCellView(cell)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Cell View

    @ViewBuilder
    private func calendarCellView(_ cell: CalendarCell) -> some View {
        switch cell {
        case .blank:
            Color.clear
                .aspectRatio(1, contentMode: .fit)

        case .day(let number, let date):
            let sessions = sessionsByDay[date] ?? []
            let totalMinutes = sessions.reduce(0.0) { $0 + $1.actualDuration / 60.0 }
            let isToday = date == today
            let isFuture = date > today
            let hasSession = !sessions.isEmpty

            ZStack {
                // Background circle
                Circle()
                    .fill(hasSession
                        ? AppColors.accent.opacity(min(totalMinutes / 10.0, 1.0))
                        : AppColors.border.opacity(0.3)
                    )

                // Today ring
                if isToday {
                    Circle()
                        .strokeBorder(AppColors.accent, lineWidth: 2)
                }

                // Day number
                Text("\(number)")
                    .font(AppTypography.caption)
                    .foregroundStyle(
                        isFuture
                            ? AppColors.textTertiary.opacity(0.4)
                            : (hasSession ? AppColors.textPrimary : AppColors.textSecondary)
                    )
            }
            .aspectRatio(1, contentMode: .fit)
            .opacity(isFuture ? 0.4 : 1.0)
        }
    }
}

// MARK: - Calendar Cell Model

private enum CalendarCell {
    case blank
    case day(number: Int, date: Date)
}

#Preview("Streak Calendar") {
    let now = Date()
    let calendar = Calendar.current
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

    let sessions: [Date: [BreathSession]] = [
        calendar.startOfDay(for: twoDaysAgo): [
            BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                          startedAt: twoDaysAgo, completedAt: twoDaysAgo.addingTimeInterval(300),
                          targetDuration: 300, cyclesCompleted: 5)
        ],
        calendar.startOfDay(for: yesterday): [
            BreathSession(techniqueId: "box", techniqueName: "Box",
                          startedAt: yesterday, completedAt: yesterday.addingTimeInterval(600),
                          targetDuration: 600, cyclesCompleted: 10)
        ],
        calendar.startOfDay(for: now): [
            BreathSession(techniqueId: "resonance", techniqueName: "Resonance",
                          startedAt: now, completedAt: now.addingTimeInterval(180),
                          targetDuration: 300, cyclesCompleted: 3)
        ]
    ]

    StreakCalendarView(sessionsByDay: sessions)
        .padding(.vertical)
        .background(AppColors.background)
}
#endif
