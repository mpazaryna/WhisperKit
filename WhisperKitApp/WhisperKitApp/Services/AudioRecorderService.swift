//
//  AudioRecorderService.swift
//  WhisperKitApp
//
//  Audio recording service for voice capture
//

import AVFoundation
import Foundation

enum AudioRecorderError: Error {
    case recordingFailed(String)
    case permissionDenied
}

@MainActor
@Observable
class AudioRecorderService: NSObject {

    // MARK: - Observable State

    var isRecording = false
    var recordingURL: URL?

    // MARK: - Private

    private var audioRecorder: AVAudioRecorder?

    // MARK: - Recording

    func startRecording() async throws {
        let permission = await requestPermission()
        guard permission else {
            throw AudioRecorderError.permissionDenied
        }

        let url = getRecordingURL()

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
        #endif

        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()

        isRecording = true
        recordingURL = url
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif

        return recordingURL
    }

    // MARK: - Permissions

    private func requestPermission() async -> Bool {
        #if os(macOS)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        default:
            return false
        }
        #else
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        #endif
    }

    // MARK: - Helpers

    private func getRecordingURL() -> URL {
        let filename = "recording_\(Date().timeIntervalSince1970).m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }
}
