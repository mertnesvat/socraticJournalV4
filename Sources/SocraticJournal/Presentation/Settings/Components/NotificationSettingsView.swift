// NotificationSettingsView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification settings section with daily reminder toggle and time picker
struct NotificationSettingsView: View {
    @Binding var dailyReminderEnabled: Bool
    @Binding var reminderTime: Date
    var notificationsDenied: Bool = false
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.headline)

            if notificationsDenied {
                deniedBanner
            }

            Toggle(isOn: $dailyReminderEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Prompt Reminder")
                        .font(.body)
                    Text("Get reminded when today's Circle question arrives")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(notificationsDenied)

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

            if let onOpenSettings {
                Button("Enable") { onOpenSettings() }
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

#Preview {
    NotificationSettingsView(
        dailyReminderEnabled: .constant(true),
        reminderTime: .constant(Date())
    )
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
