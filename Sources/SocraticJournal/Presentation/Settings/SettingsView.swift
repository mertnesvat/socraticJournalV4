// SettingsView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification posted when user requests to replay onboarding
public extension Notification.Name {
    static let replayOnboarding = Notification.Name("com.breathe.replayOnboarding")
}

/// Settings screen for the Breath Pacer app
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .task { await viewModel.loadSettings() }
                .alert("Notifications Disabled", isPresented: $viewModel.showPermissionDeniedAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Open Settings") {
                        viewModel.openNotificationSettings()
                    }
                } message: {
                    Text("To receive breath reminders, please enable notifications in Settings.")
                }
                .preferredColorScheme(themeManager.colorScheme)
                .onChange(of: viewModel.themeMode) { _, newMode in
                    themeManager.updateTheme(newMode)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack {
                ProgressView("Loading settings...")
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    settingsHeader

                    // PRACTICE section
                    SectionHeaderView("Practice")
                    DailyGoalPicker(
                        selectedMinutes: Binding(
                            get: { viewModel.dailyGoalMinutes },
                            set: { viewModel.dailyGoalMinutes = $0 }
                        )
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // REMINDERS section
                    SectionHeaderView("Reminders")
                        .padding(.top, AppSpacing.md)
                    BreathReminderSettingsView(
                        reminderEnabled: Binding(
                            get: { viewModel.breathReminderEnabled },
                            set: { viewModel.breathReminderEnabled = $0 }
                        ),
                        reminderTime: Binding(
                            get: { viewModel.reminderTime },
                            set: { viewModel.reminderTime = $0 }
                        ),
                        notificationsDenied: viewModel.notificationsDenied,
                        onOpenSettings: {
                            viewModel.openNotificationSettings()
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // APPEARANCE section
                    SectionHeaderView("Appearance")
                        .padding(.top, AppSpacing.md)
                    ThemeSelectorView(
                        selectedTheme: Binding(
                            get: { viewModel.themeMode },
                            set: { viewModel.themeMode = $0 }
                        )
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // ABOUT section
                    SectionHeaderView("About")
                        .padding(.top, AppSpacing.md)
                    AboutView(
                        version: SocraticJournal.version,
                        onPrivacyPolicy: { openPrivacyPolicy() },
                        onReplayOnboarding: {
                            Task {
                                await viewModel.resetOnboarding()
                                dismiss()
                                NotificationCenter.default.post(name: .replayOnboarding, object: nil)
                            }
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
        }
    }

    private var settingsHeader: some View {
        HStack {
            Text("Settings")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    private func openPrivacyPolicy() {
        let urlString = "https://studionext.co.uk/breathe-privacy.html"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Daily Goal Picker

struct DailyGoalPicker: View {
    @Binding var selectedMinutes: Int
    private let options = [3, 5, 10, 15]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Daily Goal")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(options, id: \.self) { minutes in
                    Button {
                        selectedMinutes = minutes
                    } label: {
                        Text("\(minutes) min")
                            .font(AppTypography.captionBold)
                            .foregroundStyle(selectedMinutes == minutes ? AppColors.textOnAccent : AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                Capsule()
                                    .fill(selectedMinutes == minutes ? AppColors.accent : AppColors.surfaceElevated)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
    }
}

// MARK: - Breath Reminder Settings

struct BreathReminderSettingsView: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date
    var notificationsDenied: Bool = false
    var onOpenSettings: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if notificationsDenied {
                deniedBanner
                HairlineDivider()
            }

            Toggle(isOn: $reminderEnabled) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Daily Reminder")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("A gentle nudge to breathe")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .tint(AppColors.accent)
            .disabled(notificationsDenied)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.sm)

            if reminderEnabled && !notificationsDenied {
                HairlineDivider()
                    .padding(.leading, AppSpacing.screenPadding)

                HStack {
                    Text("Reminder Time")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
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

    private var deniedBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(AppColors.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications Disabled")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Enable in Settings to receive reminders.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            if let onOpenSettings {
                Button("Enable") { onOpenSettings() }
                    .font(AppTypography.captionBold)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.warning.opacity(0.08))
    }
}

#Preview {
    SettingsView(
        viewModel: SettingsViewModel(
            settingsRepository: UserDefaultsSettingsRepository()
        )
    )
    .environment(ThemeManager.shared)
}
#endif
