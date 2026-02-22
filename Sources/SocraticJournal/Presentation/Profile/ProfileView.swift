// ProfileView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Main profile screen displaying the user's voice identity, stats, and achievements
public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showingSettings: Bool = false
    @Environment(ThemeManager.self) private var themeManager

    // Services passed through for SettingsView
    private let settingsRepository: SettingsRepositoryProtocol?
    private let notificationService: NotificationServiceProtocol?
    private let subscriptionService: SubscriptionServiceProtocol?
    private let analyticsService: AnalyticsServiceProtocol?

    public init(
        viewModel: ProfileViewModel,
        settingsRepository: SettingsRepositoryProtocol? = nil,
        notificationService: NotificationServiceProtocol? = nil,
        subscriptionService: SubscriptionServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.settingsRepository = settingsRepository
        self.notificationService = notificationService
        self.subscriptionService = subscriptionService
        self.analyticsService = analyticsService
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarContent }
                .sheet(isPresented: $showingSettings) {
                    settingsSheet
                }
                .task { await viewModel.loadData() }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.user == nil {
            ProgressView("Loading profile...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        } else if let errorMessage = viewModel.errorMessage, viewModel.user == nil {
            ContentUnavailableView(
                "Unable to Load Profile",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
            .background(Color(uiColor: .systemGroupedBackground))
        } else {
            profileContent
        }
    }

    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Profile header with avatar and name
                if let user = viewModel.user {
                    ProfileHeader(user: user)
                }

                // Stats row
                StatsRow(
                    questionsAnswered: viewModel.questionsAnswered,
                    streakDays: viewModel.streak?.currentStreak ?? 0,
                    friendCount: viewModel.user?.friendCount ?? 0
                )

                // Streak calendar
                StreakCalendar(
                    weeklyDays: viewModel.weeklyStreakDays,
                    todayIndex: viewModel.todayWeekdayIndex
                )

                // Spicy takes section
                if !viewModel.spicyTakes.isEmpty {
                    SpicyTakesSection(takes: viewModel.spicyTakes)
                }

                // Awards section
                AwardsBadgeView(awards: viewModel.awards)

                // Sign out button
                signOutButton

                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(role: .destructive) {
            // Sign out action -- placeholder for auth integration
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.body.weight(.medium))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.body.weight(.medium))
            }
        }
    }

    // MARK: - Settings Sheet

    @ViewBuilder
    private var settingsSheet: some View {
        if let settingsRepository = settingsRepository {
            SettingsView(
                viewModel: SettingsViewModel(
                    settingsRepository: settingsRepository,
                    notificationService: notificationService,
                    subscriptionService: subscriptionService,
                    analyticsService: analyticsService
                )
            )
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        } else {
            // Fallback minimal settings if no repository is provided
            NavigationStack {
                Text("Settings unavailable")
                    .foregroundStyle(.secondary)
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showingSettings = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.body.weight(.medium))
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(userProfileService: MockUserProfileService())
    )
    .environment(ThemeManager.shared)
}
#endif
