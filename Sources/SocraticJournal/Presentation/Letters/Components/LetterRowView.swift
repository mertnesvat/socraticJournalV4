// LetterRowView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// A row displaying a letter in the letters list
public struct LetterRowView: View {
    let letter: FutureLetter

    public init(letter: FutureLetter) {
        self.letter = letter
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Status indicator
            statusIndicator

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Preview text
                Text(contentPreview)
                    .font(.subheadline)
                    .foregroundStyle(isLocked ? .secondary : .primary)
                    .lineLimit(2)

                // Date info
                HStack(spacing: 8) {
                    dateLabel
                    statusBadge
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Status Indicator

    private var statusIndicator: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 44, height: 44)

            Image(systemName: statusIcon)
                .font(.body.weight(.medium))
                .foregroundStyle(statusColor)
        }
    }

    // MARK: - Content Preview

    private var contentPreview: String {
        if isLocked {
            return "Sealed letter - opens \(formattedDeliveryDate)"
        }
        let preview = letter.content.prefix(100)
        return preview.count < letter.content.count ? "\(preview)..." : String(preview)
    }

    // MARK: - Date Label

    private var dateLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: dateIcon)
                .font(.caption2)

            Text(dateText)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }

    private var dateIcon: String {
        if isReady {
            return "clock.badge.exclamationmark"
        } else if isLocked {
            return "lock.fill"
        } else {
            return "calendar"
        }
    }

    private var dateText: String {
        if isReady {
            return "Ready to open!"
        } else if isLocked {
            return letter.timeRemaining ?? "Soon"
        } else if let readAt = letter.readAt {
            return "Opened \(formatRelativeDate(readAt))"
        } else {
            return formatRelativeDate(letter.createdAt)
        }
    }

    // MARK: - Status Badge

    @ViewBuilder
    private var statusBadge: some View {
        if letter.status == .archived {
            HStack(spacing: 4) {
                Image(systemName: "archivebox.fill")
                    .font(.caption2)
                Text("Archived")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    // MARK: - Computed Properties

    private var isLocked: Bool {
        letter.status == .sealed && !letter.isReadyToOpen
    }

    private var isReady: Bool {
        letter.status == .ready || (letter.status == .sealed && letter.isReadyToOpen)
    }

    private var statusColor: Color {
        if isReady {
            return .purple
        }
        switch letter.status {
        case .sealed:
            return .orange
        case .ready:
            return .purple
        case .read:
            return .green
        case .archived:
            return .gray
        }
    }

    private var statusIcon: String {
        if isReady {
            return "envelope.badge"
        }
        switch letter.status {
        case .sealed:
            return "lock.fill"
        case .ready:
            return "envelope.badge"
        case .read:
            return "envelope.open.fill"
        case .archived:
            return "archivebox.fill"
        }
    }

    private var formattedDeliveryDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: letter.deliveryDate)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview("Various States") {
    let calendar = Calendar.current

    let sealedLetter = FutureLetter(
        content: "Dear future me, I hope you remember this moment...",
        deliveryDate: calendar.date(byAdding: .month, value: 2, to: Date()) ?? Date()
    )

    var readyLetter = FutureLetter(
        content: "This letter is ready to be opened!",
        deliveryDate: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    )
    readyLetter.status = .ready

    var readLetter = FutureLetter(
        content: "I've already been read and it was wonderful.",
        deliveryDate: calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    )
    readLetter.status = .read
    readLetter.readAt = calendar.date(byAdding: .day, value: -2, to: Date())

    var archivedLetter = FutureLetter(
        content: "I'm now safely archived for posterity.",
        deliveryDate: calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    )
    archivedLetter.status = .archived
    archivedLetter.readAt = calendar.date(byAdding: .month, value: -2, to: Date())

    return ScrollView {
        VStack(spacing: 12) {
            LetterRowView(letter: sealedLetter)
            LetterRowView(letter: readyLetter)
            LetterRowView(letter: readLetter)
            LetterRowView(letter: archivedLetter)
        }
        .padding()
    }
}
#endif
