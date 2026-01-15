// NotificationSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification settings section with toggles and time picker
struct NotificationSettingsView: View {
    @Binding var letterRemindersEnabled: Bool
    @Binding var dailyReminderEnabled: Bool
    @Binding var reminderTime: Date
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

            // Letter reminders toggle
            Toggle(isOn: $letterRemindersEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Letter Reminders")
                        .font(.body)
                    Text("Get notified when your future letters are ready to read")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

            Divider()

            // Daily reminder toggle
            Toggle(isOn: $dailyReminderEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Reminder")
                        .font(.body)
                    Text("Remind me to journal at a specific time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

            // Time picker (shown when daily reminder is enabled)
            if dailyReminderEnabled && !notificationsDenied {
                Divider()

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
        letterRemindersEnabled: .constant(true),
        dailyReminderEnabled: .constant(true),
        reminderTime: .constant(Date()),
        notificationsDenied: false
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Denied") {
    NotificationSettingsView(
        letterRemindersEnabled: .constant(false),
        dailyReminderEnabled: .constant(false),
        reminderTime: .constant(Date()),
        notificationsDenied: true,
        onOpenSettings: {}
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
