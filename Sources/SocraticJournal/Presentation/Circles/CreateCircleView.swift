// CreateCircleView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Form for creating a new circle
public struct CreateCircleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CirclesViewModel
    @State private var circleName = ""
    @State private var selectedEmoji = "💬"
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var createdCircle: CircleGroup?

    private let emojis = [
        "💬", "👨‍👩‍👧", "🏠", "❤️", "🎯",
        "🌟", "🎉", "🏃", "🎵", "📚",
        "🍕", "🌍", "🐾", "✈️", "💪",
        "🌸", "🎮", "🤝", "🌈", "☀️"
    ]

    public init(viewModel: CirclesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var isValid: Bool {
        circleName.trimmingCharacters(in: .whitespaces).count >= 2
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Circle Name") {
                    TextField("e.g. Family, Best Friends", text: $circleName)
                        .submitLabel(.done)
                }

                Section("Choose an Emoji") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 52, height: 52)
                                    .background(
                                        selectedEmoji == emoji
                                            ? Color.accentColor.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedEmoji == emoji ? Color.accentColor : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createCircle()
                    } label: {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isCreating)
                }
            }
        }
    }

    private func createCircle() {
        let name = circleName.trimmingCharacters(in: .whitespaces)
        guard name.count >= 2 else { return }

        isCreating = true
        errorMessage = nil

        Task {
            do {
                _ = try await viewModel.createCircle(name: name, emoji: selectedEmoji)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isCreating = false
        }
    }
}

#Preview {
    CreateCircleView(
        viewModel: CirclesViewModel(
            repository: LocalCircleRepository(),
            currentUserId: UUID()
        )
    )
}
#endif
