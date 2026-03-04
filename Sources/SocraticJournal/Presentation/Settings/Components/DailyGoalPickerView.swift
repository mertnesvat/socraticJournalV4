// DailyGoalPickerView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Row of pill buttons for selecting daily practice goal in minutes
struct DailyGoalPickerView: View {
    @Binding var selectedMinutes: Int

    private let options = [3, 5, 10, 15, 20]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Daily goal")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(options, id: \.self) { minutes in
                    goalPill(minutes: minutes)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }

    private func goalPill(minutes: Int) -> some View {
        let isSelected = selectedMinutes == minutes

        return Button {
            selectedMinutes = minutes
        } label: {
            Text("\(minutes) min")
                .font(AppTypography.captionBold)
                .foregroundStyle(isSelected ? AppColors.textOnAccent : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) minutes daily goal")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    DailyGoalPickerView(selectedMinutes: .constant(5))
        .padding(AppSpacing.screenPadding)
        .background(AppColors.background)
}
#endif
