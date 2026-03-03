// WeeklyGoalPicker.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Segmented picker for weekly breathing goal
public struct WeeklyGoalPicker: View {
    @Binding var selectedMinutes: Int

    public init(selectedMinutes: Binding<Int>) {
        self._selectedMinutes = selectedMinutes
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Set your weekly breathing target")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(WeeklyGoalOption.allCases, id: \.rawValue) { option in
                    goalPill(for: option)
                }
            }
        }
    }

    @ViewBuilder
    private func goalPill(for option: WeeklyGoalOption) -> some View {
        let isSelected = selectedMinutes == option.rawValue

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMinutes = option.rawValue
            }
        } label: {
            Text(option.shortLabel)
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : AppColors.surface)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WeeklyGoalPicker(selectedMinutes: .constant(35))
        .padding()
        .background(AppColors.background)
}
#endif
