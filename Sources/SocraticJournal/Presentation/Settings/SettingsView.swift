// SettingsView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

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
                    // Appearance
                    ThemeSelectorView(
                        selectedTheme: Binding(
                            get: { viewModel.themeMode },
                            set: { viewModel.themeMode = $0 }
                        )
                    )

                    // Notifications
                    NotificationSettingsView(
                        dailyReminderEnabled: Binding(
                            get: { viewModel.dailyReminderEnabled },
                            set: { viewModel.dailyReminderEnabled = $0 }
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

                    // Subscription
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

                    // About
                    AboutView(
                        version: AppEnvironment.version,
                        onPrivacyPolicy: {
                            if let url = URL(string: "https://studionext.co.uk/socratic-privacy.html") {
                                UIApplication.shared.open(url)
                            }
                        },
                        onReplayOnboarding: {
                            // Will be wired up when onboarding is implemented
                        }
                    )

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
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
