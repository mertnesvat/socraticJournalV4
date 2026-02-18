// CircleListView.swift
// Circle
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// View displaying the user's circles with creation and management
struct CircleListView: View {
    @State var viewModel: CircleListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.circles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.circles.isEmpty {
                emptyState
            } else {
                circleList
            }
        }
        .navigationTitle("My Circles")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreateCircle = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $viewModel.showCreateCircle) {
            CreateCircleSheet(viewModel: viewModel)
        }
        .task {
            await viewModel.loadCircles()
        }
        .refreshable {
            await viewModel.loadCircles()
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "circle.hexagongrid")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No circles yet")
                .font(.title2.bold())
            Text("Create a circle with your closest people\nto start sharing daily voice notes.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                viewModel.showCreateCircle = true
            } label: {
                Label("Create Circle", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding()
    }

    private var circleList: some View {
        List {
            ForEach(viewModel.circles) { circle in
                CircleRowView(circle: circle)
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        let circle = viewModel.circles[index]
                        if circle.createdBy == "user-001" {
                            await viewModel.deleteCircle(circle)
                        } else {
                            await viewModel.leaveCircle(circle)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Circle Row

struct CircleRowView: View {
    let circle: Circle

    var body: some View {
        HStack(spacing: 12) {
            Text(circle.emoji)
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.name)
                    .font(.headline)
                Text("\(circle.memberCount) members")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Circle Sheet

struct CreateCircleSheet: View {
    @Bindable var viewModel: CircleListViewModel
    @Environment(\.dismiss) private var dismiss

    private let emojis = ["💬", "👨‍👩‍👧", "❤️", "🏠", "🌟", "🎯", "🤝", "☕️", "🎵", "🌈"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Circle Name") {
                    TextField("e.g., Family, Close Friends", text: $viewModel.newCircleName)
                }

                Section("Pick an Emoji") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button {
                                viewModel.newCircleEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.largeTitle)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        viewModel.newCircleEmoji == emoji
                                            ? Color.blue.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task { await viewModel.createCircle() }
                    }
                    .disabled(viewModel.newCircleName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
#endif
