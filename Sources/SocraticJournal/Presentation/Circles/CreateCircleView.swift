// CreateCircleView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Sheet view for creating a new circle.
/// Collects a circle name and emoji icon via a simple form.
struct CreateCircleView: View {
    @Environment(\.dismiss) private var dismiss

    private let circleService: CircleServiceProtocol
    private let onCreated: () async -> Void

    @State private var name: String = ""
    @State private var selectedIcon: String = "heart.fill"
    @State private var isLoading = false
    @State private var error: Error?
    @FocusState private var isNameFocused: Bool

    /// Whether the form is valid for submission.
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(circleService: CircleServiceProtocol, onCreated: @escaping () async -> Void) {
        self.circleService = circleService
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview
                    circlePreview

                    // Name input
                    nameSection

                    // Emoji picker
                    EmojiPickerView(selectedEmoji: $selectedIcon)

                    // Create button
                    createButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error {
                    Text(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sections

    private var circlePreview: some View {
        VStack(spacing: 12) {
            ZStack {
                SwiftUI.Circle()
                    .fill(CircleTheme.warmAmber.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: selectedIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(CircleTheme.warmAmber)
            }

            if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(name.trimmingCharacters(in: .whitespaces))
                    .font(.headline)
                    .foregroundStyle(.primary)
            } else {
                Text("Your Circle")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 8)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Circle Name")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            TextField("e.g. Family, Close Friends", text: $name)
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

    private var createButton: some View {
        Button {
            Task { await createCircle() }
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Circle")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: isValid
                        ? [CircleTheme.warmAmber, CircleTheme.warmOrange]
                        : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: isValid ? CircleTheme.warmAmber.opacity(0.3) : .clear,
                radius: 12, x: 0, y: 6
            )
        }
        .disabled(!isValid || isLoading)
        .padding(.bottom, 16)
    }

    // MARK: - Actions

    private func createCircle() async {
        guard isValid else { return }
        isLoading = true
        error = nil

        do {
            let _ = try await circleService.createCircle(name: name, icon: selectedIcon)
            await onCreated()
            dismiss()
        } catch {
            self.error = error
        }

        isLoading = false
    }
}

#Preview {
    CreateCircleView(
        circleService: MockCircleService(),
        onCreated: {}
    )
}
#endif
