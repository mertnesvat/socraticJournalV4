// NotificationSettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings screen for managing notification preferences.
/// Shows notification permission status and per-circle mute toggles.
public struct NotificationSettingsView: View {
    @State private var viewModel: NotificationSettingsViewModel

    public init(viewModel: NotificationSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        List {
            permissionSection
            if viewModel.notificationsEnabled {
                circlesSection
            }
        }
        .navigationTitle("Notifications")
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }

    // MARK: - Permission Section

    @ViewBuilder
    private var permissionSection: some View {
        Section {
            switch viewModel.permissionStatus {
            case .authorized, .provisional:
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.green)
                    Text("Notifications Enabled")
                }

            case .denied:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bell.slash.fill")
                            .foregroundStyle(.red)
                        Text("Notifications Disabled")
                    }

                    Text("Notifications have been turned off. Open Settings to re-enable them.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Open Settings") {
                        openAppSettings()
                    }
                    .font(.subheadline)
                }

            case .notDetermined:
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                        Text("Enable Notifications")
                    }

                    Text("Get reminded when a new prompt arrives for your circles.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Allow Notifications") {
                        Task {
                            await viewModel.requestPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        } header: {
            Text("Permission")
        } footer: {
            Text("Get reminded when a new prompt arrives.")
        }
    }

    // MARK: - Circles Section

    @ViewBuilder
    private var circlesSection: some View {
        Section {
            if viewModel.circles.isEmpty {
                Text("No circles yet. Create a circle to configure notifications.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.circles) { circle in
                    circleRow(circle)
                }
            }
        } header: {
            Text("Circle Notifications")
        } footer: {
            Text("Mute a circle to stop receiving reminders for it.")
        }
    }

    private func circleRow(_ circle: CircleGroup) -> some View {
        let isMuted = viewModel.mutedCircleIds.contains(circle.id)
        return Toggle(isOn: Binding(
            get: { !isMuted },
            set: { _ in
                Task {
                    await viewModel.toggleCircleMute(circleId: circle.id)
                }
            }
        )) {
            HStack(spacing: 10) {
                Text(circle.emoji)
                    .font(.title3)
                Text(circle.name)
                    .font(.body)
            }
        }
    }

    // MARK: - Helpers

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView(
            viewModel: NotificationSettingsViewModel(
                repository: LocalCircleRepository(),
                scheduler: CircleNotificationScheduler(),
                currentUserId: UUID()
            )
        )
    }
}
#endif
