// CreateProfileView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Onboarding screen that collects the user's display name
/// and creates a local profile via AuthState.
public struct CreateProfileView: View {
    @Bindable private var authState: AuthState
    @State private var displayName: String = ""
    @FocusState private var nameFocused: Bool
    private let analyticsService: AnalyticsServiceProtocol?

    public init(authState: AuthState, analyticsService: AnalyticsServiceProtocol? = nil) {
        self.authState = authState
        self.analyticsService = analyticsService
    }

    private var isNameValid: Bool {
        displayName.trimmingCharacters(in: .whitespaces).count >= 2
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: 12) {
                Text("What should we\ncall you?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Your name is only stored on this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 48)

            // Name field
            TextField("Your name", text: $displayName)
                .font(.title3)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit {
                    if isNameValid { submit() }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            // Get Started button
            Button(action: submit) {
                Group {
                    if authState.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Get Started")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isNameValid ? Color.accentColor : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!isNameValid || authState.isLoading)
            .padding(.horizontal, 32)
            .animation(.easeInOut(duration: 0.2), value: isNameValid)

            Spacer()
        }
        .onAppear { nameFocused = true }
    }

    // MARK: - Private

    private func submit() {
        let name = displayName.trimmingCharacters(in: .whitespaces)
        guard name.count >= 2 else { return }
        Task {
            await authState.createProfile(name: name)
            if authState.isAuthenticated {
                analyticsService?.logEvent(.profileCreated)
            }
        }
    }
}

#Preview {
    CreateProfileView(
        authState: AuthState(service: LocalAuthService())
    )
    .environment(ThemeManager.shared)
}
#endif
