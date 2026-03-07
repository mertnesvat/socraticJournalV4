// HealthKitServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for HealthKit integration — saving mindful sessions and reading HRV data
public protocol HealthKitServiceProtocol: Sendable {
    /// Returns true if HealthKit is available on this device
    func isHealthDataAvailable() -> Bool

    /// Requests HealthKit authorization for read (HRV, resting HR) and write (mindful session)
    func requestAuthorization() async throws

    /// Saves a breathing session as a Mindful Minutes entry in Apple Health
    func saveMindfulSession(startDate: Date, endDate: Date) async throws

    /// Returns the most recent HRV (SDNN) value in milliseconds, or nil if unavailable
    func fetchLatestHRV() async throws -> Double?

    /// Returns the average HRV over the past N days, or nil if no data
    func fetchAverageHRV(days: Int) async throws -> Double?

    /// Returns the most recent resting heart rate in BPM, or nil if unavailable
    func fetchRestingHeartRate() async throws -> Double?
}
