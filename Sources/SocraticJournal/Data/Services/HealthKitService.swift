// HealthKitService.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import Foundation
import HealthKit

/// HealthKit implementation for writing breath sessions and reading cardiovascular metrics
public final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private let store = HKHealthStore()

    public init() {}

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }

        let writeTypes: Set<HKSampleType> = [
            HKCategoryType(.mindfulSession),
            HKQuantityType(.respiratoryRate)
        ]
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.heartRateVariabilitySDNN)
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.saveFailed(underlying: error))
                } else if !success {
                    continuation.resume(throwing: HealthKitError.authorizationDenied)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public func saveMindfulSession(startedAt: Date, duration: TimeInterval) async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }
        let endDate = startedAt.addingTimeInterval(max(duration, 1))
        let sample = HKCategorySample(
            type: HKCategoryType(.mindfulSession),
            value: HKCategoryValue.notApplicable.rawValue,
            start: startedAt,
            end: endDate
        )
        try await save(sample)
    }

    public func saveRespiratoryRate(breathsPerMinute: Double, date: Date) async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let quantity = HKQuantity(unit: unit, doubleValue: breathsPerMinute)
        let sample = HKQuantitySample(
            type: HKQuantityType(.respiratoryRate),
            quantity: quantity,
            start: date,
            end: date
        )
        try await save(sample)
    }

    public func fetchRestingHeartRate(lastDays: Int) async throws -> [(date: Date, bpm: Double)] {
        guard isAvailable else { return [] }
        let type = HKQuantityType(.restingHeartRate)
        let unit = HKUnit.count().unitDivided(by: .minute())
        let samples = try await fetchSamples(type: type, lastDays: lastDays)
        return samples.map { sample in
            (date: sample.startDate, bpm: sample.quantity.doubleValue(for: unit))
        }
    }

    public func fetchHRV(lastDays: Int) async throws -> [(date: Date, sdnn: Double)] {
        guard isAvailable else { return [] }
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        let unit = HKUnit.secondUnit(with: .milli)
        let samples = try await fetchSamples(type: type, lastDays: lastDays)
        return samples.map { sample in
            (date: sample.startDate, sdnn: sample.quantity.doubleValue(for: unit))
        }
    }

    // MARK: - Private Helpers

    private func save(_ sample: HKSample) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { _, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.saveFailed(underlying: error))
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func fetchSamples(type: HKQuantityType, lastDays: Int) async throws -> [HKQuantitySample] {
        let startDate = Calendar.current.date(byAdding: .day, value: -lastDays, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.saveFailed(underlying: error))
                } else {
                    continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
                }
            }
            store.execute(query)
        }
    }
}
#endif
