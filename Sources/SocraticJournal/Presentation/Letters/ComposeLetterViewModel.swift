// ComposeLetterViewModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import SwiftUI

/// Duration options for future letter delivery
public enum LetterDuration: String, CaseIterable, Identifiable {
    case oneWeek = "1 Week"
    case oneMonth = "1 Month"
    case threeMonths = "3 Months"
    case oneYear = "1 Year"

    public var id: String { rawValue }

    /// Calculate delivery date from creation date
    public func deliveryDate(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch self {
        case .oneWeek:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .oneMonth:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .threeMonths:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .oneYear:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }

    /// Short label for display
    public var shortLabel: String {
        switch self {
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .threeMonths: return "3M"
        case .oneYear: return "1Y"
        }
    }
}

/// ViewModel for composing a letter to future self
@Observable
@MainActor
public final class ComposeLetterViewModel {
    // MARK: - Constants

    public static let minCharacters = 20
    public static let maxCharacters = 2000

    // MARK: - State

    var letterContent: String = ""
    var selectedDuration: LetterDuration = .oneMonth
    private(set) var isSaving: Bool = false
    private(set) var error: Error?
    private(set) var didSave: Bool = false

    /// The session ID this letter is linked to (optional)
    private let sessionId: String?

    // MARK: - Computed Properties

    var characterCount: Int {
        letterContent.count
    }

    var isValidLength: Bool {
        characterCount >= Self.minCharacters && characterCount <= Self.maxCharacters
    }

    var isTooShort: Bool {
        characterCount > 0 && characterCount < Self.minCharacters
    }

    var isTooLong: Bool {
        characterCount > Self.maxCharacters
    }

    var canSave: Bool {
        isValidLength && !isSaving
    }

    var hasUnsavedContent: Bool {
        !letterContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var deliveryDate: Date {
        selectedDuration.deliveryDate()
    }

    var formattedDeliveryDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: deliveryDate)
    }

    var remainingCharacters: Int {
        Self.maxCharacters - characterCount
    }

    var characterCountStatus: CharacterCountStatus {
        if characterCount == 0 {
            return .empty
        } else if characterCount < Self.minCharacters {
            return .tooShort(needed: Self.minCharacters - characterCount)
        } else if characterCount > Self.maxCharacters {
            return .tooLong(excess: characterCount - Self.maxCharacters)
        } else {
            return .valid(remaining: remainingCharacters)
        }
    }

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Callbacks

    var onSaveComplete: (() -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - Init

    public init(
        sessionId: String? = nil,
        repository: JournalRepositoryProtocol
    ) {
        self.sessionId = sessionId
        self.repository = repository
    }

    // MARK: - Actions

    /// Save the letter to the repository
    public func saveLetter() async {
        guard canSave else { return }

        isSaving = true
        error = nil

        do {
            let letter = FutureLetter(
                content: letterContent.trimmingCharacters(in: .whitespacesAndNewlines),
                deliveryDate: deliveryDate
            )
            try await repository.saveLetter(letter)
            didSave = true
            onSaveComplete?()
        } catch {
            self.error = error
        }

        isSaving = false
    }

    /// Cancel and discard the letter
    public func cancel() {
        onCancel?()
    }
}

/// Status of character count for display
public enum CharacterCountStatus {
    case empty
    case tooShort(needed: Int)
    case valid(remaining: Int)
    case tooLong(excess: Int)

    public var displayText: String {
        switch self {
        case .empty:
            return "Minimum 20 characters"
        case .tooShort(let needed):
            return "\(needed) more characters needed"
        case .valid(let remaining):
            return "\(remaining) characters remaining"
        case .tooLong(let excess):
            return "\(excess) characters over limit"
        }
    }

    public var color: Color {
        switch self {
        case .empty:
            return .secondary
        case .tooShort:
            return .orange
        case .valid:
            return .secondary
        case .tooLong:
            return .red
        }
    }

    public var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
}
#endif
