// SettingsView.swift
// Breathe
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

public extension Notification.Name {
    static let replayOnboarding = Notification.Name("com.breathe.replayOnboarding")
}

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
                ProgressView()
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

                    // REMINDERS section
                    SectionHeaderView("Reminders")
                        .padding(.top, AppSpacing.md)
                    reminderSettings
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.bottom, AppSpacing.md)

                    // FEEDBACK section
                    SectionHeaderView("Feedback")
                        .padding(.top, AppSpacing.md)
                    hapticToggle
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
                        version: Breathe.version,
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

    // MARK: - Daily Goal Picker

    private var dailyGoalPicker: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("Daily Goal")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(viewModel.dailyGoalMinutes) min")
                    .font(AppTypography.captionBold)
                    .foregroundStyle(AppColors.accent)
            }

            HStack(spacing: 8) {
                ForEach([1, 3, 5, 10, 15], id: \.self) { minutes in
                    Button {
                        viewModel.dailyGoalMinutes = minutes
                    } label: {
                        Text("\(minutes)")
                            .font(AppTypography.captionBold)
                            .foregroundStyle(viewModel.dailyGoalMinutes == minutes ? AppColors.accent : AppColors.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(viewModel.dailyGoalMinutes == minutes ? AppColors.accentLight : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(viewModel.dailyGoalMinutes == minutes ? AppColors.accent : AppColors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surface)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Reminder Settings

    private var reminderSettings: some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { viewModel.breathReminderEnabled },
                set: { viewModel.breathReminderEnabled = $0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminder")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Get a gentle nudge to breathe")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textQuaternary)
                }
            }
            .tint(AppColors.accent)
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.sm)

            if viewModel.breathReminderEnabled {
                HairlineDivider()
                    .padding(.leading, AppSpacing.cardPadding)

                HStack {
                    Text("Time")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { viewModel.reminderTime },
                        set: { viewModel.reminderTime = $0 }
                    ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.vertical, AppSpacing.sm)
            }
        }
        .background(AppColors.surface)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 1))
    }

    // MARK: - Haptic Toggle

    private var hapticToggle: some View {
        Toggle(isOn: Binding(
            get: { viewModel.hapticFeedbackEnabled },
            set: { viewModel.hapticFeedbackEnabled = $0 }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Haptic Rhythm")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Soft taptic cue at phase changes")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textQuaternary)
            }
        }
        .tint(AppColors.accent)
        .padding(.horizontal, AppSpacing.cardPadding)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface)
        .overlay(Rectangle().stroke(AppColors.border, lineWidth: 1))
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
        if let url = URL(string: "https://studionext.co.uk/breathe-privacy.html") {
            UIApplication.shared.open(url)
        }
    }
}
#endif
