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
    private let hrvType = HKQuantityType(.heartRateVariability)

    private init() {}

    // MARK: - HealthKitServiceProtocol

    public func isAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func requestAuthorization() async throws {
        guard isAvailable() else { return }
        let typesToWrite: Set<HKSampleType> = [
            mindfulSessionType,
            HKQuantityType(.heartRateVariability)
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

    public func fetchTotalRumiMindfulMinutes() async -> Double? {
        guard isAvailable() else { return nil }
        guard store.authorizationStatus(for: mindfulSessionType) != .notDetermined else { return nil }

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulSessionType,
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                // Filter to only Rumi-originated samples via metadata key
                let rumiSamples = samples.filter { $0.metadata?["RumiPatternId"] != nil }
                guard !rumiSamples.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }
                let totalMinutes = rumiSamples.reduce(0.0) { acc, sample in
                    acc + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                }
                continuation.resume(returning: totalMinutes)
            }
            store.execute(query)
        }
    }
}
#endif
