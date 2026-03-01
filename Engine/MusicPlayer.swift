import AVFoundation
import UIKit

/// Background music player — loops ambient music continuously with fade in/out
class MusicPlayer {
    static let shared = MusicPlayer()
    
    private var player: AVAudioPlayer?
    var isEnabled = true
    
    
    func start() {
        guard isEnabled, player == nil || player?.isPlaying == false else { return }
        
        guard let url = Bundle.main.url(forResource: "background", withExtension: "m4a") else {
            print("MusicPlayer: background.m4a not found in bundle")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0
            player?.prepareToPlay()
            player?.play()
            
            fadeVolume(to: 0.12, duration: 3.0)
        } catch {
            print("MusicPlayer: Failed to play - \(error)")
        }
    }
    
    func stop() {
        fadeVolume(to: 0, duration: 1.5) {
            self.player?.stop()
            self.player = nil
        }
    }
    
    func toggle() {
        if player?.isPlaying == true {
            isEnabled = false
            stop()
        } else {
            isEnabled = true
            start()
        }
    }
    
    private func fadeVolume(to target: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player else { completion?(); return }
        let steps = 30
        let interval = duration / Double(steps)
        let delta = (target - player.volume) / Float(steps)
        
        DispatchQueue.global(qos: .background).async {
            for _ in 0..<steps {
                Thread.sleep(forTimeInterval: interval)
                DispatchQueue.main.async { player.volume += delta }
            }
            DispatchQueue.main.async {
                player.volume = target
                completion?()
            }
        }
    }
}
