import SwiftUI

struct SplashView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var isCompact: Bool { sizeClass == .compact }
    var onBegin: () -> Void
    
    // Animation states
    @State private var circleProgress: CGFloat = 0
    @State private var dotsOpacity: CGFloat = 0
    @State private var starProgress: CGFloat = 0
    @State private var starFill: CGFloat = 0
    @State private var constructionOpacity: CGFloat = 1
    @State private var tessOpacity: CGFloat = 0
    @State private var titleOpacity: CGFloat = 0
    @State private var subtitleOpacity: CGFloat = 0
    @State private var buttonOpacity: CGFloat = 0
    @State private var starPulse: CGFloat = 1.0
    @State private var bgRotation: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cx = size.width / 2
            let cy = size.height * (0.35)
            let radius = min(size.width, size.height) * (0.18)
            
            ZStack {
                // Background
                LinearGradient.tilSimBackground.ignoresSafeArea()
                
                // Tessellation background
                Canvas { context, canvasSize in
                    TessellationRenderer.draw(
                        in: context, size: canvasSize,
                        points: 8, innerRatio: 0.38, cellSize: 80,
                        strokeColor: .tilSimGold.opacity(tessOpacity),
                        fillColor: .clear, lineWidth: 0.5,
                        rotation: .degrees(bgRotation)
                    )
                }
                .ignoresSafeArea()
                
                // === CONSTRUCTION PHASE ===
                
                // Construction circle
                Circle()
                    .trim(from: 0, to: circleProgress)
                    .stroke(Color.tilSimGold.opacity(0.4 * constructionOpacity),
                            style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(.degrees(-90))
                    .position(x: cx, y: cy)
                
                // Guide dots
                ForEach(0..<8, id: \.self) { i in
                    let angle = CGFloat(i) / 8 * .pi * 2 - .pi / 2
                    Circle()
                        .fill(Color.tilSimGold)
                        .frame(width: 5, height: 5)
                        .position(
                            x: cx + radius * cos(angle),
                            y: cy + radius * sin(angle)
                        )
                        .opacity(dotsOpacity * constructionOpacity)
                }
                
                // Radial lines from center
                ForEach(0..<8, id: \.self) { i in
                    let angle = CGFloat(i) / 8 * .pi * 2 - .pi / 2
                    Path { path in
                        path.move(to: CGPoint(x: cx, y: cy))
                        path.addLine(to: CGPoint(
                            x: cx + radius * cos(angle),
                            y: cy + radius * sin(angle)
                        ))
                    }
                    .stroke(Color.tilSimGold.opacity(0.2 * constructionOpacity), lineWidth: 0.5)
                    .opacity(dotsOpacity)
                }
                
                // === STAR PHASE ===
                
                // Star outline drawing itself
                StarShape(points: 8, innerRatio: 0.38)
                    .trim(from: 0, to: starProgress)
                    .stroke(Color.tilSimGold,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                    .scaleEffect(starPulse)
                
                // Star fill
                StarShape(points: 8, innerRatio: 0.38)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.tilSimBlue.opacity(starFill),
                                Color.tilSimDeepBlue.opacity(starFill * 0.7)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                    .scaleEffect(starPulse)
                
                // Golden stroke on filled star
                StarShape(points: 8, innerRatio: 0.38)
                    .stroke(Color.tilSimGold.opacity(starFill), lineWidth: 1.5)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                    .scaleEffect(starPulse)
                
                // === TITLE PHASE ===
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    Text("TILSIM")
                        .font(.system(size: isCompact ? 34 : 44, weight: .ultraLight, design: .serif))
                        .tracking(isCompact ? 14 : 20)
                        .foregroundStyle(
                            LinearGradient.tilSimGoldShimmer
                        )
                        .opacity(titleOpacity)
                        .padding(.bottom, 10)
                    
                    // Decorative line
                    Rectangle()
                        .fill(Color.tilSimGold.opacity(0.3))
                        .frame(width: 120, height: 0.5)
                        .opacity(titleOpacity)
                        .padding(.bottom, 12)
                    
                    Text("The Mathematics of Beauty")
                        .font(.system(size: isCompact ? 11 : 13, weight: .light))
                        .tracking(5)
                        .foregroundStyle(Color.tilSimIvory.opacity(0.6))
                        .opacity(subtitleOpacity)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    // Begin button
                    Button(action: {
                        HapticsEngine.shared.starComplete()
                        onBegin()
                    }) {
                        HStack(spacing: 10) {
                            Text("Begin Journey")
                                .font(.system(size: 14, weight: .medium))
                                .tracking(4)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(Color.tilSimIvory)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .stroke(Color.tilSimGold.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .opacity(buttonOpacity)
                    .accessibilityLabel("Begin Journey")
                    .accessibilityHint("Start exploring the mathematics of Uzbek geometric art")
                    .padding(.bottom, 50)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .onAppear { startAnimation() }
    }
    
    private func startAnimation() {
        let speed: Double = reduceMotion ? 0.3 : 1.0
        
        withAnimation(.easeOut(duration: 1.2 * speed)) { circleProgress = 1.0 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 * speed) {
            withAnimation(.easeIn(duration: 0.4 * speed)) { dotsOpacity = 1.0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 * speed) {
            withAnimation(.easeInOut(duration: 2.0 * speed)) { starProgress = 1.0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5 * speed) {
            withAnimation(.easeIn(duration: 1.0 * speed)) {
                starFill = 0.85
                constructionOpacity = 0
            }
            HapticsEngine.shared.bloom()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0 * speed) {
            withAnimation(.easeIn(duration: 1.5 * speed)) { tessOpacity = 0.12 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5 * speed) {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    starPulse = 1.04
                }
                withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                    bgRotation = 360
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 * speed) {
            withAnimation(.easeIn(duration: 1.0 * speed)) { titleOpacity = 1.0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.8 * speed) {
            withAnimation(.easeIn(duration: 0.7 * speed)) { subtitleOpacity = 1.0 }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5 * speed) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                buttonOpacity = 1.0
            }
            HapticsEngine.shared.constructionStep()
        }
    }
}
