// CalendarView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Interactive calendar showing session activity
public struct CalendarView: View {
    let stats: JournalStats
    let selectedDate: Date?
    let onDateSelected: (Date) -> Void

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    public init(
        stats: JournalStats,
        selectedDate: Date?,
        onDateSelected: @escaping (Date) -> Void
    ) {
        self.stats = stats
        self.selectedDate = selectedDate
        self.onDateSelected = onDateSelected
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(monthYearString)
                    .font(.headline)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            sessionCount: stats.sessionCount(for: date),
                            averageScore: stats.averageScore(for: date),
                            isSelected: isSelected(date),
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            onDateSelected(date)
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Computed Properties

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday
        return Array(symbols[(firstWeekday - 1)...]) + Array(symbols[..<(firstWeekday - 1)])
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        var currentDate = monthFirstWeek.start

        // Add empty cells for days before the month starts
        while currentDate < monthInterval.start {
            days.append(nil)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Add days in the month
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    // MARK: - Helpers

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}

private struct DayCell: View {
    let date: Date
    let sessionCount: Int
    let averageScore: Double?
    let isSelected: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            // Background
            if isSelected {
                Circle()
                    .fill(Color.accentColor)
            } else if isToday {
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1)
            }

            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)

                // Session indicator - always present for consistent row height
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 6, height: 6)
                    .opacity(sessionCount > 0 ? 1 : 0)
            }
        }
        .aspectRatio(1, contentMode: .fill)
    }

    private var indicatorColor: Color {
        if isSelected {
            return .white
        }
        guard let score = averageScore else {
            return .accentColor.opacity(0.6)
        }
        // Color based on average clarity score
        switch score {
        case 0..<4: return .orange
        case 4..<7: return .yellow
        default: return .green
        }
    }
}

#Preview {
    CalendarView(
        stats: JournalStats(
            totalEntries: 10,
            sessionCountByDate: [
                JournalStats.dateKey(for: Date()): 2,
                JournalStats.dateKey(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!): 1
            ],
            averageScoreByDate: [
                JournalStats.dateKey(for: Date()): 7.5
            ]
        ),
        selectedDate: nil,
        onDateSelected: { _ in }
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
