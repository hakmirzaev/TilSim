import CoreHaptics
import UIKit

/// Rich haptic engine using CoreHaptics — makes the device feel alive
class HapticsEngine {
    static let shared = HapticsEngine()
    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool
    
    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        setupEngine()
    }
    
    private func setupEngine() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine?.stoppedHandler = { _ in }
            try engine?.start()
        } catch { }
    }
    
    // MARK: - Simple Taps
    func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    // MARK: - Construction Step — sharp geometric "click"
    func constructionStep() {
        guard supportsHaptics, let engine else { tap(.medium); return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
                ], relativeTime: 0.04, duration: 0.12)
            ]
            try engine.makePlayer(with: CHHapticPattern(events: events, parameters: [])).start(atTime: 0)
        } catch { tap(.medium) }
    }
    
    // MARK: - Bloom — rising cascade for color fill
    func bloom() {
        guard supportsHaptics, let engine else { tap(.heavy); return }
        do {
            var events: [CHHapticEvent] = []
            for i in 0..<8 {
                let t = Float(i) / 7.0
                events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2 + t * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3 + t * 0.5)
                ], relativeTime: TimeInterval(i) * 0.06))
            }
            try engine.makePlayer(with: CHHapticPattern(events: events, parameters: [])).start(atTime: 0)
        } catch { tap(.heavy) }
    }
    
    // MARK: - Star Complete — satisfying deep thud
    func starComplete() {
        guard supportsHaptics, let engine else { tap(.heavy); return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ], relativeTime: 0.05, duration: 0.35)
            ]
            try engine.makePlayer(with: CHHapticPattern(events: events, parameters: [])).start(atTime: 0)
        } catch { tap(.heavy) }
    }
    
    // MARK: - Page Turn — gentle swipe feel
    func pageTurn() {
        guard supportsHaptics, let engine else { tap(.light); return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ], relativeTime: 0.08)
            ]
            try engine.makePlayer(with: CHHapticPattern(events: events, parameters: [])).start(atTime: 0)
        } catch { tap(.light) }
    }
    
    // MARK: - Drag Texture — subtle feedback during gesture
    func dragTexture(intensity: Float = 0.3) {
        guard supportsHaptics, let engine else { return }
        do {
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.25),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ], relativeTime: 0)
            try engine.makePlayer(with: CHHapticPattern(events: [event], parameters: [])).start(atTime: 0)
        } catch { }
    }
    
    // MARK: - Slider Tick — notch feedback for control changes
    func sliderTick() {
        let sel = UISelectionFeedbackGenerator()
        sel.selectionChanged()
    }
}
