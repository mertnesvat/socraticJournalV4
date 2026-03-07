// HealthKitService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import HealthKit

/// Real HealthKit implementation — reads HRV + resting HR, writes mindful sessions
public final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private let store = HKHealthStore()

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public init() {}

    // MARK: - Authorization

    public func requestAuthorization() async throws {
        guard isAvailable else { return }

        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        ]

        try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }

    // MARK: - Write

    public func saveMindfulSession(start: Date, end: Date) async throws {
        guard isAvailable else { return }
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try await store.save(sample)
    }

    // MARK: - Read

    public func fetchHRVSamples(days: Int) async throws -> [HRVSample] {
        guard isAvailable else { return [] }
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return [] }

        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let result = (samples as? [HKQuantitySample] ?? []).map { sample in
                    HRVSample(
                        date: sample.startDate,
                        valueMs: sample.quantity.doubleValue(for: .init(from: "ms"))
                    )
                }
                continuation.resume(returning: result)
            }
            self.store.execute(query)
        }
    }

    public func fetchRestingHeartRate(days: Int) async throws -> [HeartRateSample] {
        guard isAvailable else { return [] }
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return [] }

        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: rhrType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let beatsPerMinute = HKUnit.count().unitDivided(by: .minute())
                let result = (samples as? [HKQuantitySample] ?? []).map { sample in
                    HeartRateSample(
                        date: sample.startDate,
                        bpm: sample.quantity.doubleValue(for: beatsPerMinute)
                    )
                }
                continuation.resume(returning: result)
            }
            self.store.execute(query)
        }
    }
}
#endif
