// CircleRootView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Root navigation view for the Circle app.
/// Single-stack navigation centered around the daily circle feed.
public struct CircleRootView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(ThemeManager.self) private var themeManager
    @State private var showSettings = false
    @State private var showCreateCircle = false

    public var body: some View {
        NavigationStack {
            CircleHomeView()
                .navigationTitle("Circle")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.body.weight(.medium))
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(
                        viewModel: SettingsViewModel(
                            settingsRepository: services.settingsRepository,
                            notificationService: services.notificationService,
                            subscriptionService: services.subscriptionService,
                            analyticsService: services.analyticsService
                        )
                    )
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
        }
    }
}

// MARK: - Circle Home (Placeholder)

/// Placeholder home screen — will be replaced by the Circle Response Feed in Feature 8.
struct CircleHomeView: View {
    @State private var showCreateCircle = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)

                // Empty state illustration
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(CircleTheme.warmAmber.opacity(0.15))
                            .frame(width: 120, height: 120)

                        Image(systemName: "person.3.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(CircleTheme.warmAmber)
                    }

                    VStack(spacing: 8) {
                        Text("Your Circle Awaits")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Text("Create a circle with 2-5 people you care about.\nOne question. Their voice. Every day.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }

                // Create circle CTA
                Button {
                    showCreateCircle = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Your First Circle")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [CircleTheme.warmAmber, CircleTheme.warmOrange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: CircleTheme.warmAmber.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)

                // Or join
                Text("or join a circle with an invite code")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $showCreateCircle) {
            // Placeholder — will be implemented in Feature 3
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "hammer.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Circle Creation")
                        .font(.headline)
                    Text("Coming in Feature 3")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("New Circle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showCreateCircle = false }
                    }
                }
            }
        }
    }
}

#Preview {
    CircleRootView()
        .environment(ServiceContainer())
        .environment(ThemeManager.shared)
}
#endif
