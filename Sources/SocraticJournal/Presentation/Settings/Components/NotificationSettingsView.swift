// NotificationSettingsView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct NotificationSettingsView: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date

    var body: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $reminderEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminder")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Gentle nudge to breathe")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textQuaternary)
                }
            }
            .tint(AppColors.accent)
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.sm)

            if reminderEnabled {
                HairlineDivider()
                    .padding(.leading, AppSpacing.cardPadding)

                HStack {
                    Text("Time")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.vertical, AppSpacing.sm)
            }
        }
        .background(AppColors.surface)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 1))
    }
}
#endif
