import SpriteKit
import SwiftUI

/// SpriteKit golden sparkle particle effect — appears during "magic" moments
class SparkleScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 50
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 1.0
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.3
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = UIColor(red: 0.83, green: 0.63, blue: 0.09, alpha: 1)
        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -0.35
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 70
        emitter.particleSpeedRange = 50
        emitter.particleBlendMode = .add
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(emitter)
        
        // Fade out after burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            emitter.particleBirthRate = 0
        }
    }
}

/// SwiftUI wrapper for SpriteKit sparkle effect
struct SparkleView: UIViewRepresentable {
    var size: CGSize = CGSize(width: 300, height: 300)
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.backgroundColor = .clear
        view.allowsTransparency = true
        view.isUserInteractionEnabled = false
        let scene = SparkleScene(size: size)
        scene.backgroundColor = .clear
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}
