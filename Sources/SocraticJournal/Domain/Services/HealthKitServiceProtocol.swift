// HealthKitServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Domain-layer abstraction for HealthKit interactions.
/// Keeps the domain decoupled from HealthKit framework types.
public protocol HealthKitServiceProtocol: Sendable {
    /// Returns true if HealthKit is available on this device (false on iPad, simulator)
    func isAvailable() -> Bool

    /// Requests write permission for mindful sessions and read permission for
    /// resting heart rate and HRV. Throws if HealthKit is unavailable.
    func requestAuthorization() async throws

    /// Returns true if the user has granted write authorisation for mindful sessions
    func isMindfulSessionWriteAuthorized() -> Bool

    /// Saves a mindful session sample to HealthKit for the given time range
    func saveMindfulSession(start: Date, end: Date, patternId: String) async throws

    /// Returns the most recent resting heart rate in BPM, or nil if unavailable
    func fetchLatestRestingHeartRate() async -> Double?

    /// Writes an HRV session marker (value 0.0 ms, metadata flagged as estimated)
    /// to Apple Health at the given date. This is a practice marker, not a real HRV measurement.
    func saveHRVMarker(date: Date) async throws

    /// Returns true if write authorisation for HRV has been granted
    func isHRVWriteAuthorized() -> Bool
}
