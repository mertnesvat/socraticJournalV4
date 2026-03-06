// HealthKitService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import HealthKit

/// HealthKit integration for writing breathing sessions as Mindful Minutes
/// and reading resting heart rate data.
public final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    public static let shared = HealthKitService()

    private let store = HKHealthStore()

    // Types we write
    private let mindfulSessionType = HKCategoryType(.mindfulSession)

    // Types we read
    private let restingHRType = HKQuantityType(.restingHeartRate)
    private let hrvType = HKQuantityType(.heartRateVariabilitySDNN)

    private init() {}

    // MARK: - HealthKitServiceProtocol

    public func isAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func requestAuthorization() async throws {
        guard isAvailable() else { return }
        let typesToWrite: Set<HKSampleType> = [
            mindfulSessionType,
            HKQuantityType(.heartRateVariabilitySDNN)
        ]
        let typesToRead: Set<HKObjectType> = [
            restingHRType,
            hrvType
        ]
        try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }

    public func isMindfulSessionWriteAuthorized() -> Bool {
        guard isAvailable() else { return false }
        return store.authorizationStatus(for: mindfulSessionType) == .sharingAuthorized
    }

    public func isHRVWriteAuthorized() -> Bool {
        guard isAvailable() else { return false }
        return store.authorizationStatus(for: hrvType) == .sharingAuthorized
    }

    // MARK: - Write

    public func saveMindfulSession(start: Date, end: Date, patternId: String) async throws {
        guard isAvailable(), isMindfulSessionWriteAuthorized() else { return }
        // Skip sessions shorter than 60 seconds
        guard end.timeIntervalSince(start) >= 60 else { return }

        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: false,
            "RumiPatternId": patternId
        ]
        let sample = HKCategorySample(
            type: mindfulSessionType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: metadata
        )
        try await store.save(sample)
    }

    public func saveHRVMarker(date: Date) async throws {
        guard isAvailable(), isHRVWriteAuthorized() else { return }
        let quantity = HKQuantity(unit: HKUnit(from: "ms"), doubleValue: 0.0)
        let metadata: [String: Any] = [
            HKMetadataKeyWasUserEntered: false,
            "RumiEstimated": true,
            "RumiSessionMarker": true
        ]
        let sample = HKQuantitySample(
            type: hrvType,
            quantity: quantity,
            start: date,
            end: date,
            metadata: metadata
        )
        try await store.save(sample)
    }

    // MARK: - Read

    public func fetchLatestRestingHeartRate() async -> Double? {
        guard isAvailable() else { return nil }
        guard store.authorizationStatus(for: restingHRType) != .notDetermined else { return nil }

        return await withCheckedContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: restingHRType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let bpm = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: bpm)
            }
            store.execute(query)
        }
    }
}
#endif
