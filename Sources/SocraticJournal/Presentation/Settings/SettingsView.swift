// SettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification posted when user requests to replay onboarding
public extension Notification.Name {
    static let replayOnboarding = Notification.Name("com.breathe.replayOnboarding")
}

/// Settings screen for breath app configuration
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel: SettingsViewModel
    let healthKitService: HealthKitServiceProtocol?

    public init(viewModel: SettingsViewModel, healthKitService: HealthKitServiceProtocol? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.healthKitService = healthKitService
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
                    dailyGoalPicker
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.bottom, AppSpacing.md)

                    // HAPTICS section
                    SectionHeaderView("Haptics")
                        .padding(.top, AppSpacing.md)
                    hapticToggle
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.bottom, AppSpacing.md)

                    // REMINDERS section
                    SectionHeaderView("Reminders")
                        .padding(.top, AppSpacing.md)
                    reminderSettings
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

                    // HEALTH & DATA section (only on device with HealthKit)
                    if let hkService = healthKitService, hkService.isHealthDataAvailable() {
                        SectionHeaderView("Health & Data")
                            .padding(.top, AppSpacing.md)
                        healthSection(hkService: hkService)
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.bottom, AppSpacing.md)
                    }

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

                    // DEVELOPER section
                    if viewModel.sessionRepository != nil {
                        SectionHeaderView("Developer")
                            .padding(.top, AppSpacing.md)
                        developerSection
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .padding(.bottom, AppSpacing.md)
                    }

                    Spacer(minLength: AppSpacing.sectionGap)
                }
            }
            .background(AppColors.background)
        }
    }

    // MARK: - Settings Header

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

    // MARK: - Daily Goal Picker

    private var dailyGoalPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Daily goal")
                .font(AppTypography.bodyBold)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach([3, 5, 10, 15], id: \.self) { minutes in
                    let isSelected = viewModel.dailyGoalMinutes == minutes
                    Button {
                        viewModel.dailyGoalMinutes = minutes
                    } label: {
                        Text("\(minutes) min")
                            .font(.system(size: 13, weight: isSelected ? .bold : .regular, design: .serif))
                            .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? AppColors.accentLight : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Haptic Toggle

    private var hapticToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Haptic rhythm")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Soft taptic cues at phase transitions")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.hapticRhythmEnabled },
                set: { viewModel.hapticRhythmEnabled = $0 }
            ))
            .tint(AppColors.accent)
            .labelsHidden()
        }
    }

    // MARK: - Reminder Settings

    private var reminderSettings: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Daily reminder")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.dailyReminderEnabled },
                    set: { viewModel.dailyReminderEnabled = $0 }
                ))
                .tint(AppColors.accent)
                .labelsHidden()
            }

            if viewModel.dailyReminderEnabled {
                DatePicker(
                    "Reminder time",
                    selection: Binding(
                        get: { viewModel.reminderTime },
                        set: { viewModel.reminderTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
            }

            if viewModel.notificationsDenied {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(AppColors.warning)
                    Text("Notifications are disabled in system settings")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Button("Fix") {
                        viewModel.openNotificationSettings()
                    }
                    .font(AppTypography.captionBold)
                    .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    // MARK: - Developer Section

    private var developerSection: some View {
        VStack(spacing: 0) {
            Button {
                Task { await viewModel.addSampleData() }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add Sample Data")
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(AppColors.accent)
                        Text("30 days of sessions + BOLT history")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    if viewModel.isSampleDataLoading && !viewModel.hasSampleData {
                        ProgressView()
                            .tint(AppColors.accent)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSampleDataLoading || viewModel.hasSampleData)
            .opacity((viewModel.hasSampleData) ? 0.4 : 1.0)

            if viewModel.hasSampleData {
                HairlineDivider()
                    .padding(.vertical, AppSpacing.sm)

                Button {
                    Task { await viewModel.removeSampleData() }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Remove Sample Data")
                                .font(AppTypography.bodyBold)
                                .foregroundStyle(AppColors.accent2)
                            Text("Deletes only generated data, not real sessions")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        if viewModel.isSampleDataLoading {
                            ProgressView()
                                .tint(AppColors.accent2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSampleDataLoading)
            }
        }
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

    // MARK: - Health Section

    private func healthSection(hkService: HealthKitServiceProtocol) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Connect Apple Health row
            Button {
                Task {
                    if viewModel.healthKitEnabled {
                        // Already enabled — open Health settings
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(url)
                        }
                    } else {
                        try? await hkService.requestAuthorization()
                        viewModel.healthKitEnabled = true
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connect Apple Health")
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(viewModel.healthKitEnabled ? "Connected" : "Tap to connect")
                            .font(.system(size: 12))
                            .foregroundStyle(viewModel.healthKitEnabled ? AppColors.accent : AppColors.textTertiary)
                    }
                    Spacer()
                    Image(systemName: viewModel.healthKitEnabled ? "checkmark.circle.fill" : "chevron.right")
                        .foregroundStyle(viewModel.healthKitEnabled ? AppColors.accent : AppColors.textTertiary)
                        .font(.system(size: 15))
                }
                .padding(.vertical, AppSpacing.xs)
            }
            .buttonStyle(.plain)

            if viewModel.healthKitEnabled {
                HairlineDivider()

                Toggle(isOn: Binding(
                    get: { viewModel.saveMindfulMinutes },
                    set: { viewModel.saveMindfulMinutes = $0 }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Save sessions as Mindful Minutes")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Sessions appear in Apple Health")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .tint(AppColors.accent)

                HairlineDivider()

                Toggle(isOn: Binding(
                    get: { viewModel.showHRVInsights },
                    set: { viewModel.showHRVInsights = $0 }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show HRV in Today view")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Requires Apple Watch data")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .tint(AppColors.accent)
            }
        }
    }

    private func openPrivacyPolicy() {
        let urlString = "https://studionext.co.uk/socratic-privacy.html"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
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
