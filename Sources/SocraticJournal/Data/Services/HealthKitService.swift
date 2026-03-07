// HealthKitService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

#if canImport(HealthKit)
import HealthKit

/// HealthKit integration for saving mindful sessions and reading HRV/resting HR
public final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    private let healthStore = HKHealthStore()

    private let writeTypes: Set<HKSampleType> = [
        HKCategoryType(.mindfulSession)
    ]

    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.restingHeartRate)
    ]

    public init() {}

    // MARK: - HealthKitServiceProtocol

    public func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    public func saveMindfulSession(startDate: Date, endDate: Date) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let type = HKCategoryType(.mindfulSession)
        let sample = HKCategorySample(
            type: type,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )
        try await healthStore.save(sample)
    }

    public func fetchLatestHRV() async throws -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        return try await fetchLatestQuantity(type: type, unit: HKUnit.secondUnit(with: .milli))
    }

    public func fetchAverageHRV(days: Int) async throws -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return try await fetchAverage(type: type, unit: HKUnit.secondUnit(with: .milli), since: startDate)
    }

    public func fetchRestingHeartRate() async throws -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let type = HKQuantityType(.restingHeartRate)
        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        return try await fetchLatestQuantity(type: type, unit: bpmUnit)
    }

    // MARK: - Private Helpers

    private func fetchLatestQuantity(type: HKQuantityType, unit: HKUnit) async throws -> Double? {
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let sample = samples?.first as? HKQuantitySample {
                    continuation.resume(returning: sample.quantity.doubleValue(for: unit))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
    }

    private func fetchAverage(type: HKQuantityType, unit: HKUnit, since startDate: Date) async throws -> Double? {
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: Date(),
                options: .strictStartDate
            )
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let value = statistics?.averageQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}

#else

/// Stub implementation when HealthKit is not available (e.g., on simulator / non-iOS)
public final class HealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    public init() {}
    public func isHealthDataAvailable() -> Bool { false }
    public func requestAuthorization() async throws {}
    public func saveMindfulSession(startDate: Date, endDate: Date) async throws {}
    public func fetchLatestHRV() async throws -> Double? { nil }
    public func fetchAverageHRV(days: Int) async throws -> Double? { nil }
    public func fetchRestingHeartRate() async throws -> Double? { nil }
}

#endif
