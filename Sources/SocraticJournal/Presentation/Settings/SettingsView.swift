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
    @Environment(SuperwallService.self) private var subscriptionService
    @State private var viewModel: SettingsViewModel
    @State private var showingExportView: Bool = false
    @State private var showingWisdomQuotes: Bool = false

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
                .alert("Clear All Data", isPresented: $viewModel.showClearDataConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clear", role: .destructive) {
                        Task {
                            await viewModel.clearAllData()
                        }
                    }
                } message: {
                    Text("This will permanently delete all your journal sessions and letters. This action cannot be undone.")
                }
                .alert("Notifications Disabled", isPresented: $viewModel.showPermissionDeniedAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Open Settings") {
                        viewModel.openNotificationSettings()
                    }
                } message: {
                    Text("To receive notifications, please enable them in Settings.")
                }
                .sheet(isPresented: $showingExportView) {
                    ExportView(
                        viewModel: ExportViewModel(
                            exportService: JSONDataExportService(
                                journalRepository: viewModel.journalRepository,
                                settingsRepository: viewModel.settingsRepository
                            )
                        )
                    )
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .fullScreenCover(isPresented: $showingWisdomQuotes) {
                    WisdomQuotesView(
                        viewModel: WisdomQuotesViewModel(
                            quoteService: LocalWisdomQuoteService()
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
                .overlay {
                    if viewModel.showClearDataSuccess {
                        successOverlay
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
                    // Subscription section (first for prominence)
                    SubscriptionSectionView()

                    // Appearance section
                    ThemeSelectorView(
                        selectedTheme: Binding(
                            get: { viewModel.themeMode },
                            set: { viewModel.themeMode = $0 }
                        )
                    )

                    // Notifications section
                    NotificationSettingsView(
                        letterRemindersEnabled: Binding(
                            get: { viewModel.letterRemindersEnabled },
                            set: { viewModel.letterRemindersEnabled = $0 }
                        ),
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

                    // Features section
                    FeaturesSettingsView(
                        onWisdomQuotesTapped: {
                            showingWisdomQuotes = true
                        }
                    )

                    // Data section
                    DataManagementView(
                        onExport: {
                            showingExportView = true
                        },
                        onClearData: {
                            viewModel.confirmClearData()
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
                                // Post notification to trigger onboarding display
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

    private var successOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("All data cleared")
                    .font(.subheadline.weight(.medium))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.bottom, 40)
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
        // Privacy policy URL
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
            settingsRepository: UserDefaultsSettingsRepository(),
            journalRepository: InMemoryJournalRepository()
        )
    )
    .environment(ThemeManager.shared)
    .environment(SuperwallService.shared)
}
#endif
