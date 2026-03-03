// SettingsView.swift
// SocraticJournal
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
                .alert("Notifications Disabled", isPresented: $viewModel.showPermissionDeniedAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Open Settings") {
                        viewModel.openNotificationSettings()
                    }
                } message: {
                    Text("To receive reminders, please enable notifications in Settings.")
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

                    // REMINDERS section
                    SectionHeaderView("Reminders")
                        .padding(.top, AppSpacing.md)
                    NotificationSettingsView(
                        breathReminderEnabled: Binding(
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

    private var dailyGoalPicker: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Daily Goal")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(viewModel.dailyGoalMinutes) min")
                    .font(AppTypography.bodyBold)
                    .foregroundStyle(AppColors.accent)
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.md)

            HairlineDivider()

            HStack(spacing: AppSpacing.sm) {
                ForEach([1, 3, 5, 10, 15], id: \.self) { minutes in
                    Button {
                        viewModel.dailyGoalMinutes = minutes
                    } label: {
                        Text("\(minutes)")
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(
                                viewModel.dailyGoalMinutes == minutes
                                    ? AppColors.textOnAccent
                                    : AppColors.textPrimary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                Capsule()
                                    .fill(
                                        viewModel.dailyGoalMinutes == minutes
                                            ? AppColors.accent
                                            : AppColors.surfaceElevated
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.cardPadding)
            .padding(.vertical, AppSpacing.md)
        }
        .background(AppColors.surface)
        .overlay(
            Rectangle()
                .stroke(AppColors.border, lineWidth: AppSpacing.gridGutter)
        )
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
        if let url = URL(string: "https://studionext.co.uk/socratic-privacy.html") {
            UIApplication.shared.open(url)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
