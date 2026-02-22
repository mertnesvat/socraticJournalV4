// StreakCalendar.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Weekly streak visualization — 7 inline circles for Mon-Sun with editorial section header
struct StreakCalendar: View {
    let weeklyDays: [Bool]
    let todayIndex: Int

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("THIS WEEK")

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    dayDot(index: index)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.lg)

            HairlineDivider()
        }
    }

    // MARK: - Subviews

    private func dayDot(index: Int) -> some View {
        let isAnswered = index < weeklyDays.count ? weeklyDays[index] : false
        let isToday = index == todayIndex

        return VStack(spacing: AppSpacing.xs) {
            ZStack {
                if isAnswered {
                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .strokeBorder(
                            isToday ? AppColors.accent : AppColors.border,
                            lineWidth: isToday ? 2 : 1
                        )
                        .frame(width: 32, height: 32)
                }
            }

            Text(dayLabels[index])
                .font(AppTypography.caption)
                .foregroundStyle(
                    isToday ? AppColors.textPrimary : AppColors.textSecondary
                )
        }
    }
}

#Preview {
    StreakCalendar(
        weeklyDays: [true, true, true, true, true, false, false],
        todayIndex: 5
    )
    .background(AppColors.background)
}
#endif
