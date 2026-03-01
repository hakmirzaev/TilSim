import AVFoundation
import SwiftUI

/// Procedural ambient music using AVAudioEngine — no audio files needed
/// Creates soft harmonic drones that evoke Silk Road mystery
class AmbientEngine {
    static let shared = AmbientEngine()
    
    private var engine: AVAudioEngine?
    private var toneNodes: [AVAudioSourceNode] = []
    private var isPlaying = false
    var isEnabled = true
    
    // Frequencies: D minor pentatonic (mystical, Central Asian feel)
    // D3, F3, G3, A3 → deep ambient drone in D minor
    private let baseFreqs: [Float] = [146.83, 174.61, 196.0, 220.0]
    private var phases: [Float] = [0, 0, 0, 0]
    private var amplitude: Float = 0.0
    
    func start() {
        guard isEnabled, !isPlaying else { return }
        
        do {
            let audioEngine = AVAudioEngine()
            let mainMixer = audioEngine.mainMixerNode
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            
            for i in 0..<baseFreqs.count {
                let freq = baseFreqs[i]
                let phaseIdx = i
                
                let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, buffers -> OSStatus in
                    guard let self else { return noErr }
                    let ptr = buffers.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self)
                    guard let buf = ptr else { return noErr }
                    
                    let sampleRate: Float = 44100
                    for frame in 0..<Int(frameCount) {
                        // Sine wave with slow amplitude modulation
                        let t = self.phases[phaseIdx]
                        let lfo = sin(t * 0.1 * Float(phaseIdx + 1)) * 0.3 + 0.7 // slow wobble
                        let sample = sin(t * 2 * .pi * freq / sampleRate) * self.amplitude * lfo * 0.04
                        buf[frame] = sample
                        self.phases[phaseIdx] += 1.0
                    }
                    return noErr
                }
                
                audioEngine.attach(sourceNode)
                audioEngine.connect(sourceNode, to: mainMixer, format: format)
                toneNodes.append(sourceNode)
            }
            
            try audioEngine.start()
            engine = audioEngine
            isPlaying = true
            
            // Fade in slowly
            DispatchQueue.global(qos: .background).async { [weak self] in
                for step in 0...100 {
                    self?.amplitude = Float(step) / 100.0
                    Thread.sleep(forTimeInterval: 0.03) // 3 second fade in
                }
            }
        } catch {
            // Silently fail — music is optional
        }
    }
    
    func stop() {
        guard isPlaying else { return }
        
        // Fade out
        DispatchQueue.global(qos: .background).async { [weak self] in
            for step in stride(from: 100, through: 0, by: -1) {
                self?.amplitude = Float(step) / 100.0
                Thread.sleep(forTimeInterval: 0.02)
            }
            DispatchQueue.main.async {
                self?.engine?.stop()
                self?.toneNodes.forEach { self?.engine?.detach($0) }
                self?.toneNodes.removeAll()
                self?.engine = nil
                self?.isPlaying = false
                self?.phases = [0, 0, 0, 0]
            }
        }
    }
    
    func toggle() {
        if isPlaying {
            stop()
            isEnabled = false
        } else {
            isEnabled = true
            start()
        }
    }
}
