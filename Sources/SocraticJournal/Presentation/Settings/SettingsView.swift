// SettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Notification posted when user requests to replay onboarding
public extension Notification.Name {
    static let replayOnboarding = Notification.Name("com.socraticjournal.replayOnboarding")
}

/// Settings screen for app configuration
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel: SettingsViewModel
    @State private var showingPaywall: Bool = false

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
                    Text("To receive notifications, please enable them in Settings.")
                }
                .sheet(isPresented: $showingPaywall) {
                    if let subscriptionService = viewModel.subscriptionService {
                        PaywallView(
                            viewModel: PaywallViewModel(
                                subscriptionService: subscriptionService,
                                analyticsService: viewModel.analyticsService
                            )
                        )
                        .environment(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                    } else {
                        subscriptionUnavailableView
                            .preferredColorScheme(themeManager.colorScheme)
                    }
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
                    // Custom title
                    settingsHeader

                    // APPEARANCE section
                    SectionHeaderView("Appearance")
                    ThemeSelectorView(
                        selectedTheme: Binding(
                            get: { viewModel.themeMode },
                            set: { viewModel.themeMode = $0 }
                        )
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // NOTIFICATIONS section
                    SectionHeaderView("Notifications")
                        .padding(.top, AppSpacing.md)
                    NotificationSettingsView(
                        dailyReminderEnabled: Binding(
                            get: { viewModel.dailyReminderEnabled },
                            set: { viewModel.dailyReminderEnabled = $0 }
                        ),
                        reminderTime: Binding(
                            get: { viewModel.reminderTime },
                            set: { viewModel.reminderTime = $0 }
                        ),
                        friendActivityEnabled: Binding(
                            get: { viewModel.friendActivityEnabled },
                            set: { viewModel.friendActivityEnabled = $0 }
                        ),
                        streakRemindersEnabled: Binding(
                            get: { viewModel.streakRemindersEnabled },
                            set: { viewModel.streakRemindersEnabled = $0 }
                        ),
                        fomoAlertsEnabled: Binding(
                            get: { viewModel.fomoAlertsEnabled },
                            set: { viewModel.fomoAlertsEnabled = $0 }
                        ),
                        notificationsDenied: viewModel.notificationsDenied,
                        onOpenSettings: {
                            viewModel.openNotificationSettings()
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // SUBSCRIPTION section
                    SectionHeaderView("Subscription")
                        .padding(.top, AppSpacing.md)
                    SubscriptionSettingsView(
                        subscriptionStatus: viewModel.subscriptionStatus,
                        expiryDate: viewModel.formattedSubscriptionExpiry,
                        isRestoring: viewModel.isRestoringPurchases,
                        onUpgradeTapped: {
                            showingPaywall = true
                        },
                        onRestoreTapped: {
                            Task {
                                await viewModel.restorePurchases()
                            }
                        },
                        onManageSubscriptionTapped: {
                            viewModel.openSubscriptionManagement()
                        }
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.md)

                    // ABOUT section
                    SectionHeaderView("About")
                        .padding(.top, AppSpacing.md)
                    AboutView(
                        version: SocraticJournal.version,
                        onPrivacyPolicy: {
                            openPrivacyPolicy()
                        },
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

    // MARK: - Subscription Unavailable

    private var subscriptionUnavailableView: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.warning)

                VStack(spacing: AppSpacing.xs) {
                    Text("Subscriptions Unavailable")
                        .font(AppTypography.headlineMedium)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("The subscription service is not available right now. Please try again later.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AccentPillButton("Dismiss") {
                    showingPaywall = false
                }
                .frame(width: 180)
            }
            .padding(AppSpacing.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingPaywall = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
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

    private func openPrivacyPolicy() {
        let urlString = "https://studionext.co.uk/socratic-privacy.html"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

/// UIActivityViewController wrapper for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
