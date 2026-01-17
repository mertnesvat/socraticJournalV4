// FutureLetterTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
import Foundation
@testable import SocraticJournal

/// Tests for FutureLetter status transitions and time-based unlocking logic
@Suite("FutureLetter Tests")
struct FutureLetterTests {

    // MARK: - isReadyToOpen Tests

    @Suite("isReadyToOpen")
    struct IsReadyToOpenTests {

        @Test("Returns true when delivery date has passed and status is sealed")
        func readyWhenDeliveryDatePassedAndSealed() {
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: pastDate,
                status: .sealed
            )

            #expect(letter.isReadyToOpen == true)
        }

        @Test("Returns false for future delivery date")
        func notReadyForFutureDate() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.isReadyToOpen == false)
        }

        @Test("Returns false when status is read even if delivery date passed")
        func notReadyWhenAlreadyRead() {
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: pastDate,
                status: .read,
                readAt: Date()
            )

            #expect(letter.isReadyToOpen == false)
        }

        @Test("Returns false when status is ready")
        func notReadyWhenStatusIsReady() {
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: pastDate,
                status: .ready
            )

            #expect(letter.isReadyToOpen == false)
        }

        @Test("Returns false when status is archived")
        func notReadyWhenArchived() {
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: pastDate,
                status: .archived
            )

            #expect(letter.isReadyToOpen == false)
        }
    }

    // MARK: - timeRemaining Tests

    @Suite("timeRemaining")
    struct TimeRemainingTests {

        @Test("Shows days when delivery is multiple days away")
        func showsDaysForFutureDate() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining?.contains("day") == true)
        }

        @Test("Shows singular day for exactly one day")
        func showsSingularDayForOneDay() {
            // Add 25 hours to ensure it shows "1 day"
            let futureDate = Calendar.current.date(byAdding: .hour, value: 25, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining == "1 day")
        }

        @Test("Shows plural days for multiple days")
        func showsPluralDaysForMultipleDays() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining?.contains("days") == true)
        }

        @Test("Shows hours when less than a day remains")
        func showsHoursWhenLessThanADay() {
            let futureDate = Calendar.current.date(byAdding: .hour, value: 5, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining?.contains("hour") == true)
        }

        @Test("Shows singular hour for exactly one hour")
        func showsSingularHourForOneHour() {
            let futureDate = Calendar.current.date(byAdding: .minute, value: 65, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining == "1 hour")
        }

        @Test("Shows Soon when very close to delivery")
        func showsSoonWhenVeryClose() {
            let futureDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .sealed
            )

            #expect(letter.timeRemaining == "Soon")
        }

        @Test("Returns nil when delivery date has passed")
        func nilWhenPastDeliveryDate() {
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: pastDate,
                status: .sealed
            )

            #expect(letter.timeRemaining == nil)
        }

        @Test("Returns nil when status is not sealed")
        func nilWhenNotSealed() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .read
            )

            #expect(letter.timeRemaining == nil)
        }

        @Test("Returns nil for ready status")
        func nilForReadyStatus() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .ready
            )

            #expect(letter.timeRemaining == nil)
        }

        @Test("Returns nil for archived status")
        func nilForArchivedStatus() {
            let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            let letter = FutureLetter(
                content: "Test",
                deliveryDate: futureDate,
                status: .archived
            )

            #expect(letter.timeRemaining == nil)
        }
    }

    // MARK: - Status Transition Tests

    @Suite("Status Transitions")
    struct StatusTransitionTests {

        @Test("All expected status cases exist")
        func allStatusCasesExist() {
            let statuses = FutureLetterStatus.allCases

            #expect(statuses.contains(.sealed))
            #expect(statuses.contains(.ready))
            #expect(statuses.contains(.read))
            #expect(statuses.contains(.archived))
            #expect(statuses.count == 4)
        }

        @Test("Status can transition from sealed to ready")
        func sealedToReady() {
            var letter = FutureLetter(
                content: "Test",
                deliveryDate: Date(),
                status: .sealed
            )

            letter.status = .ready

            #expect(letter.status == .ready)
        }

        @Test("Status can transition from ready to read")
        func readyToRead() {
            var letter = FutureLetter(
                content: "Test",
                deliveryDate: Date(),
                status: .ready
            )

            letter.status = .read

            #expect(letter.status == .read)
        }

        @Test("Status can transition from read to archived")
        func readToArchived() {
            var letter = FutureLetter(
                content: "Test",
                deliveryDate: Date(),
                status: .read
            )

            letter.status = .archived

            #expect(letter.status == .archived)
        }

        @Test("Full status lifecycle transitions correctly")
        func fullLifecycleTransition() {
            var letter = FutureLetter(
                content: "Test",
                deliveryDate: Date(),
                status: .sealed
            )

            #expect(letter.status == .sealed)

            letter.status = .ready
            #expect(letter.status == .ready)

            letter.status = .read
            #expect(letter.status == .read)

            letter.status = .archived
            #expect(letter.status == .archived)
        }

        @Test("readAt can be set when marking as read")
        func readAtCanBeSet() {
            var letter = FutureLetter(
                content: "Test",
                deliveryDate: Date(),
                status: .ready
            )

            let readDate = Date()
            letter.status = .read
            letter.readAt = readDate

            #expect(letter.status == .read)
            #expect(letter.readAt == readDate)
        }
    }

    // MARK: - Entity Tests

    @Suite("FutureLetter Entity")
    struct EntityTests {

        @Test("Initializes with correct default values")
        func defaultValues() {
            let deliveryDate = Date()
            let letter = FutureLetter(
                content: "Dear future me...",
                deliveryDate: deliveryDate
            )

            #expect(!letter.id.isEmpty)
            #expect(letter.content == "Dear future me...")
            #expect(letter.deliveryDate == deliveryDate)
            #expect(letter.status == .sealed)
            #expect(letter.readAt == nil)
        }

        @Test("Initializes with all custom values")
        func customValues() {
            let id = "custom-id-123"
            let content = "Custom content"
            let createdAt = Date()
            let deliveryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            let readAt = Date()

            let letter = FutureLetter(
                id: id,
                content: content,
                createdAt: createdAt,
                deliveryDate: deliveryDate,
                status: .read,
                readAt: readAt
            )

            #expect(letter.id == id)
            #expect(letter.content == content)
            #expect(letter.createdAt == createdAt)
            #expect(letter.deliveryDate == deliveryDate)
            #expect(letter.status == .read)
            #expect(letter.readAt == readAt)
        }

        @Test("Conforms to Equatable")
        func equatable() {
            let id = "test-id"
            let now = Date()
            let delivery = Calendar.current.date(byAdding: .day, value: 7, to: now)!

            let letter1 = FutureLetter(
                id: id,
                content: "Test",
                createdAt: now,
                deliveryDate: delivery,
                status: .sealed
            )
            let letter2 = FutureLetter(
                id: id,
                content: "Test",
                createdAt: now,
                deliveryDate: delivery,
                status: .sealed
            )

            #expect(letter1 == letter2)
        }

        @Test("Conforms to Identifiable")
        func identifiable() {
            let letter = FutureLetter(
                id: "unique-id",
                content: "Test",
                deliveryDate: Date()
            )

            #expect(letter.id == "unique-id")
        }
    }

    // MARK: - FutureLetterStatus Tests

    @Suite("FutureLetterStatus")
    struct StatusTests {

        @Test("Status conforms to CaseIterable")
        func caseIterable() {
            let allCases = FutureLetterStatus.allCases

            #expect(allCases.count == 4)
        }

        @Test("Status has correct raw values", arguments: FutureLetterStatus.allCases)
        func rawValues(status: FutureLetterStatus) {
            #expect(!status.rawValue.isEmpty)
        }

        @Test("Status sealed raw value")
        func sealedRawValue() {
            #expect(FutureLetterStatus.sealed.rawValue == "sealed")
        }

        @Test("Status ready raw value")
        func readyRawValue() {
            #expect(FutureLetterStatus.ready.rawValue == "ready")
        }

        @Test("Status read raw value")
        func readRawValue() {
            #expect(FutureLetterStatus.read.rawValue == "read")
        }

        @Test("Status archived raw value")
        func archivedRawValue() {
            #expect(FutureLetterStatus.archived.rawValue == "archived")
        }
    }
}
