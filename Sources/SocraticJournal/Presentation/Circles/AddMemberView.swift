// AddMemberView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Enhanced Add Member sheet with emoji avatar selection,
/// a live preview of the member card, and remaining slot indicator.
struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddMemberViewModel
    /// Callback invoked after a member is successfully added so the parent can refresh.
    private let onMemberAdded: () -> Void

    init(viewModel: AddMemberViewModel, onMemberAdded: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onMemberAdded = onMemberAdded
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Remaining slots indicator
                    remainingSlotsView

                    // Name input
                    nameSection

                    // Emoji avatar picker
                    emojiAvatarSection

                    // Live preview
                    if !viewModel.trimmedName.isEmpty {
                        previewSection
                    }

                    // Add button
                    addButton

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
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
            .onChange(of: viewModel.didAddMember) { _, didAdd in
                if didAdd {
                    onMemberAdded()
                    dismiss()
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Remaining Slots

    private var remainingSlotsView: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.remainingSlots > 0 ? "person.badge.plus" : "person.fill.xmark")
                .foregroundStyle(viewModel.remainingSlots > 0 ? CircleTheme.warmAmber : .secondary)

            if viewModel.isAtMaxMembers {
                Text("Circle is full (\(viewModel.maxMembers) of \(viewModel.maxMembers) members)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                Text("\(viewModel.remainingSlots) spot\(viewModel.remainingSlots == 1 ? "" : "s") remaining")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CircleTheme.warmBrown)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.isAtMaxMembers
                    ? Color(uiColor: .tertiarySystemFill)
                    : CircleTheme.warmAmber.opacity(0.08))
        )
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Member Name")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            TextField("e.g. Mom, Alex, Jordan", text: $viewModel.memberName)
                .autocorrectionDisabled()
                .textContentType(.name)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                )
        }
    }

    // MARK: - Emoji Avatar Section

    private var emojiAvatarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose an Avatar (optional)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 8),
                spacing: 10
            ) {
                ForEach(AddMemberViewModel.avatarEmojis, id: \.self) { emoji in
                    Button {
                        if viewModel.selectedEmoji == emoji {
                            viewModel.selectedEmoji = nil
                        } else {
                            viewModel.selectedEmoji = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewModel.selectedEmoji == emoji
                                        ? CircleTheme.warmAmber.opacity(0.2)
                                        : Color(uiColor: .tertiarySystemFill))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.selectedEmoji == emoji
                                            ? CircleTheme.warmAmber
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CircleTheme.warmBrown)

            HStack(spacing: 12) {
                // Avatar preview: show emoji if selected, otherwise show initials
                if let emoji = viewModel.selectedEmoji {
                    ZStack {
                        SwiftUI.Circle()
                            .fill(CircleTheme.warmAmber.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Text(emoji)
                            .font(.title2)
                    }
                } else {
                    InitialsAvatarView(
                        initials: previewInitials,
                        size: 48
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.trimmedName)
                        .font(.body.weight(.medium))

                    Text("New member")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
    }

    /// Compute initials from the trimmed name for the preview.
    private var previewInitials: String {
        let components = viewModel.trimmedName
            .split(separator: " ")
            .filter { !$0.isEmpty }

        guard let first = components.first else { return "?" }

        if components.count >= 2, let last = components.last {
            return "\(first.prefix(1).uppercased())\(last.prefix(1).uppercased())"
        }

        return first.prefix(1).uppercased()
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            Task { await viewModel.addMember() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Add to Circle")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: viewModel.isFormValid
                        ? [CircleTheme.warmAmber, CircleTheme.warmOrange]
                        : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
}

#Preview {
    AddMemberView(
        viewModel: {
            let service = MockCircleService()
            let circle = service.circles.first!
            return AddMemberViewModel(circle: circle, circleService: service)
        }(),
        onMemberAdded: {}
    )
}
#endif
