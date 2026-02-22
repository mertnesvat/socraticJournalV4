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
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
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
            ProgressView("Loading settings...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    // Appearance section
                    ThemeSelectorView(
                        selectedTheme: Binding(
                            get: { viewModel.themeMode },
                            set: { viewModel.themeMode = $0 }
                        )
                    )

                    // Notifications section
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

                    // Subscription section
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

                    // About section
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

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private var subscriptionUnavailableView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                VStack(spacing: 8) {
                    Text("Subscriptions Unavailable")
                        .font(.headline)

                    Text("The subscription service is not available right now. Please try again later.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Dismiss") {
                    showingPaywall = false
                }
                .font(.headline)
                .frame(width: 160, height: 44)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingPaywall = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
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
