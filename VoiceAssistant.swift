import Foundation
import Speech
import AVFoundation

@MainActor
final class VoiceAssistant: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isListening = false
    @Published var isThinking = false
    @Published var transcript = ""
    @Published var lastReply = ""

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let speaker = AVSpeechSynthesizer()
    private let sessionId = UUID().uuidString
    private var silenceTimer: Timer?

    override init() {
        super.init()
        speaker.delegate = self
    }

    func start() async {
        let speechOK = await requestSpeechPermission()
        let micOK = await requestMicPermission()
        guard speechOK, micOK else {
            speak("Necesito permiso para usar el micrófono y reconocer tu voz.")
            return
        }
        beginListening()
    }

    func stop() {
        silenceTimer?.invalidate()
        task?.cancel(); task = nil
        request?.endAudio(); request = nil
        if audioEngine.isRunning { audioEngine.stop(); audioEngine.inputNode.removeTap(onBus: 0) }
        isListening = false
        speaker.stopSpeaking(at: .immediate)
    }

    private func beginListening() {
        stopRecognitionOnly()
        transcript = ""
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        request = req
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in self?.request?.append(buffer) }
        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true

        task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    self.resetSilenceTimer()
                    if result.isFinal { await self.submitTranscript() }
                } else if error != nil {
                    self.stopRecognitionOnly()
                }
            }
        }
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false) { [weak self] _ in
            Task { @MainActor in await self?.submitTranscript() }
        }
    }

    private func submitTranscript() async {
        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isThinking else { return }
        stopRecognitionOnly()
        isThinking = true
        do {
            let reply = try await APIClient.ask(text, sessionId: sessionId)
            lastReply = reply
            isThinking = false
            speak(reply)
        } catch {
            isThinking = false
            speak("No he podido conectar con mi cerebro. Revisa el servidor de Midas.")
        }
    }

    private func speak(_ text: String) {
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "es-ES")
        u.rate = 0.49
        u.pitchMultiplier = 0.92
        speaker.speak(u)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.beginListening() }
    }

    private func stopRecognitionOnly() {
        silenceTimer?.invalidate()
        task?.cancel(); task = nil
        request?.endAudio(); request = nil
        if audioEngine.isRunning { audioEngine.stop(); audioEngine.inputNode.removeTap(onBus: 0) }
        isListening = false
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { c in
            SFSpeechRecognizer.requestAuthorization { c.resume(returning: $0 == .authorized) }
        }
    }

    private func requestMicPermission() async -> Bool {
        await withCheckedContinuation { c in
            AVAudioApplication.requestRecordPermission { c.resume(returning: $0) }
        }
    }
}
