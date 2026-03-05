// UserDefaultsProgramProgressRepository.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// UserDefaults-backed implementation of ProgramProgressRepositoryProtocol
public final class UserDefaultsProgramProgressRepository: ProgramProgressRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let progressKey = "com.breathe.programProgress"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    // MARK: - ProgramProgressRepositoryProtocol

    public func getActiveProgram() async throws -> ProgramProgress? {
        guard let data = defaults.data(forKey: progressKey) else { return nil }
        do {
            let progress = try decoder.decode(ProgramProgress.self, from: data)
            return progress.isComplete ? nil : progress
        } catch {
            return nil
        }
    }

    public func startProgram(_ programId: String, totalDays: Int) async throws {
        let progress = ProgramProgress(
            programId: programId,
            currentDay: 1,
            completedDays: [],
            totalDays: totalDays,
            startedAt: Date()
        )
        let data = try encoder.encode(progress)
        defaults.set(data, forKey: progressKey)
    }

    public func completeDay(_ day: Int, for programId: String) async throws {
        guard var progress = try await getStoredProgress() else { return }
        guard progress.programId == programId else { return }
        guard !progress.completedDays.contains(day) else { return }

        progress.completedDays.append(day)
        progress.completedDays.sort()
        progress.lastPracticedAt = Date()

        // Advance currentDay to the next incomplete day
        if day == progress.currentDay {
            var nextDay = progress.currentDay + 1
            while progress.completedDays.contains(nextDay) && nextDay <= progress.totalDays {
                nextDay += 1
            }
            progress.currentDay = nextDay
        }

        let data = try encoder.encode(progress)
        defaults.set(data, forKey: progressKey)
    }

    public func abandonProgram() async throws {
        defaults.removeObject(forKey: progressKey)
    }

    public func getProgress(for programId: String) async throws -> ProgramProgress? {
        guard let progress = try await getStoredProgress() else { return nil }
        return progress.programId == programId ? progress : nil
    }

    // MARK: - Private

    private func getStoredProgress() async throws -> ProgramProgress? {
        guard let data = defaults.data(forKey: progressKey) else { return nil }
        do {
            return try decoder.decode(ProgramProgress.self, from: data)
        } catch {
            return nil
        }
    }
}
