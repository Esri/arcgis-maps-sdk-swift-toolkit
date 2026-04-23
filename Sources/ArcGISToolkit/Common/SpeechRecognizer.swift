// Copyright 2026 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Speech

internal import os

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor SpeechRecognizer: Observable {
    // MARK: Public members
    
    /// The complete transcript of the recognized speech.
    @MainActor
    var transcript = ""
    
    /// Initializes a new speech recognizer. If this is the first time you've used the class, it
    /// requests access to the speech recognizer and the microphone.
    init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            log(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.hasPermissionToRecord else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                log(error)
            }
        }
    }
    
    /// Starts speech recognition.
    @MainActor
    func startTranscribing() {
        // Clear the transcript from any previous sessions.
        transcript.removeAll()
        Task {
            await transcribe()
        }
    }
    
    /// Stops speech recognition.
    @MainActor
    func stopTranscribing() {
        Task {
            await reset()
        }
    }
    
    // MARK: Private members
    
    /// The engine to interface with the device's microphone.
    private var audioEngine: AVAudioEngine?
    /// Manages the speech recognition process.
    private let recognizer: SFSpeechRecognizer?
    /// The request to recognize speech from captured audio content.
    private var request: SFSpeechAudioBufferRecognitionRequest?
    /// A task object for monitoring the speech recognition progress.
    private var task: SFSpeechRecognitionTask?
    
    /// Writes information about an error to the log.
    /// - Parameter error: The error to log.
    nonisolated private func log(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Logger.speechToText.error("\(errorMessage)")
    }
    
    /// Creates the engine and request, configures the audio session and finally prepares and starts the
    /// audio engine.
    /// - Returns: The engine and request.
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let engine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = engine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        engine.prepare()
        try engine.start()
        
        return (engine, request)
    }
    
    /// Processes a speech recognition result.
    /// - Parameters:
    ///   - audioEngine: The engine processing the audio.
    ///   - result: A speech recognition result containing the partial or final transcriptions of the audio
    ///   content.
    ///   - error: An error object if a problem occurred. This parameter is nil if speech recognition was
    ///   successful.
    nonisolated private func processResult(
        audioEngine: AVAudioEngine,
        result: SFSpeechRecognitionResult?,
        error: Error?
    ) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString)
        }
    }
    
    /// Reset the speech recognizer.
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            log(error)
        }
    }
    
    /// Begin transcribing audio.
    ///
    /// Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
    /// The resulting transcription is continuously written to the published `transcript` property.
    private func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            log(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.processResult(audioEngine: audioEngine, result: result, error: error)
            })
        } catch {
            reset()
            log(error)
        }
    }
    
    /// Publishes a transcribed message to the actor's observable transcript.
    /// - Parameter message: The message to be published.
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    
    /// A speech recognition error.
    private enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
}

extension AVAudioSession {
    /// A Boolean value indicating whether the user has granted permission to record audio.
    static var hasPermissionToRecord: Bool {
        get async {
            await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { authorized in
                    continuation.resume(returning: authorized)
                }
            }
        }
    }
}

extension Logger {
    /// A logger for the feature form view.
    static var speechToText: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "SpeechToText")
    }
}

extension SFSpeechRecognizer {
    /// A Boolean value indicating whether the user has granted permission to perform speech recognition.
    static var hasAuthorizationToRecognize: Bool {
        get async {
            await withCheckedContinuation { continuation in
                requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }
}
