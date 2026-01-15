// LetterDetailView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Screen displaying a single letter's details
public struct LetterDetailView: View {
    @State private var viewModel: LetterDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: LetterDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Status header
                        statusHeader

                        // Content card (or locked state)
                        if viewModel.isSealed {
                            sealedContentCard
                        } else {
                            letterContentCard
                        }

                        // Metadata card
                        metadataCard

                        // Archive button (if applicable)
                        if viewModel.canArchive {
                            archiveButton
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Letter Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                viewModel.onArchive = {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.statusIcon)
                .font(.title)
                .foregroundStyle(viewModel.statusColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.statusLabel)
                    .font(.headline)

                if viewModel.isSealed, let timeRemaining = viewModel.timeRemaining {
                    Text("Opens in \(timeRemaining)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if viewModel.isRead, let readDate = viewModel.formattedReadDate {
                    Text("Opened \(readDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(viewModel.statusColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Sealed Content Card

    private var sealedContentCard: some View {
        VStack(spacing: 20) {
            // Lock icon
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .padding(.top, 20)

            Text("This letter is sealed")
                .font(.headline)

            // Countdown timer
            if let time = viewModel.timeRemainingDetailed {
                UnlockCountdown(days: time.days, hours: time.hours, minutes: time.minutes)
            }

            Text("Written on \(viewModel.formattedCreatedDate)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Letter Content Card

    private var letterContentCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "envelope.open.fill")
                    .font(.title3)
                    .foregroundStyle(.accent)

                Text("From Your Past Self")
                    .font(.headline)

                Spacer()
            }

            Divider()

            // Letter content
            Text(viewModel.letter.content)
                .font(.body)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Written date
            HStack {
                Spacer()
                Text("Written \(viewModel.formattedCreatedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Metadata Card

    private var metadataCard: some View {
        VStack(spacing: 0) {
            metadataRow(
                icon: "calendar.badge.plus",
                label: "Created",
                value: viewModel.formattedCreatedDate
            )

            Divider()
                .padding(.leading, 44)

            metadataRow(
                icon: "calendar.badge.clock",
                label: "Delivery Date",
                value: viewModel.formattedDeliveryDate
            )

            if let readDate = viewModel.formattedReadDate {
                Divider()
                    .padding(.leading, 44)

                metadataRow(
                    icon: "envelope.open",
                    label: "Opened",
                    value: readDate
                )
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Archive Button

    private var archiveButton: some View {
        Button {
            Task {
                await viewModel.archiveLetter()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isArchiving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                } else {
                    Image(systemName: "archivebox")
                        .font(.body.weight(.medium))
                }

                Text(viewModel.isArchiving ? "Archiving..." : "Archive Letter")
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.isArchiving)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
            }
        }
    }
}

#Preview("Sealed Letter") {
    let calendar = Calendar.current
    let letter = FutureLetter(
        content: "Dear future me, I hope you're doing well...",
        deliveryDate: calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    )
    return LetterDetailView(
        viewModel: LetterDetailViewModel(
            letter: letter,
            repository: InMemoryJournalRepository()
        )
    )
}

#Preview("Read Letter") {
    var letter = FutureLetter(
        content: "Dear future me, remember this moment of clarity and the insights you gained today. The world may feel uncertain, but your inner wisdom remains constant. Trust in your journey.",
        deliveryDate: Date()
    )
    letter.status = .read
    letter.readAt = Date()

    return LetterDetailView(
        viewModel: LetterDetailViewModel(
            letter: letter,
            repository: InMemoryJournalRepository()
        )
    )
}
#endif
