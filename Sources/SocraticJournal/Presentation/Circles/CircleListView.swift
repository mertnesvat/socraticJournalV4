// CircleListView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Shows the list of all circles the user belongs to
public struct CircleListView: View {
    @State private var viewModel: CirclesViewModel
    @State private var showingCreateCircle = false
    @State private var selectedCircle: CircleGroup?

    public init(viewModel: CirclesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Circles")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCreateCircle = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingCreateCircle) {
                    CreateCircleView(viewModel: viewModel)
                }
                .navigationDestination(item: $selectedCircle) { circle in
                    CircleDetailView(circle: circle, viewModel: viewModel)
                }
                .task {
                    await viewModel.loadCircles()
                }
                .refreshable {
                    await viewModel.loadCircles()
                }
                .alert("Error", isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("OK") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error?.localizedDescription ?? "")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.circles.isEmpty {
            ProgressView("Loading circles...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.circles.isEmpty {
            emptyState
        } else {
            circleList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("💬")
                .font(.system(size: 72))

            VStack(spacing: 8) {
                Text("No circles yet")
                    .font(.title2.bold())

                Text("Create a circle to start sharing\ndaily moments with people you love")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingCreateCircle = true
            } label: {
                Text("Create Your First Circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    private var circleList: some View {
        List {
            ForEach(viewModel.circles) { circle in
                Button {
                    selectedCircle = circle
                } label: {
                    CircleRowView(circle: circle)
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        await viewModel.deleteCircle(id: viewModel.circles[index].id)
                    }
                }
            }
        }
    }
}

// MARK: - Circle Row

private struct CircleRowView: View {
    let circle: CircleGroup

    var body: some View {
        HStack(spacing: 14) {
            Text(circle.emoji)
                .font(.system(size: 36))
                .frame(width: 52, height: 52)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(circle.memberIds.count) member\(circle.memberIds.count == 1 ? "" : "s")")
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

#Preview {
    CircleListView(
        viewModel: CirclesViewModel(
            repository: LocalCircleRepository(),
            currentUserId: UUID()
        )
    )
    .environment(ThemeManager.shared)
}
#endif
