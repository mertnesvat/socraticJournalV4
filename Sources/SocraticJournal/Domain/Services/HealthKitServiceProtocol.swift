// HealthKitServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Protocol for HealthKit data operations
public protocol HealthKitServiceProtocol: Sendable {
    /// Whether HealthKit is available on this device
    var isAvailable: Bool { get }

    /// Request authorization for the health data types the app uses
    func requestAuthorization() async throws

    /// Save a mindful session to Apple Health
    func saveMindfulSession(startedAt: Date, duration: TimeInterval) async throws

    /// Save respiratory rate from a breath session
    func saveRespiratoryRate(breathsPerMinute: Double, date: Date) async throws

    /// Fetch resting heart rate samples for the last N days
    func fetchRestingHeartRate(lastDays: Int) async throws -> [(date: Date, bpm: Double)]

    /// Fetch HRV (SDNN) samples for the last N days
    func fetchHRV(lastDays: Int) async throws -> [(date: Date, sdnn: Double)]
}

/// HealthKit error cases
public enum HealthKitError: Error {
    case notAvailable
    case authorizationDenied
    case saveFailed(underlying: Error)
}

/// No-op implementation for previews and simulator environments
public struct NoOpHealthKitService: HealthKitServiceProtocol, Sendable {
    public var isAvailable: Bool { false }

    public init() {}

    public func requestAuthorization() async throws {}
    public func saveMindfulSession(startedAt: Date, duration: TimeInterval) async throws {}
    public func saveRespiratoryRate(breathsPerMinute: Double, date: Date) async throws {}
    public func fetchRestingHeartRate(lastDays: Int) async throws -> [(date: Date, bpm: Double)] { [] }
    public func fetchHRV(lastDays: Int) async throws -> [(date: Date, sdnn: Double)] { [] }
}
