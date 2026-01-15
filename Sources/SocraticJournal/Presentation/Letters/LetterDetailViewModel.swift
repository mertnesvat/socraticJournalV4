// LetterDetailViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// ViewModel for the letter detail screen
@Observable
@MainActor
public final class LetterDetailViewModel {
    // MARK: - State

    private(set) var letter: FutureLetter
    private(set) var isArchiving: Bool = false
    private(set) var error: Error?

    // MARK: - Computed Properties

    var isSealed: Bool {
        letter.status == .sealed && !letter.isReadyToOpen
    }

    var isReady: Bool {
        letter.status == .ready || (letter.status == .sealed && letter.isReadyToOpen)
    }

    var isRead: Bool {
        letter.status == .read
    }

    var isArchived: Bool {
        letter.status == .archived
    }

    var canArchive: Bool {
        letter.status == .read && !isArchiving
    }

    var statusLabel: String {
        if isSealed {
            return "Sealed"
        } else if isReady {
            return "Ready to Open"
        } else if isRead {
            return "Opened"
        } else {
            return "Archived"
        }
    }

    var statusIcon: String {
        if isSealed {
            return "lock.fill"
        } else if isReady {
            return "envelope.badge"
        } else if isRead {
            return "envelope.open.fill"
        } else {
            return "archivebox.fill"
        }
    }

    var statusColor: Color {
        if isSealed {
            return .orange
        } else if isReady {
            return .purple
        } else if isRead {
            return .green
        } else {
            return .gray
        }
    }

    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: letter.createdAt)
    }

    var formattedDeliveryDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: letter.deliveryDate)
    }

    var formattedReadDate: String? {
        guard let readAt = letter.readAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: readAt)
    }

    var timeRemaining: String? {
        letter.timeRemaining
    }

    var timeRemainingDetailed: (days: Int, hours: Int, minutes: Int)? {
        guard isSealed else { return nil }

        let now = Date()
        if now >= letter.deliveryDate { return nil }

        let components = Calendar.current.dateComponents(
            [.day, .hour, .minute],
            from: now,
            to: letter.deliveryDate
        )

        return (
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0
        )
    }

    /// Preview of content for sealed letters
    var contentPreview: String {
        if isSealed {
            return "This letter is sealed until \(formattedDeliveryDate)"
        }
        return letter.content
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Callbacks

    var onArchive: (() -> Void)?

    // MARK: - Init

    public init(
        letter: FutureLetter,
        repository: JournalRepositoryProtocol
    ) {
        self.letter = letter
        self.repository = repository
    }

    // MARK: - Actions

    public func archiveLetter() async {
        guard canArchive else { return }

        isArchiving = true
        error = nil

        do {
            try await repository.updateLetterStatus(id: letter.id, status: .archived)
            letter.status = .archived
            onArchive?()
        } catch {
            self.error = error
        }

        isArchiving = false
    }
}
#endif
