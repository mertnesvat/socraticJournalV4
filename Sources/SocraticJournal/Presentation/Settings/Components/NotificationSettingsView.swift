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
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.headline)

            // Show denied state banner if notifications are disabled
            if notificationsDenied {
                deniedBanner
            }

            // Daily question reminder toggle
            Toggle(isOn: $dailyReminderEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Question")
                        .font(.body)
                    Text("Get notified when a new question drops")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

            // Time picker (shown when daily reminder is enabled)
            if dailyReminderEnabled && !notificationsDenied {
                HStack {
                    Text("Reminder Time")
                        .font(.body)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }

            Divider()

            // Friend activity toggle
            Toggle(isOn: $friendActivityEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Friend Activity")
                        .font(.body)
                    Text("Know when friends record their take")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

            Divider()

            // Streak reminders toggle
            Toggle(isOn: $streakRemindersEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak Reminders")
                        .font(.body)
                    Text("Don't lose your answer streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

            Divider()

            // FOMO alerts toggle
            Toggle(isOn: $fomoAlertsEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FOMO Alerts")
                        .font(.body)
                    Text("See how many friends answered before you")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var deniedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications Disabled")
                    .font(.subheadline.weight(.medium))

                Text("Enable notifications in Settings to receive reminders.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let onOpenSettings = onOpenSettings {
                Button("Enable") {
                    onOpenSettings()
                }
                .font(.subheadline.weight(.medium))
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
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
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
