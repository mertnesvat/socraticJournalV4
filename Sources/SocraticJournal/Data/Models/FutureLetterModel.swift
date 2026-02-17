// FutureLetterModel.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation
import SwiftData

/// SwiftData persistence model for FutureLetter
@Model
public final class FutureLetterModel {
    @Attribute(.unique) public var id: String
    public var content: String
    public var createdAt: Date
    public var deliveryDate: Date
    public var statusRawValue: String
    public var readAt: Date?

    public init(
        id: String,
        content: String,
        createdAt: Date,
        deliveryDate: Date,
        statusRawValue: String,
        readAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.deliveryDate = deliveryDate
        self.statusRawValue = statusRawValue
        self.readAt = readAt
    }

    /// Converts domain entity to SwiftData model
    public static func from(letter: FutureLetter) -> FutureLetterModel {
        FutureLetterModel(
            id: letter.id,
            content: letter.content,
            createdAt: letter.createdAt,
            deliveryDate: letter.deliveryDate,
            statusRawValue: letter.status.rawValue,
            readAt: letter.readAt
        )
    }

    /// Converts SwiftData model to domain entity
    public func toDomain() -> FutureLetter {
        let status = FutureLetterStatus(rawValue: statusRawValue) ?? .sealed

        return FutureLetter(
            id: id,
            content: content,
            createdAt: createdAt,
            deliveryDate: deliveryDate,
            status: status,
            readAt: readAt
        )
    }
}
