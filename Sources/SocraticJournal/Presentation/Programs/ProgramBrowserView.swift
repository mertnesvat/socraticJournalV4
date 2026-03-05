// ProgramBrowserView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Sheet presenting the catalog of guided breathing programs
struct ProgramBrowserView: View {
    @State private var viewModel = ProgramBrowserViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    HairlineDivider()

                    // Program cards
                    ForEach(viewModel.programs) { program in
                        NavigationLink(value: program.id) {
                            ProgramCard(program: program)
                        }
                        .buttonStyle(.plain)
                        HairlineDivider()
                    }
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationDestination(for: String.self) { programId in
                if let program = viewModel.programs.first(where: { $0.id == programId }) {
                    ProgramDetailView(program: program)
                }
            }
            .task {
                viewModel.loadPrograms()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Programs")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Text("Structured paths to better breathing")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.cardPadding)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    ProgramBrowserView()
}
#endif
