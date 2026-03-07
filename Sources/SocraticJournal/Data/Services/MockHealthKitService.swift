// MockHealthKitService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Mock HealthKit service for simulator and preview builds
public final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
    public var isAvailable: Bool { false }

    public init() {}

    public func requestAuthorization() async throws {}

    public func saveMindfulSession(start: Date, end: Date) async throws {}

    public func fetchHRVSamples(days: Int) async throws -> [HRVSample] { [] }

    public func fetchRestingHeartRate(days: Int) async throws -> [HeartRateSample] { [] }
}
