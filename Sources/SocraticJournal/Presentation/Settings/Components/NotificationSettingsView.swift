// NotificationSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

struct NotificationSettingsView: View {
    @Binding var breathReminderEnabled: Bool
    @Binding var reminderTime: Date
    var notificationsDenied: Bool = false
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if notificationsDenied {
                deniedBanner
                HairlineDivider()
            }

            toggleRow(
                title: "Daily Reminder",
                subtitle: "Get reminded to practice breathing",
                isOn: $breathReminderEnabled,
                disabled: notificationsDenied
            )

            if breathReminderEnabled && !notificationsDenied {
                HairlineDivider()
                    .padding(.leading, AppSpacing.screenPadding)

                HStack {
                    Text("Reminder Time")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.sm)
            }
        }
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        disabled: Bool
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .tint(AppColors.accent)
        .disabled(disabled)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
    }

    private var deniedBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(AppColors.warning)
            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications Disabled")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Enable notifications in Settings to receive reminders.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if let onOpenSettings = onOpenSettings {
                Button("Enable") {
                    onOpenSettings()
                }
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.warning.opacity(0.08))
    }
}
#endif
