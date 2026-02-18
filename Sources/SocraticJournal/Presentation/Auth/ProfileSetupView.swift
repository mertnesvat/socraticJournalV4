// ProfileSetupView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import PhotosUI
import SwiftUI

/// Profile setup screen shown when no user is signed in.
/// Collects a display name and optional avatar photo.
public struct ProfileSetupView: View {
    @State private var viewModel: ProfileSetupViewModel
    @FocusState private var isNameFocused: Bool

    public init(viewModel: ProfileSetupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                // Header
                headerSection

                // Avatar picker
                avatarSection

                // Name input
                nameSection

                // Continue button
                continueButton

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(CircleTheme.backgroundGradient.ignoresSafeArea())
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task { await viewModel.handlePhotoSelection() }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Welcome to Circle")
                .font(.title.bold())
                .foregroundStyle(CircleTheme.warmBrown)

            Text("Set up your profile so your people\nknow who you are.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var avatarSection: some View {
        let currentInitials = viewModel.initials
        let currentAvatarData = viewModel.avatarImageData

        return VStack(spacing: 12) {
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            ) {
                ZStack(alignment: .bottomTrailing) {
                    InitialsAvatarView(
                        initials: currentInitials,
                        avatarImageData: currentAvatarData,
                        size: 100
                    )

                    // Camera badge
                    ZStack {
                        Circle()
                            .fill(CircleTheme.warmAmber)
                            .frame(width: 30, height: 30)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)

            if currentAvatarData != nil {
                Button("Remove Photo") {
                    viewModel.removePhoto()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Name")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            TextField("e.g. John Doe", text: $viewModel.displayName)
                .textContentType(.name)
                .autocorrectionDisabled()
                .focused($isNameFocused)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isNameFocused ? CircleTheme.warmAmber : Color(uiColor: .separator),
                            lineWidth: isNameFocused ? 2 : 1
                        )
                )
        }
    }

    private var continueButton: some View {
        Button {
            Task { await viewModel.signIn() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Continue")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: viewModel.isValid
                        ? [CircleTheme.warmAmber, CircleTheme.warmOrange]
                        : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: viewModel.isValid ? CircleTheme.warmAmber.opacity(0.3) : .clear,
                radius: 12, x: 0, y: 6
            )
        }
        .disabled(!viewModel.isValid || viewModel.isLoading)
    }
}

#Preview {
    ProfileSetupView(
        viewModel: ProfileSetupViewModel(
            authService: MockAuthService(isSignedIn: false)
        )
    )
}
#endif
