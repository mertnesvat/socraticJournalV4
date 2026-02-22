// NotificationSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification settings section with toggles for social engagement notifications
struct NotificationSettingsView: View {
    @Binding var dailyReminderEnabled: Bool
    @Binding var reminderTime: Date
    @Binding var friendActivityEnabled: Bool
    @Binding var streakRemindersEnabled: Bool
    @Binding var fomoAlertsEnabled: Bool
    var notificationsDenied: Bool = false
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Show denied state banner if notifications are disabled
            if notificationsDenied {
                deniedBanner
                HairlineDivider()
            }

            // Daily question reminder toggle
            toggleRow(
                title: "Daily Question",
                subtitle: "Get notified when a new question drops",
                isOn: $dailyReminderEnabled,
                disabled: notificationsDenied
            )

            HairlineDivider()
                .padding(.leading, AppSpacing.screenPadding)

            // Time picker (shown when daily reminder is enabled)
            if dailyReminderEnabled && !notificationsDenied {
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

                HairlineDivider()
                    .padding(.leading, AppSpacing.screenPadding)
            }

            // Friend activity toggle
            toggleRow(
                title: "Friend Activity",
                subtitle: "Know when friends record their take",
                isOn: $friendActivityEnabled,
                disabled: notificationsDenied
            )

            HairlineDivider()
                .padding(.leading, AppSpacing.screenPadding)

            // Streak reminders toggle
            toggleRow(
                title: "Streak Reminders",
                subtitle: "Don't lose your answer streak",
                isOn: $streakRemindersEnabled,
                disabled: notificationsDenied
            )

            HairlineDivider()
                .padding(.leading, AppSpacing.screenPadding)

            // FOMO alerts toggle
            toggleRow(
                title: "FOMO Alerts",
                subtitle: "See how many friends answered before you",
                isOn: $fomoAlertsEnabled,
                disabled: notificationsDenied
            )
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

#Preview("Enabled") {
    NotificationSettingsView(
        dailyReminderEnabled: .constant(true),
        reminderTime: .constant(Date()),
        friendActivityEnabled: .constant(true),
        streakRemindersEnabled: .constant(true),
        fomoAlertsEnabled: .constant(true),
        notificationsDenied: false
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}

#Preview("Denied") {
    NotificationSettingsView(
        dailyReminderEnabled: .constant(false),
        reminderTime: .constant(Date()),
        friendActivityEnabled: .constant(false),
        streakRemindersEnabled: .constant(false),
        fomoAlertsEnabled: .constant(false),
        notificationsDenied: true,
        onOpenSettings: {}
    )
    .padding(AppSpacing.screenPadding)
    .background(AppColors.background)
}
#endif
