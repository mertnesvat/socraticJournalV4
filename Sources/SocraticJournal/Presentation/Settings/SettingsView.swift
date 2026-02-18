// SettingsView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Settings & Profile screen for the Circle app.
/// Shows profile editing, circles list, preferences, notifications, subscription, about, and data management.
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    @State private var viewModel: SettingsViewModel
    @State private var showLeaveCircleConfirmation: UUID?

    // Dependencies for child views
    private let circleRepository: CircleRepositoryProtocol
    private let subscriptionService: SubscriptionServiceProtocol?
    private let notificationScheduler: CircleNotificationScheduler?
    private let analyticsService: AnalyticsServiceProtocol?
    private let currentUserId: UUID?

    // MARK: - Init

    public init(
        viewModel: SettingsViewModel,
        circleRepository: CircleRepositoryProtocol,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        notificationScheduler: CircleNotificationScheduler? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        currentUserId: UUID? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.circleRepository = circleRepository
        self.subscriptionService = subscriptionService
        self.notificationScheduler = notificationScheduler
        self.analyticsService = analyticsService
        self.currentUserId = currentUserId
    }

    // MARK: - Body

    public var body: some View {
        Form {
            profileSection
            myCirclesSection
            preferencesSection
            notificationsSection
            subscriptionSection
            aboutSection
            dangerZoneSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.error ?? "")
        }
        .alert("Clear All Data", isPresented: $viewModel.showClearDataConfirmation) {
            Button("Clear All Data", role: .destructive) {
                Task {
                    await viewModel.clearAllLocalData()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all your circles, prompts, and voice notes. You will be signed out and need to create a new profile.")
        }
        .alert("Leave Circle", isPresented: Binding(
            get: { showLeaveCircleConfirmation != nil },
            set: { if !$0 { showLeaveCircleConfirmation = nil } }
        )) {
            Button("Leave", role: .destructive) {
                if let circleId = showLeaveCircleConfirmation {
                    Task {
                        await viewModel.leaveCircle(id: circleId)
                    }
                }
                showLeaveCircleConfirmation = nil
            }
            Button("Cancel", role: .cancel) {
                showLeaveCircleConfirmation = nil
            }
        } message: {
            if let circleId = showLeaveCircleConfirmation,
               let circle = viewModel.circles.first(where: { $0.id == circleId }) {
                Text("Are you sure you want to leave \"\(circle.name)\"? You will need a new invite code to rejoin.")
            } else {
                Text("Are you sure you want to leave this circle?")
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar circle with initials
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 64, height: 64)

                    Text(viewModel.userInitials)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Profile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    TextField("Display Name", text: $viewModel.displayName)
                        .font(.title3.weight(.medium))
                        .textContentType(.name)
                        .submitLabel(.done)
                        .onSubmit {
                            Task {
                                await viewModel.updateDisplayName()
                            }
                        }
                }
            }
            .padding(.vertical, 4)

            if viewModel.hasNameChanged {
                Button {
                    Task {
                        await viewModel.updateDisplayName()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Name")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - My Circles Section

    private var myCirclesSection: some View {
        Section {
            if viewModel.circles.isEmpty {
                Text("No circles yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.circles) { circle in
                    NavigationLink {
                        if let userId = currentUserId {
                            CircleDetailView(
                                circle: circle,
                                viewModel: CirclesViewModel(
                                    repository: circleRepository,
                                    currentUserId: userId,
                                    notificationScheduler: notificationScheduler
                                )
                            )
                        }
                    } label: {
                        circleRow(circle)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            showLeaveCircleConfirmation = circle.id
                        } label: {
                            Label("Leave", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
        } header: {
            Text("My Circles")
        }
    }

    private func circleRow(_ circle: CircleGroup) -> some View {
        HStack(spacing: 12) {
            Text(circle.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(circle.name)
                    .font(.body)

                Text("\(circle.memberIds.count) member\(circle.memberIds.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        Section {
            // Voice Quality
            Picker("Voice Quality", selection: $viewModel.voiceQuality) {
                ForEach(VoiceQuality.allCases, id: \.self) { quality in
                    Text(quality.displayName).tag(quality)
                }
            }

            // Theme
            Picker("Theme", selection: Binding(
                get: { themeManager.themeMode },
                set: { newMode in
                    Task {
                        await themeManager.setTheme(newMode)
                    }
                }
            )) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Label(mode.displayName, systemImage: mode.iconName)
                        .tag(mode)
                }
            }
        } header: {
            Text("Preferences")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            if let userId = currentUserId {
                NavigationLink {
                    NotificationSettingsView(
                        viewModel: NotificationSettingsViewModel(
                            repository: circleRepository,
                            scheduler: notificationScheduler ?? CircleNotificationScheduler(),
                            currentUserId: userId
                        )
                    )
                } label: {
                    Label("Notifications", systemImage: "bell.badge")
                }
            }
        } header: {
            Text("Notifications")
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        Section {
            if let service = subscriptionService {
                NavigationLink {
                    PaywallView(
                        viewModel: PaywallViewModel(
                            subscriptionService: service,
                            analyticsService: analyticsService
                        )
                    )
                } label: {
                    HStack {
                        Label("Subscription", systemImage: "sparkles")

                        Spacer()

                        Text(viewModel.subscriptionStatusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Label("Subscription", systemImage: "sparkles")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Subscription")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("App Version")
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://studionext.co.uk/socratic-privacy.html")!) {
                HStack {
                    Text("Privacy Policy")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.forward.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://studionext.co.uk/socratic-terms.html")!) {
                HStack {
                    Text("Terms of Service")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.forward.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "mailto:support@studionext.co.uk?subject=Circle%20App%20Feedback")!) {
                HStack {
                    Text("Send Feedback")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "envelope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        }
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showClearDataConfirmation = true
            } label: {
                Label("Clear All Local Data", systemImage: "trash")
            }
        } header: {
            Text("Danger Zone")
        } footer: {
            Text("This will remove all your circles, prompts, and voice notes. You will be signed out.")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                authState: AuthState(service: LocalAuthService()),
                settingsRepository: UserDefaultsSettingsRepository(),
                circleRepository: LocalCircleRepository()
            ),
            circleRepository: LocalCircleRepository()
        )
    }
    .environment(ThemeManager.shared)
}
#endif
