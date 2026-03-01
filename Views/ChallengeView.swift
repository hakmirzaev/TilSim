import SwiftUI
import Darwin

// MARK: - Challenge Data

struct Challenge: Identifiable {
    let id: String
    let pattern: PatternDefinition
    let difficulty: Difficulty
    let hint: String
    
    enum Difficulty: String, CaseIterable {
        case apprentice = "Apprentice"
        case artisan = "Artisan"
        case master = "Master"
        
        var color: Color {
            switch self {
            case .apprentice: return .green
            case .artisan: return Color.tilSimGold
            case .master: return Color.tilSimTurquoise
            }
        }
        
        var stepsUnlocked: Int {
            switch self {
            case .apprentice: return 1
            case .artisan: return 2
            case .master: return 3
            }
        }
    }
    
    static let all: [Challenge] = {
        let patterns = PatternDefinition.presets
        return [
            Challenge(id: "c1", pattern: patterns[0], difficulty: .apprentice, hint: "The Registan Star has 8 points — the foundation of Timurid geometry."),
            Challenge(id: "c2", pattern: patterns[2], difficulty: .apprentice, hint: "Shah-i-Zinda's lattice uses 6-fold symmetry, like a honeycomb."),
            Challenge(id: "c3", pattern: patterns[1], difficulty: .artisan, hint: "Bibi-Khanym's rosette has 10 points with a wide inner ratio."),
            Challenge(id: "c4", pattern: patterns[3], difficulty: .artisan, hint: "Ulugh Beg's 12-pointed star is tilted 15° — an astronomer's precision."),
            Challenge(id: "c5", pattern: patterns[4], difficulty: .master, hint: "Khiva's pentagon is the rarest symmetry in Islamic art — only 5 points.")
        ]
    }()
}

// MARK: - Challenge View

struct ChallengeView: View {
    @State private var mode: ChallengeMode = .guided
    
    enum ChallengeMode {
        case guided, sandbox
    }
    
    var body: some View {
        ZStack {
            LinearGradient.tilSimBackground.ignoresSafeArea()
            
            switch mode {
            case .guided:
                GuidedChallengeView(onSwitchToSandbox: {
                    withAnimation(.spring(response: 0.4)) { mode = .sandbox }
                })
            case .sandbox:
                SandboxView(onBack: {
                    withAnimation(.spring(response: 0.4)) { mode = .guided }
                })
            }
        }
    }
}

// MARK: - Guided Challenge View

struct GuidedChallengeView: View {
    var onSwitchToSandbox: () -> Void
    
    @State private var currentIndex = 0
    @State private var phase: ChallengePhase = .intro
    @State private var userPoints: Double = 6
    @State private var userRatio: Double = 0.3
    @State private var userRotation: Double = 0
    @State private var showGhost = true
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var completedIds: Set<String> = []
    @State private var showHint = false
    @State private var resultScale: CGFloat = 0.8
    @State private var resultOpacity: CGFloat = 0
    @State private var introPatternRotation: Double = 0
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isCompact: Bool { sizeClass == .compact }
    
    private let challenges = Challenge.all
    private var current: Challenge { challenges[currentIndex] }
    private var target: PatternDefinition { current.pattern }
    
    enum ChallengePhase { case intro, building, result }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            switch phase {
            case .intro: introPhase
            case .building: buildingPhase
            case .result: resultPhase
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                Text("C H A L L E N G E")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(6)
                    .foregroundStyle(Color.tilSimGold.opacity(0.6))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").font(.system(size: 10))
                    Text("\(score)").font(.system(size: 13, weight: .medium, design: .monospaced))
                }
                .foregroundStyle(Color.tilSimGold)
            }
            HStack(spacing: 6) {
                ForEach(Array(challenges.enumerated()), id: \.element.id) { i, c in
                    Circle()
                        .fill(completedIds.contains(c.id) ? c.difficulty.color : i == currentIndex ? Color.tilSimGold.opacity(0.6) : Color.tilSimGold.opacity(0.12))
                        .frame(width: 8, height: 8)
                }
                Spacer()
                if streak > 1 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill").font(.system(size: 10))
                        Text("\(streak)").font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(Color.orange)
                }
            }
        }
        .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 8)
    }
    
    private var introPhase: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(current.difficulty.rawValue.uppercased())
                .font(.system(size: 10, weight: .medium)).tracking(4)
                .foregroundStyle(current.difficulty.color).padding(.bottom, 8)
            Text("Recreate").font(.system(size: 14, weight: .light)).tracking(3)
                .foregroundStyle(Color.tilSimIvory.opacity(0.5)).padding(.bottom, 4)
            Text(target.name)
                .font(.system(size: isCompact ? 24 : 28, weight: .light, design: .serif))
                .foregroundStyle(Color.tilSimIvory).padding(.bottom, 2)
            Text(target.subtitle).font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.tilSimGold.opacity(0.5)).padding(.bottom, 20)
            
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background))
                TessellationRenderer.drawEnhanced(in: context, size: size, points: target.points, innerRatio: target.innerRatio, cellSize: isCompact ? 50 : 65, palette: target.palette, lineWidth: 0.8, rotation: .degrees(target.rotation + introPatternRotation), showConnections: true)
            }
            .frame(width: isCompact ? 220 : 280, height: isCompact ? 220 : 280)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.tilSimGold.opacity(0.15), lineWidth: 0.5))
            .gesture(DragGesture()
                .onChanged { v in introPatternRotation = Double(v.translation.width) * 0.15 }
                .onEnded { _ in withAnimation(.spring(response: 0.5)) { introPatternRotation = 0 } })
            .padding(.bottom, 20)
            
            VStack(spacing: 4) {
                challengeInfoRow(icon: "circle.grid.cross", label: "Points", unlocked: true)
                challengeInfoRow(icon: "arrow.up.and.down", label: "Depth", unlocked: current.difficulty.stepsUnlocked >= 2)
                challengeInfoRow(icon: "rotate.right", label: "Rotation", unlocked: current.difficulty.stepsUnlocked >= 3)
            }
            .padding(.bottom, 16)
            
            Spacer()
            
            // Primary: Open Sandbox, Secondary: Begin Construction
            VStack(spacing: 10) {
                Button(action: {
                    HapticsEngine.shared.tap(.medium)
                    onSwitchToSandbox()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.draw").font(.system(size: 13))
                        Text("Open Sandbox").font(.system(size: 14, weight: .medium)).tracking(2)
                    }
                    .foregroundStyle(Color.tilSimNavy)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.tilSimGold))
                }
                
                Button(action: {
                    HapticsEngine.shared.constructionStep()
                    resetUserValues()
                    withAnimation(.spring(response: 0.4)) { phase = .building }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hammer.fill").font(.system(size: 13))
                        Text("Begin Construction").font(.system(size: 14, weight: .medium)).tracking(2)
                    }
                    .foregroundStyle(Color.tilSimIvory)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 14)
                    .background(Capsule().stroke(Color.tilSimGold.opacity(0.5), lineWidth: 1))
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private var buildingPhase: some View {
        VStack(spacing: 0) {
            ZStack {
                Canvas { context, size in
                    context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background))
                    TessellationRenderer.drawEnhanced(in: context, size: size, points: Int(userPoints), innerRatio: CGFloat(userRatio), cellSize: isCompact ? 45 : 60, palette: target.palette, lineWidth: 1, rotation: .degrees(userRotation), showConnections: true)
                }
                if showGhost {
                    Canvas { context, size in
                        TessellationRenderer.drawEnhanced(in: context, size: size, points: target.points, innerRatio: target.innerRatio, cellSize: isCompact ? 45 : 60, palette: PatternPalette(id: "ghost", name: "Ghost", background: .clear, primary: .white, secondary: .white, accent: .white, stroke: .white), lineWidth: 0.4, rotation: .degrees(target.rotation), showConnections: false)
                    }.opacity(0.15).allowsHitTesting(false)
                }
                VStack { HStack { Spacer(); let match = calculateMatch(); Text("\(Int(match * 100))%").font(.system(size: 16, weight: .light, design: .monospaced)).foregroundStyle(match >= 0.85 ? .green : Color.tilSimGold.opacity(0.6)).padding(10).background(Circle().fill(.ultraThinMaterial)).padding(12) }; Spacer() }
            }.frame(maxHeight: .infinity)
            
            VStack(spacing: 10) {
                HStack {
                    Button(action: { withAnimation { showGhost.toggle() }; HapticsEngine.shared.tap() }) { HStack(spacing: 4) { Image(systemName: showGhost ? "eye.fill" : "eye.slash").font(.system(size: 11)); Text("Guide").font(.system(size: 10, weight: .medium)).tracking(1) }.foregroundStyle(Color.white.opacity(showGhost ? 0.6 : 0.3)) }
                    Spacer()
                    Button(action: { withAnimation { showHint.toggle() }; HapticsEngine.shared.tap() }) { HStack(spacing: 4) { Image(systemName: "lightbulb.fill").font(.system(size: 10)); Text("Hint").font(.system(size: 10, weight: .medium)).tracking(1) }.foregroundStyle(Color.tilSimGold.opacity(0.5)) }
                }
                if showHint { Text(current.hint).font(.system(size: 11, weight: .light, design: .serif)).italic().foregroundStyle(Color.tilSimGold.opacity(0.6)).transition(.opacity).padding(.bottom, 4) }
                stepControl(label: "Points", value: "\(Int(userPoints))", binding: $userPoints, range: 4...12, stepSize: 1, unlocked: true, isCorrect: Int(userPoints) == target.points)
                stepControl(label: "Depth", value: "\(Int(userRatio * 100))%", binding: $userRatio, range: 0.15...0.48, stepSize: 0.01, unlocked: current.difficulty.stepsUnlocked >= 2, isCorrect: abs(Double(target.innerRatio) - userRatio) < 0.03)
                stepControl(label: "Rotation", value: "\(Int(userRotation))°", binding: $userRotation, range: 0...45, stepSize: 1, unlocked: current.difficulty.stepsUnlocked >= 3, isCorrect: abs(target.rotation - userRotation) < 3)
                Button(action: submitAnswer) { HStack(spacing: 6) { Image(systemName: "checkmark.seal.fill").font(.system(size: 13)); Text("Submit").font(.system(size: 13, weight: .medium)).tracking(2) }.foregroundStyle(Color.tilSimNavy).frame(maxWidth: .infinity).padding(.vertical, 12).background(Capsule().fill(Color.tilSimGold)) }.padding(.top, 4)
            }.padding(16).background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)).padding(.horizontal, 12).padding(.bottom, 6)
        }
    }
    
    private var resultPhase: some View {
        let matchPct = calculateMatch(); let passed = matchPct >= 0.85
        return VStack(spacing: 0) {
            Spacer()
            ZStack { if passed { StarShape(points: target.points, innerRatio: target.innerRatio).fill(RadialGradient(colors: [target.palette.primary.opacity(0.6), target.palette.background], center: .center, startRadius: 0, endRadius: 80)).frame(width: 120, height: 120); StarShape(points: target.points, innerRatio: target.innerRatio).stroke(Color.tilSimGold, lineWidth: 2).frame(width: 120, height: 120) } }.scaleEffect(resultScale).padding(.bottom, 20)
            Text(passed ? "Masterful!" : "Not quite...").font(.system(size: 28, weight: .light, design: .serif)).foregroundStyle(Color.tilSimGold).opacity(resultOpacity).padding(.bottom, 8)
            Text("\(Int(matchPct * 100))% match").font(.system(size: 40, weight: .ultraLight, design: .monospaced)).foregroundStyle(passed ? .green : Color.tilSimTurquoise).opacity(resultOpacity).padding(.bottom, 16)
            Group { if passed { VStack(spacing: 4) { Text("You've mastered \(target.name)").font(.system(size: 14, weight: .light)).foregroundStyle(Color.tilSimIvory.opacity(0.7)); Text("+\(Int(matchPct * 100)) points").font(.system(size: 16, weight: .medium, design: .monospaced)).foregroundStyle(Color.tilSimGold) } } else { Text("Study the target pattern and try again.").font(.system(size: 13, weight: .light)).multilineTextAlignment(.center).foregroundStyle(Color.tilSimIvory.opacity(0.5)).frame(maxWidth: 280) } }.opacity(resultOpacity).padding(.bottom, 20)
            HStack(spacing: 12) { comparisonTile(label: "TARGET", points: target.points, ratio: target.innerRatio, rot: target.rotation); comparisonTile(label: "YOURS", points: Int(userPoints), ratio: CGFloat(userRatio), rot: userRotation) }.padding(.horizontal, 24).opacity(resultOpacity).padding(.bottom, 20)
            Spacer()
            HStack(spacing: 16) {
                if !passed { Button(action: { HapticsEngine.shared.tap(); withAnimation(.spring(response: 0.3)) { phase = .building } }) { Text("Try Again").font(.system(size: 13, weight: .medium)).tracking(2).foregroundStyle(Color.tilSimIvory).padding(.horizontal, 24).padding(.vertical, 12).background(Capsule().stroke(Color.tilSimGold.opacity(0.4), lineWidth: 0.5)) } }
                Button(action: advanceChallenge) { Text(passed ? "Next Challenge" : "Skip").font(.system(size: 13, weight: .medium)).tracking(2).foregroundStyle(passed ? Color.tilSimNavy : Color.tilSimIvory.opacity(0.4)).padding(.horizontal, 24).padding(.vertical, 12).background(passed ? AnyShapeStyle(Color.tilSimGold) : AnyShapeStyle(Color.clear)).clipShape(Capsule()) }
            }.opacity(resultOpacity).padding(.bottom, 24)
        }.onAppear { animateResult(passed: passed) }
    }
    
    private func challengeInfoRow(icon: String, label: String, unlocked: Bool) -> some View {
        HStack(spacing: 8) { Image(systemName: unlocked ? icon : "lock.fill").font(.system(size: 11)).foregroundStyle(unlocked ? Color.tilSimGold : Color.tilSimIvory.opacity(0.2)).frame(width: 16); Text(label).font(.system(size: 12, weight: .light)).foregroundStyle(unlocked ? Color.tilSimIvory.opacity(0.7) : Color.tilSimIvory.opacity(0.2)); Spacer(); if unlocked { Image(systemName: "checkmark").font(.system(size: 10)).foregroundStyle(Color.green.opacity(0.6)) } }.frame(maxWidth: 200)
    }
    
    private func stepControl(label: String, value: String, binding: Binding<Double>, range: ClosedRange<Double>, stepSize: Double, unlocked: Bool, isCorrect: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack { HStack(spacing: 4) { Circle().fill(isCorrect && unlocked ? Color.green : Color.tilSimGold.opacity(unlocked ? 0.4 : 0.1)).frame(width: 6, height: 6); Text(label.uppercased()).font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.white.opacity(unlocked ? 0.5 : 0.15)) }; Spacer(); if unlocked { Text(value).font(.system(size: 11, weight: .light, design: .monospaced)).foregroundStyle(isCorrect ? Color.green : Color.tilSimGold.opacity(0.8)) } else { Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(Color.white.opacity(0.15)) } }
            if unlocked { Slider(value: binding, in: range, step: stepSize) { editing in if !editing { HapticsEngine.shared.sliderTick() } }.tint(isCorrect ? .green : Color.tilSimGold) }
        }.opacity(unlocked ? 1 : 0.4).disabled(!unlocked)
    }
    
    private func comparisonTile(label: String, points: Int, ratio: CGFloat, rot: Double) -> some View {
        VStack(spacing: 4) { Text(label).font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.tilSimGold.opacity(0.4)); Canvas { context, size in context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background)); TessellationRenderer.drawEnhanced(in: context, size: size, points: points, innerRatio: ratio, cellSize: 35, palette: target.palette, lineWidth: 0.5, rotation: .degrees(rot), showConnections: true) }.frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tilSimGold.opacity(0.1), lineWidth: 0.5)); HStack(spacing: 12) { Text("\(points)pt").font(.system(size: 9, design: .monospaced)); Text("\(Int(ratio * 100))%").font(.system(size: 9, design: .monospaced)); Text("\(Int(rot))°").font(.system(size: 9, design: .monospaced)) }.foregroundStyle(Color.tilSimIvory.opacity(0.4)) }
    }
    
    private func calculateMatch() -> CGFloat {
        let pointsDiff = abs(Double(target.points) - userPoints) / 8.0
        var s = 1.0 - pointsDiff * 0.6
        if current.difficulty.stepsUnlocked >= 2 { s -= abs(Double(target.innerRatio) - userRatio) / 0.33 * 0.25 }
        if current.difficulty.stepsUnlocked >= 3 { s -= abs(target.rotation - userRotation) / 45.0 * 0.15 }
        return CGFloat(max(0, min(1, s)))
    }
    private func submitAnswer() { let match = calculateMatch(); if match >= 0.85 { HapticsEngine.shared.starComplete(); score += Int(match * 100); streak += 1; completedIds.insert(current.id) } else { HapticsEngine.shared.tap(.light); streak = 0 }; resultScale = 0.8; resultOpacity = 0; withAnimation(.spring(response: 0.4)) { phase = .result } }
    private func animateResult(passed: Bool) { if passed { HapticsEngine.shared.bloom() }; withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { resultScale = 1.0 }; withAnimation(.easeIn(duration: 0.6).delay(0.3)) { resultOpacity = 1.0 } }
    private func advanceChallenge() { HapticsEngine.shared.pageTurn(); withAnimation(.spring(response: 0.4)) { currentIndex = (currentIndex + 1) % challenges.count; phase = .intro; showHint = false; showGhost = true } }
    private func resetUserValues() { userPoints = Double([4, 5, 6, 7, 9, 10, 11].filter { $0 != target.points }.randomElement() ?? 6); userRatio = Double.random(in: 0.2...0.4); userRotation = 0 }
}

// MARK: - Sandbox Stroke Model

struct SandboxStroke {
    var points: [CGPoint]
    var color: Color
}

// MARK: - Symmetry Mirror Sandbox

struct SandboxView: View {
    var onBack: () -> Void
    
    @State private var strokes: [SandboxStroke] = []
    @State private var currentStroke: [CGPoint] = []
    @State private var symmetryCount: Int = 8
    @State private var strokeWidth: Double = 3
    @State private var selectedPaletteIndex: Int = 0
    @State private var strokeColor: Color = .tilSimGold
    @State private var showControls = true
    @State private var showSavedToast = false
    @State private var showGuides = true
    @State private var canvasSize: CGSize = .zero
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isCompact: Bool { sizeClass == .compact }
    private var palette: PatternPalette { PatternPalette.all[selectedPaletteIndex] }
    
    var body: some View {
        GeometryReader { geo in
            sandboxContent(center: CGPoint(x: geo.size.width / 2, y: geo.size.height / 2))
                .onAppear { canvasSize = geo.size }
                .onChange(of: geo.size) { _, newSize in canvasSize = newSize }
        }
    }
    
    @ViewBuilder
    private func sandboxContent(center: CGPoint) -> some View {
        ZStack {
            Color(palette.background).ignoresSafeArea()
            sandboxDrawingCanvas
            if strokes.isEmpty && currentStroke.isEmpty {
                sandboxEmptyHint(center: center)
            }
            sandboxHeaderOverlay
            if showSavedToast {
                sandboxSavedToast
            }
        }
    }
    
    private var sandboxDrawingCanvas: some View {
        Canvas { context, size in
            sandboxDraw(in: context, size: size)
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { v in
                    currentStroke.append(v.location)
                    if currentStroke.count % 3 == 0 {
                        HapticsEngine.shared.dragTexture(intensity: 0.15)
                    }
                }
                .onEnded { _ in
                    if currentStroke.count >= 2 {
                        strokes.append(SandboxStroke(points: currentStroke, color: strokeColor))
                    }
                    currentStroke = []
                }
        )
    }
    
    private func sandboxDraw(in context: GraphicsContext, size: CGSize) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let r = min(size.width, size.height) * 0.42
        
        if showGuides {
            let circleRect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
            context.stroke(Path(ellipseIn: circleRect), with: .color(palette.accent.opacity(0.08)), lineWidth: 1)
            for i in 0..<symmetryCount {
                let angle = Double(i) / Double(symmetryCount) * .pi * 2 - .pi / 2
                var line = Path()
                line.move(to: c)
                line.addLine(to: CGPoint(x: c.x + r * Darwin.cos(angle), y: c.y + r * Darwin.sin(angle)))
                context.stroke(line, with: .color(palette.accent.opacity(i == 0 ? 0.2 : 0.06)), lineWidth: i == 0 ? 1 : 0.5)
            }
        }
        
        // Draw completed strokes (each with its own color)
        for stroke in strokes {
            guard stroke.points.count >= 2 else { continue }
            drawSymmetricStroke(stroke.points, color: stroke.color, in: context, center: c)
        }
        
        // Draw current in-progress stroke
        if currentStroke.count >= 2 {
            drawSymmetricStroke(currentStroke, color: strokeColor, in: context, center: c)
        }
    }
    
    private func drawSymmetricStroke(_ points: [CGPoint], color: Color, in context: GraphicsContext, center c: CGPoint) {
        let relativePoints = points.map { CGPoint(x: $0.x - c.x, y: $0.y - c.y) }
        for i in 0..<symmetryCount {
            let angle = Double(i) / Double(symmetryCount) * .pi * 2
            let rotatedPath = buildSmoothPath(from: relativePoints.map { rotatePoint($0, by: angle) }, center: c)
            context.stroke(rotatedPath, with: .color(color), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
        }
    }
    
    private func sandboxEmptyHint(center: CGPoint) -> some View {
        VStack(spacing: 8) {
            Text("Draw inside the circle")
                .font(.system(size: 14, weight: .light))
                .tracking(2)
                .foregroundStyle(Color.tilSimIvory.opacity(0.25))
            Text("Your strokes mirror across \(symmetryCount) axes")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(Color.tilSimIvory.opacity(0.15))
        }
        .position(x: center.x, y: center.y)
        .allowsHitTesting(false)
    }
    
    private var sandboxHeaderOverlay: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { HapticsEngine.shared.tap(); onBack() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 12))
                        Text("Challenges").font(.system(size: 12, weight: .medium)).tracking(1)
                    }
                    .foregroundStyle(Color.tilSimGold.opacity(0.7))
                }
                Spacer()
                Text("S A N D B O X")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(Color.tilSimGold.opacity(0.5))
                Spacer()
                Button(action: { withAnimation(.spring(response: 0.3)) { showControls.toggle() }; HapticsEngine.shared.tap() }) {
                    Image(systemName: showControls ? "chevron.down.circle.fill" : "slider.horizontal.3")
                        .foregroundStyle(Color.tilSimGold.opacity(0.7)).font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16).padding(.top, 12)
            Spacer()
            if showControls {
                sandboxControls.transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var sandboxSavedToast: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Design saved to Photos").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.white)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(Capsule().fill(.ultraThinMaterial))
            .padding(.top, 60)
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var sandboxControls: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // Symmetry picker
            HStack(spacing: 0) {
                Text("SYMMETRY").font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.white.opacity(0.4))
                Spacer()
                Text("\(symmetryCount)-fold").font(.system(size: 11, weight: .light, design: .monospaced)).foregroundStyle(Color.tilSimGold.opacity(0.8))
            }
            HStack(spacing: 8) {
                ForEach([4, 5, 6, 8, 10, 12], id: \.self) { n in
                    Button(action: { symmetryCount = n; HapticsEngine.shared.sliderTick() }) {
                        Text("\(n)")
                            .font(.system(size: 13, weight: n == symmetryCount ? .medium : .light, design: .monospaced))
                            .foregroundStyle(n == symmetryCount ? Color.tilSimGold : Color.white.opacity(0.4))
                            .frame(width: 36, height: 32)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(n == symmetryCount ? Color.tilSimGold.opacity(0.15) : Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(n == symmetryCount ? Color.tilSimGold.opacity(0.5) : Color.clear, lineWidth: 1)))
                    }
                }
                Spacer()
            }
            
            // Stroke width
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("STROKE").font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.white.opacity(0.4))
                    Spacer()
                    Text("\(Int(strokeWidth))px").font(.system(size: 11, weight: .light, design: .monospaced)).foregroundStyle(Color.tilSimGold.opacity(0.8))
                }
                Slider(value: $strokeWidth, in: 1...8, step: 0.5) { editing in
                    if !editing { HapticsEngine.shared.sliderTick() }
                }.tint(Color.tilSimGold)
            }
            
            // Palette + actions
            HStack(spacing: 6) {
                ForEach(Array(PatternPalette.all.enumerated()), id: \.element.id) { idx, pal in
                    Button(action: { selectedPaletteIndex = idx; HapticsEngine.shared.sliderTick() }) {
                        Circle().fill(pal.stroke)
                            .frame(width: 20, height: 20)
                            .overlay(Circle().stroke(idx == selectedPaletteIndex ? Color.tilSimGold : Color.clear, lineWidth: 2))
                    }
                }
                
                ColorPicker("", selection: $strokeColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 28, height: 28)
                
                Spacer()
                
                Button(action: { withAnimation { showGuides.toggle() }; HapticsEngine.shared.tap() }) {
                    Image(systemName: showGuides ? "eye.fill" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                
                Button(action: undoLast) {
                    Image(systemName: "arrow.uturn.backward").font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(strokes.isEmpty ? 0.2 : 0.6))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }.disabled(strokes.isEmpty)
                
                Button(action: clearAll) {
                    Image(systemName: "trash").font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(strokes.isEmpty ? 0.2 : 0.6))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }.disabled(strokes.isEmpty)
                
                Button(action: saveDesign) {
                    Image(systemName: "square.and.arrow.down").font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(strokes.isEmpty ? 0.2 : 0.6))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.tilSimGold.opacity(0.2)))
                }.disabled(strokes.isEmpty)
            }
        }
        .padding(isCompact ? 14 : 18)
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.3), radius: 20, y: -5))
        .padding(.horizontal, 16).padding(.bottom, 8)
    }
    
    // MARK: - Geometry helpers
    
    private func rotatePoint(_ pt: CGPoint, by angle: Double) -> CGPoint {
        let cos_a = Darwin.cos(angle), sin_a = Darwin.sin(angle)
        return CGPoint(x: pt.x * cos_a - pt.y * sin_a, y: pt.x * sin_a + pt.y * cos_a)
    }
    
    private func reflectAndRotate(_ pt: CGPoint, axis angle: Double) -> CGPoint {
        let cos2a = Darwin.cos(2 * angle), sin2a = Darwin.sin(2 * angle)
        return CGPoint(x: pt.x * cos2a + pt.y * sin2a, y: pt.x * sin2a - pt.y * cos2a)
    }
    
    private func buildSmoothPath(from points: [CGPoint], center: CGPoint) -> Path {
        Path { path in
            let abs = points.map { CGPoint(x: $0.x + center.x, y: $0.y + center.y) }
            guard abs.count >= 2 else { return }
            path.move(to: abs[0])
            if abs.count == 2 {
                path.addLine(to: abs[1])
                return
            }
            // Catmull-Rom to cubic Bézier conversion for smooth curves
            for i in 0..<abs.count - 1 {
                let p0 = abs[max(i - 1, 0)]
                let p1 = abs[i]
                let p2 = abs[min(i + 1, abs.count - 1)]
                let p3 = abs[min(i + 2, abs.count - 1)]
                let cp1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6.0,
                                  y: p1.y + (p2.y - p0.y) / 6.0)
                let cp2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6.0,
                                  y: p2.y - (p3.y - p1.y) / 6.0)
                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }
        }
    }
    
    private func undoLast() {
        guard !strokes.isEmpty else { return }
        HapticsEngine.shared.tap()
        _ = strokes.removeLast()
    }
    
    private func clearAll() {
        HapticsEngine.shared.tap(.medium)
        strokes.removeAll()
    }
    
    private func saveDesign() {
        HapticsEngine.shared.starComplete()
        let exportSize = CGSize(width: 1200, height: 1200)
        let viewW = canvasSize.width > 0 ? canvasSize.width : UIScreen.main.bounds.width
        let viewH = canvasSize.height > 0 ? canvasSize.height : UIScreen.main.bounds.height
        let renderer = ImageRenderer(
            content: Canvas { context, size in
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(palette.background))
                
                let scaleX = size.width / viewW
                let scaleY = size.height / viewH
                let scale = min(scaleX, scaleY)
                
                for stroke in strokes {
                    guard stroke.points.count >= 2 else { continue }
                    let rel = stroke.points.map { CGPoint(x: ($0.x - viewW / 2) * scale, y: ($0.y - viewH / 2) * scale) }
                    
                    for i in 0..<symmetryCount {
                        let angle = Double(i) / Double(symmetryCount) * .pi * 2
                        let rPath = buildSmoothPath(from: rel.map { rotatePoint($0, by: angle) }, center: c)
                        context.stroke(rPath, with: .color(stroke.color), style: StrokeStyle(lineWidth: strokeWidth * scale, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .frame(width: exportSize.width, height: exportSize.height)
        )
        renderer.scale = 1.0
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        withAnimation(.spring(response: 0.3)) { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { withAnimation { showSavedToast = false } }
    }
}
