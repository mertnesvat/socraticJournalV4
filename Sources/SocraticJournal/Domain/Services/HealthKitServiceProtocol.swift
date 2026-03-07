// HealthKitServiceProtocol.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// A single HRV (heart rate variability SDNN) data point
public struct HRVSample: Sendable {
    public let date: Date
    public let valueMs: Double

    public init(date: Date, valueMs: Double) {
        self.date = date
        self.valueMs = valueMs
    }
}

/// A single resting heart rate data point
public struct HeartRateSample: Sendable {
    public let date: Date
    public let bpm: Double

    public init(date: Date, bpm: Double) {
        self.date = date
        self.bpm = bpm
    }
}

/// Protocol for HealthKit integration — saving mindful sessions and reading heart health data
public protocol HealthKitServiceProtocol: Sendable {
    /// Whether HealthKit is available on this device (false on iPad without paired watch, simulator, etc.)
    var isAvailable: Bool { get }

    /// Request authorization for reading and writing health data
    func requestAuthorization() async throws

    /// Save a completed breath session as a Mindful Session to Apple Health
    func saveMindfulSession(start: Date, end: Date) async throws

    /// Fetch HRV (SDNN) samples from the past N days, newest first
    func fetchHRVSamples(days: Int) async throws -> [HRVSample]

    /// Fetch resting heart rate samples from the past N days, newest first
    func fetchRestingHeartRate(days: Int) async throws -> [HeartRateSample]
}
