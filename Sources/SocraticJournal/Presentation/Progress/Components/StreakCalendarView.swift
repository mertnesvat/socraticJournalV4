// StreakCalendarView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Month-view calendar heatmap showing practice days
public struct StreakCalendarView: View {
    let displayedMonth: Date
    let practiceDates: Set<Date>
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let canGoForward: Bool
    let monthTitle: String

    private let calendar = Calendar.current
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    public init(
        displayedMonth: Date,
        practiceDates: Set<Date>,
        onPreviousMonth: @escaping () -> Void,
        onNextMonth: @escaping () -> Void,
        canGoForward: Bool,
        monthTitle: String
    ) {
        self.displayedMonth = displayedMonth
        self.practiceDates = practiceDates
        self.onPreviousMonth = onPreviousMonth
        self.onNextMonth = onNextMonth
        self.canGoForward = canGoForward
        self.monthTitle = monthTitle
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Month navigation
            HStack {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text(monthTitle)
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(canGoForward ? AppColors.textSecondary : AppColors.textTertiary.opacity(0.3))
                }
                .disabled(!canGoForward)
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { day in
                    dayCell(for: day)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
    }

    // MARK: - Day Cell

    @ViewBuilder
    private func dayCell(for day: Date?) -> some View {
        if let day = day {
            let isToday = calendar.isDateInToday(day)
            let hasPractice = practiceDates.contains(calendar.startOfDay(for: day))
            let dayNumber = calendar.component(.day, from: day)

            ZStack {
                if hasPractice {
                    Circle()
                        .fill(AppColors.accent.opacity(0.8))
                        .frame(width: 32, height: 32)
                } else if isToday {
                    Circle()
                        .stroke(AppColors.accent.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                }

                Text("\(dayNumber)")
                    .font(AppTypography.caption)
                    .foregroundStyle(
                        hasPractice ? AppColors.textOnAccent
                            : isToday ? AppColors.accent
                            : AppColors.textSecondary
                    )
            }
            .frame(height: 36)
        } else {
            Color.clear
                .frame(height: 36)
        }
    }

    // MARK: - Helpers

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        let firstDay = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingEmpty = firstWeekday - calendar.firstWeekday

        var days: [Date?] = Array(repeating: nil, count: (leadingEmpty + 7) % 7)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        // Pad trailing to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }
}

#Preview {
    StreakCalendarView(
        displayedMonth: Date(),
        practiceDates: [],
        onPreviousMonth: {},
        onNextMonth: {},
        canGoForward: false,
        monthTitle: "March 2026"
    )
    .padding()
    .background(AppColors.background)
}
#endif
