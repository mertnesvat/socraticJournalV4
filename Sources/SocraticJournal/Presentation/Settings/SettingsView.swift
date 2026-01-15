// SettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings screen for app configuration
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    @State private var showingExportView: Bool = false

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
                .sheet(isPresented: $showingExportView) {
                    ExportView(
                        viewModel: ExportViewModel(
                            exportService: JSONDataExportService(
                                journalRepository: viewModel.journalRepository,
                                settingsRepository: viewModel.settingsRepository
                            )
                        )
                    )
                }
                .overlay {
                    if viewModel.showClearDataSuccess {
                        successOverlay
                    }
                }
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch viewModel.themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
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
                        )
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
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func openPrivacyPolicy() {
        // Privacy policy URL - replace with actual URL
        let urlString = "https://socraticjournal.app/privacy"
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
}
#endif
