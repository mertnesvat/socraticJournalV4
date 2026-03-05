// ProgramBrowserView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Browse all available breath programs
public struct ProgramBrowserView: View {
    @State private var viewModel: ProgramBrowserViewModel
    private let progressRepository: ProgramProgressRepositoryProtocol

    public init(progressRepository: ProgramProgressRepositoryProtocol) {
        self.progressRepository = progressRepository
        _viewModel = State(initialValue: ProgramBrowserViewModel(
            progressRepository: progressRepository
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("PROGRAMS")
                        .font(.system(size: 11))
                        .tracking(1.2)
                        .foregroundStyle(AppColors.textTertiary)

                    Text("Guided Journeys")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                        .tracking(-0.3)

                    Text("Multi-day programs to build specific skills")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.cardPadding)

                HairlineDivider()

                // Program list
                ForEach(viewModel.programs) { program in
                    NavigationLink {
                        ProgramDetailView(
                            program: program,
                            progressRepository: progressRepository
                        )
                    } label: {
                        ProgramCard(
                            program: program,
                            isActive: viewModel.isActiveProgram(program.id),
                            progress: viewModel.isActiveProgram(program.id) ? viewModel.activeProgress : nil
                        )
                    }
                    .buttonStyle(.plain)

                    HairlineDivider()
                }

                Spacer(minLength: AppSpacing.sectionGap)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
    }
}

#Preview {
    NavigationStack {
        ProgramBrowserView(
            progressRepository: UserDefaultsProgramProgressRepository()
        )
    }
}
#endif
