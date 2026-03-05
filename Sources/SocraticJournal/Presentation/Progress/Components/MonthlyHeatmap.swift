// MonthlyHeatmap.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Calendar heatmap showing daily practice intensity for a given month
struct MonthlyHeatmap: View {
    let monthTitle: String
    let dayCells: [ProgressViewModel.DayCell]
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let cellSize: CGFloat = 32

    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView("This Month")

            // Month navigation header
            monthNavigationHeader
                .padding(.bottom, AppSpacing.sm)

            // Day-of-week header
            dayOfWeekHeader
                .padding(.bottom, AppSpacing.xs)

            // Calendar grid
            calendarGrid
                .padding(.bottom, AppSpacing.cardPadding)
        }
    }

    // MARK: - Month Navigation

    private var monthNavigationHeader: some View {
        HStack {
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Day-of-Week Header

    private var dayOfWeekHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(dayLabels.indices, id: \.self) { index in
                Text(dayLabels[index])
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
                    .frame(width: cellSize, height: 16)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(dayCells) { cell in
                dayCellView(cell)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    @ViewBuilder
    private func dayCellView(_ cell: ProgressViewModel.DayCell) -> some View {
        if cell.isCurrentMonth {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(cellFillColor(for: cell.intensity))
                    .frame(width: cellSize, height: cellSize)

                // Empty cell border
                if cell.intensity == .none {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(AppColors.border, lineWidth: 0.5)
                        .frame(width: cellSize, height: cellSize)
                }

                // Today ring
                if cell.isToday {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(AppColors.accent, lineWidth: 2)
                        .frame(width: cellSize, height: cellSize)
                }

                // Day number
                Text("\(cell.day)")
                    .font(.system(size: 10))
                    .foregroundStyle(dayNumberColor(for: cell))
            }
            .frame(width: cellSize, height: cellSize)
        } else {
            // Outside current month: invisible
            Color.clear
                .frame(width: cellSize, height: cellSize)
        }
    }

    // MARK: - Colors

    private func cellFillColor(for intensity: ProgressViewModel.HeatIntensity) -> Color {
        switch intensity {
        case .none:
            return AppColors.background
        case .light:
            return AppColors.accent.opacity(0.2)
        case .moderate:
            return AppColors.accent.opacity(0.5)
        case .deep:
            return AppColors.accent
        }
    }

    private func dayNumberColor(for cell: ProgressViewModel.DayCell) -> Color {
        switch cell.intensity {
        case .deep:
            return .white
        case .moderate, .light:
            return AppColors.textPrimary
        case .none:
            return AppColors.textTertiary
        }
    }
}
#endif
