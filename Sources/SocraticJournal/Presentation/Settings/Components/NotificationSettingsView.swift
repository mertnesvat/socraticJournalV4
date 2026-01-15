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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.headline)

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

            // Time picker (shown when daily reminder is enabled)
            if dailyReminderEnabled {
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
}

#Preview {
    NotificationSettingsView(
        letterRemindersEnabled: .constant(true),
        dailyReminderEnabled: .constant(true),
        reminderTime: .constant(Date())
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
