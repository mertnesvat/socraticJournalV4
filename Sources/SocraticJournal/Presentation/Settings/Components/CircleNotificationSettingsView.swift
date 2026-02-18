// CircleNotificationSettingsView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Per-circle notification settings view.
/// Shows each circle with an individual notification toggle and time picker.
struct CircleNotificationSettingsView: View {
    @State private var viewModel: CircleNotificationSettingsViewModel

    init(viewModel: CircleNotificationSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection

            if viewModel.permissionDenied {
                permissionDeniedBanner
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else if viewModel.circles.isEmpty {
                emptyState
            } else {
                circleList
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task { await viewModel.loadData() }
        .alert("Notifications Disabled", isPresented: $viewModel.showPermissionDeniedAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                viewModel.openNotificationSettings()
            }
        } message: {
            Text("To receive circle reminders, please enable notifications in Settings.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Circle Reminders")
                .font(.headline)

            Text("Get a daily reminder for each circle at the time you choose")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Permission Denied Banner

    private var permissionDeniedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications Disabled")
                    .font(.subheadline.weight(.medium))
                Text("Enable in Settings to receive circle reminders.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Enable") {
                viewModel.openNotificationSettings()
            }
            .font(.subheadline.weight(.medium))
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("No circles yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Create a circle to set up reminders.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Circle List

    private var circleList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.circles.enumerated()), id: \.element.id) { index, circle in
                if index > 0 {
                    Divider()
                        .padding(.leading, 52)
                }
                circleRow(for: circle)
            }
        }
    }

    // MARK: - Circle Row

    @ViewBuilder
    private func circleRow(for circle: Circle) -> some View {
        let setting = viewModel.circleSettings[circle.id]
            ?? CircleNotificationSetting(circleId: circle.id)
        let isEnabled = setting.isEnabled

        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Circle icon
                ZStack {
                    SwiftUI.Circle()
                        .fill(CircleTheme.warmAmber.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: circle.emojiIcon)
                        .font(.subheadline)
                        .foregroundStyle(CircleTheme.warmAmber)
                }

                // Circle name
                Text(circle.name)
                    .font(.body)

                Spacer()

                // Toggle
                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { newValue in
                        Task {
                            await viewModel.toggleNotification(for: circle.id, enabled: newValue)
                        }
                    }
                ))
                .labelsHidden()
                .disabled(viewModel.permissionDenied)
            }

            // Time picker (shown when enabled)
            if isEnabled && !viewModel.permissionDenied {
                HStack {
                    Text("Reminder Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { setting.notificationTime },
                            set: { newTime in
                                Task {
                                    await viewModel.updateTime(for: circle.id, time: newTime)
                                }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .padding(.leading, 48)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("With Circles") {
    ScrollView {
        CircleNotificationSettingsView(
            viewModel: CircleNotificationSettingsViewModel(
                circleService: MockCircleService(),
                notificationService: LocalNotificationService(),
                settingsRepository: UserDefaultsSettingsRepository()
            )
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}

#Preview("Empty") {
    ScrollView {
        CircleNotificationSettingsView(
            viewModel: CircleNotificationSettingsViewModel(
                circleService: MockCircleService(withSampleData: false),
                notificationService: LocalNotificationService(),
                settingsRepository: UserDefaultsSettingsRepository()
            )
        )
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
#endif
