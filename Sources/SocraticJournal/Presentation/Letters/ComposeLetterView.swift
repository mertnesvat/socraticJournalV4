// ComposeLetterView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen for composing a letter to future self
public struct ComposeLetterView: View {
    @State private var viewModel: ComposeLetterViewModel
    @State private var showingExitConfirmation: Bool = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool

    public init(viewModel: ComposeLetterViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Letter to Future Self")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .confirmationDialog(
                "Discard Letter?",
                isPresented: $showingExitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Writing", role: .cancel) {}
            } message: {
                Text("Your letter will be lost if you leave now.")
            }
            .task {
                viewModel.onSaveComplete = {
                    dismiss()
                }
                viewModel.onCancel = {
                    if viewModel.hasUnsavedContent {
                        showingExitConfirmation = true
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header instructions
                headerCard

                // Letter editor
                letterEditorCard

                // Duration selector
                durationSelectorCard

                // Delivery date preview
                deliveryDateCard

                // Save button
                saveButton
                    .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "envelope.badge.person.crop")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)

                Text("Write to Your Future Self")
                    .font(.headline)
            }

            Text("Capture this moment. Your future self will thank you for these words of reflection and wisdom.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Letter Editor Card

    private var letterEditorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Letter")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            TextEditor(text: $viewModel.letterContent)
                .frame(minHeight: 200)
                .padding(12)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
                .focused($isTextEditorFocused)

            // Character counter
            CharacterCounter(status: viewModel.characterCountStatus)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var borderColor: Color {
        if viewModel.isTooLong {
            return .red
        } else if viewModel.isTooShort {
            return .orange
        } else if viewModel.isValidLength {
            return .green.opacity(0.5)
        }
        return Color(uiColor: .separator)
    }

    // MARK: - Duration Selector Card

    private var durationSelectorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When should this letter unlock?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            DurationPicker(selection: $viewModel.selectedDuration)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Delivery Date Card

    private var deliveryDateCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock Date")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.formattedDeliveryDate)
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            isTextEditorFocused = false
            Task {
                await viewModel.saveLetter()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.body.weight(.medium))
                }

                Text(viewModel.isSaving ? "Sealing Letter..." : "Seal & Send to Future")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.canSave ? Color.accentColor : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.canSave)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                isTextEditorFocused = false
                viewModel.cancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }
}

#Preview {
    ComposeLetterView(
        viewModel: ComposeLetterViewModel(
            repository: InMemoryJournalRepository()
        )
    )
}
#endif
