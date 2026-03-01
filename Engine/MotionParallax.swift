import CoreMotion
import SwiftUI

/// CoreMotion-based parallax effect — makes patterns feel like they float above the screen
class MotionParallax: ObservableObject {
    private let manager = CMMotionManager()
    @Published var offset = CGSize.zero
    
    func start(sensitivity: Double = 12) {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.offset = CGSize(
                width: data.attitude.roll * sensitivity,
                height: (data.attitude.pitch - 0.5) * sensitivity
            )
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
        offset = .zero
    }
}
