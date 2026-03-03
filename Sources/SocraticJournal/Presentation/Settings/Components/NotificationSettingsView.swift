// NotificationSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification settings section with daily breath reminder toggle
struct NotificationSettingsView: View {
    @Binding var dailyReminderEnabled: Bool
    @Binding var reminderTime: Date
    var notificationsDenied: Bool = false
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Show denied state banner if notifications are disabled
            if notificationsDenied {
                deniedBanner
                HairlineDivider()
            }

            // Daily breath reminder toggle
            toggleRow(
                title: "Daily Reminder",
                subtitle: "Get a gentle nudge to breathe",
                isOn: $dailyReminderEnabled,
                disabled: notificationsDenied
            )

            HairlineDivider()
                .padding(.leading, AppSpacing.screenPadding)

            // Time picker and presets (shown when daily reminder is enabled)
            if dailyReminderEnabled && !notificationsDenied {
                // Suggested presets
                HStack(spacing: AppSpacing.xs) {
                    presetButton(label: "Morning", hour: 7, minute: 0)
                    presetButton(label: "Midday", hour: 12, minute: 0)
                    presetButton(label: "Evening", hour: 21, minute: 0)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xs)

                HStack {
                    Text("Custom Time")
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

    private func presetButton(label: String, hour: Int, minute: Int) -> some View {
        Button {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            if let date = Calendar.current.date(from: components) {
                reminderTime = date
            }
        } label: {
            Text(label)
                .font(AppTypography.captionBold)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xxs)
                .background(
                    Capsule()
                        .fill(AppColors.surfaceElevated)
                )
        }
        .buttonStyle(.plain)
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

#Preview("Enabled") {
    NotificationSettingsView(
        dailyReminderEnabled: .constant(true),
        reminderTime: .constant(Date()),
        notificationsDenied: false
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}

#Preview("Denied") {
    NotificationSettingsView(
        dailyReminderEnabled: .constant(false),
        reminderTime: .constant(Date()),
        notificationsDenied: true,
        onOpenSettings: {}
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
