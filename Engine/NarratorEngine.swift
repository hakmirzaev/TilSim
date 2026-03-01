import AVFoundation

/// Narrator engine — plays pre-recorded ElevenLabs audio for onboarding story.
class NarratorEngine {
    static let shared = NarratorEngine()
    
    private var audioPlayer: AVAudioPlayer?
    var isEnabled = true
    
    /// Play pre-recorded narration for a story page index (0-3)
    func playStoryAudio(index: Int) {
        guard isEnabled else { return }
        stop()
        
        let filename = "story_\(index)"
        
        // Try finding in bundle (resources are processed by SPM)
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp3") {
            play(url: url)
        }
    }
    
    private func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.9
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("NarratorEngine: Failed to play audio - \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func toggle() {
        isEnabled.toggle()
        if !isEnabled { stop() }
    }
}
