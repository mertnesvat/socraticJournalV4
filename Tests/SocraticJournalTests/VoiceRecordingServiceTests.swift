// VoiceRecordingServiceTests.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Testing
@testable import SocraticJournal

/// Tests for VoiceRecordingService state transitions using the mock implementation
@Suite("Voice Recording Service Tests")
struct VoiceRecordingServiceTests {

    // MARK: - Initial State Tests

    @Suite("Initial State")
    struct InitialStateTests {

        @Test("Initial state is not recording")
        @MainActor
        func initialNotRecording() {
            let service = MockVoiceRecordingService()

            #expect(service.isRecording == false)
        }

        @Test("Initial duration is zero")
        @MainActor
        func initialDurationZero() {
            let service = MockVoiceRecordingService()

            #expect(service.currentDuration == 0)
        }
    }

    // MARK: - Start Recording Tests

    @Suite("Start Recording")
    struct StartRecordingTests {

        @Test("Start recording transitions state to recording")
        @MainActor
        func startRecordingTransitionsState() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()

            #expect(service.isRecording == true)
        }

        @Test("Start recording throws when permission denied")
        @MainActor
        func startRecordingThrowsOnPermissionDenied() {
            let service = MockVoiceRecordingService(permissionStatus: .denied)

            #expect(throws: VoiceRecordingError.self) {
                try service.startRecording()
            }
        }
    }

    // MARK: - Stop Recording Tests

    @Suite("Stop Recording")
    struct StopRecordingTests {

        @Test("Stop recording returns URL when duration is sufficient")
        @MainActor
        func stopRecordingReturnsURL() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            // Manually set duration above minimum (3 seconds)
            service.simulateDuration(5.0)
            let url = service.stopRecording()

            #expect(url != nil)
            #expect(service.isRecording == false)
        }

        @Test("Stop recording returns nil when recording too short")
        @MainActor
        func stopRecordingReturnsNilWhenTooShort() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            // Duration stays at 0, which is below the 3 second minimum
            let url = service.stopRecording()

            #expect(url == nil)
            #expect(service.isRecording == false)
        }

        @Test("Stop recording resets duration to zero")
        @MainActor
        func stopRecordingResetsDuration() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            service.simulateDuration(5.0)
            _ = service.stopRecording()

            #expect(service.currentDuration == 0)
        }
    }

    // MARK: - Cancel Recording Tests

    @Suite("Cancel Recording")
    struct CancelRecordingTests {

        @Test("Cancel recording clears recording state")
        @MainActor
        func cancelRecordingClearsState() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            #expect(service.isRecording == true)

            service.cancelRecording()

            #expect(service.isRecording == false)
            #expect(service.currentDuration == 0)
        }

        @Test("Cancel recording when not recording does nothing")
        @MainActor
        func cancelRecordingWhenNotRecordingIsNoOp() {
            let service = MockVoiceRecordingService()

            service.cancelRecording()

            #expect(service.isRecording == false)
            #expect(service.currentDuration == 0)
        }
    }

    // MARK: - Pause/Resume Tests

    @Suite("Pause and Resume")
    struct PauseResumeTests {

        @Test("Pause recording pauses active recording")
        @MainActor
        func pauseRecording() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            #expect(service.isRecording == true)

            service.pauseRecording()

            // Service is still "recording" (session is active) but paused internally
            #expect(service.isRecording == true)
        }

        @Test("Resume recording after pause continues recording")
        @MainActor
        func resumeAfterPause() throws {
            let service = MockVoiceRecordingService(permissionStatus: .granted)

            try service.startRecording()
            service.pauseRecording()
            service.resumeRecording()

            #expect(service.isRecording == true)
        }

        @Test("Pause when not recording does nothing")
        @MainActor
        func pauseWhenNotRecordingIsNoOp() {
            let service = MockVoiceRecordingService()

            service.pauseRecording()

            #expect(service.isRecording == false)
        }

        @Test("Resume when not paused does nothing")
        @MainActor
        func resumeWhenNotPausedIsNoOp() {
            let service = MockVoiceRecordingService()

            service.resumeRecording()

            #expect(service.isRecording == false)
        }
    }

    // MARK: - Permission Tests

    @Suite("Permissions")
    struct PermissionTests {

        @Test("Permission status returns configured value")
        @MainActor
        func permissionStatusReturnsConfiguredValue() async {
            let service = MockVoiceRecordingService(permissionStatus: .notDetermined)

            let status = await service.permissionStatus

            #expect(status == .notDetermined)
        }

        @Test("Request permission returns true and updates status")
        @MainActor
        func requestPermissionGranted() async {
            let service = MockVoiceRecordingService(permissionStatus: .notDetermined)

            let granted = await service.requestPermission()

            #expect(granted == true)
            let status = await service.permissionStatus
            #expect(status == .granted)
        }
    }
}
