// StreakCalendar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Weekly streak visualization showing 7 dots for Mon-Sun with answered/missed status
struct StreakCalendar: View {
    let weeklyDays: [Bool]
    let todayIndex: Int

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    dayDot(index: index)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Subviews

    private func dayDot(index: Int) -> some View {
        let isAnswered = index < weeklyDays.count ? weeklyDays[index] : false
        let isToday = index == todayIndex

        return VStack(spacing: 6) {
            ZStack {
                // Answered fill
                Circle()
                    .fill(isAnswered ? Color.accentColor : Color.clear)
                    .frame(width: 32, height: 32)

                // Empty outline for non-answered days
                if !isAnswered {
                    Circle()
                        .strokeBorder(Color(uiColor: .separator), lineWidth: 2)
                        .frame(width: 32, height: 32)
                }

                // Today highlight ring
                if isToday {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 3)
                        .frame(width: 38, height: 38)
                }

                // Checkmark for answered days
                if isAnswered {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 40, height: 40)

            Text(dayLabels[index])
                .font(.caption2.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? .primary : .secondary)
        }
    }
}

#Preview {
    StreakCalendar(
        weeklyDays: [true, true, true, true, true, false, false],
        todayIndex: 5
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
