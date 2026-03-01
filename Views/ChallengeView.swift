import SwiftUI

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var isCompact: Bool { sizeClass == .compact }
    
    private let challenges = Challenge.all
    private var current: Challenge { challenges[currentIndex] }
    private var target: PatternDefinition { current.pattern }
    
    enum ChallengePhase {
        case intro, building, result
    }
    
    var body: some View {
        ZStack {
            LinearGradient.tilSimBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                switch phase {
                case .intro: introPhase
                case .building: buildingPhase
                case .result: resultPhase
                }
            }
        }
    }
    
    // MARK: - Header
    
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
                    Text("\(score)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
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
                        Text("\(streak)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(Color.orange)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Intro Phase
    
    private var introPhase: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(current.difficulty.rawValue.uppercased())
                .font(.system(size: 10, weight: .medium))
                .tracking(4)
                .foregroundStyle(current.difficulty.color)
                .padding(.bottom, 8)
            
            Text("Recreate")
                .font(.system(size: 14, weight: .light))
                .tracking(3)
                .foregroundStyle(Color.tilSimIvory.opacity(0.5))
                .padding(.bottom, 4)
            
            Text(target.name)
                .font(.system(size: isCompact ? 24 : 28, weight: .light, design: .serif))
                .foregroundStyle(Color.tilSimIvory)
                .padding(.bottom, 2)
            
            Text(target.subtitle)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.tilSimGold.opacity(0.5))
                .padding(.bottom, 20)
            
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background))
                TessellationRenderer.drawEnhanced(
                    in: context, size: size,
                    points: target.points, innerRatio: target.innerRatio,
                    cellSize: isCompact ? 50 : 65,
                    palette: target.palette, lineWidth: 0.8,
                    rotation: .degrees(target.rotation + introPatternRotation), showConnections: true
                )
            }
            .frame(width: isCompact ? 220 : 280, height: isCompact ? 220 : 280)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.tilSimGold.opacity(0.15), lineWidth: 0.5))
            .gesture(
                DragGesture()
                    .onChanged { v in
                        introPatternRotation = Double(v.translation.width) * 0.15
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5)) { introPatternRotation = 0 }
                    }
            )
            .padding(.bottom, 20)
            
            VStack(spacing: 4) {
                challengeInfoRow(icon: "circle.grid.cross", label: "Points", unlocked: true)
                challengeInfoRow(icon: "arrow.up.and.down", label: "Depth", unlocked: current.difficulty.stepsUnlocked >= 2)
                challengeInfoRow(icon: "rotate.right", label: "Rotation", unlocked: current.difficulty.stepsUnlocked >= 3)
            }
            .padding(.bottom, 16)
            
            Spacer()
            
            Button(action: {
                HapticsEngine.shared.constructionStep()
                resetUserValues()
                withAnimation(.spring(response: 0.4)) { phase = .building }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "hammer.fill").font(.system(size: 13))
                    Text("Begin Construction").font(.system(size: 14, weight: .medium)).tracking(2)
                }
                .foregroundStyle(Color.tilSimNavy)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.tilSimGold))
            }
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Building Phase
    
    private var buildingPhase: some View {
        VStack(spacing: 0) {
            ZStack {
                Canvas { context, size in
                    context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background))
                    TessellationRenderer.drawEnhanced(
                        in: context, size: size,
                        points: Int(userPoints),
                        innerRatio: CGFloat(userRatio),
                        cellSize: isCompact ? 45 : 60,
                        palette: target.palette, lineWidth: 1,
                        rotation: .degrees(userRotation), showConnections: true
                    )
                }
                
                if showGhost {
                    Canvas { context, size in
                        TessellationRenderer.drawEnhanced(
                            in: context, size: size,
                            points: target.points,
                            innerRatio: target.innerRatio,
                            cellSize: isCompact ? 45 : 60,
                            palette: PatternPalette(
                                id: "ghost", name: "Ghost",
                                background: .clear,
                                primary: .white, secondary: .white,
                                accent: .white, stroke: .white
                            ),
                            lineWidth: 0.4,
                            rotation: .degrees(target.rotation), showConnections: false
                        )
                    }
                    .opacity(0.15)
                    .allowsHitTesting(false)
                }
                
                // Live match indicator
                VStack {
                    HStack {
                        Spacer()
                        let match = calculateMatch()
                        Text("\(Int(match * 100))%")
                            .font(.system(size: 16, weight: .light, design: .monospaced))
                            .foregroundStyle(match >= 0.85 ? .green : Color.tilSimGold.opacity(0.6))
                            .padding(10)
                            .background(Circle().fill(.ultraThinMaterial))
                            .padding(12)
                    }
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)
            
            VStack(spacing: 10) {
                HStack {
                    Button(action: { withAnimation { showGhost.toggle() }; HapticsEngine.shared.tap() }) {
                        HStack(spacing: 4) {
                            Image(systemName: showGhost ? "eye.fill" : "eye.slash")
                                .font(.system(size: 11))
                            Text("Guide")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(1)
                        }
                        .foregroundStyle(Color.white.opacity(showGhost ? 0.6 : 0.3))
                    }
                    
                    Spacer()
                    
                    Button(action: { withAnimation { showHint.toggle() }; HapticsEngine.shared.tap() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill").font(.system(size: 10))
                            Text("Hint").font(.system(size: 10, weight: .medium)).tracking(1)
                        }
                        .foregroundStyle(Color.tilSimGold.opacity(0.5))
                    }
                }
                
                if showHint {
                    Text(current.hint)
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .italic()
                        .foregroundStyle(Color.tilSimGold.opacity(0.6))
                        .transition(.opacity)
                        .padding(.bottom, 4)
                }
                
                stepControl(
                    step: 1,
                    label: "Points",
                    value: "\(Int(userPoints))",
                    binding: $userPoints,
                    range: 4...12,
                    stepSize: 1,
                    unlocked: true,
                    isCorrect: Int(userPoints) == target.points
                )
                
                stepControl(
                    step: 2,
                    label: "Depth",
                    value: "\(Int(userRatio * 100))%",
                    binding: $userRatio,
                    range: 0.15...0.48,
                    stepSize: 0.01,
                    unlocked: current.difficulty.stepsUnlocked >= 2,
                    isCorrect: abs(Double(target.innerRatio) - userRatio) < 0.03
                )
                
                stepControl(
                    step: 3,
                    label: "Rotation",
                    value: "\(Int(userRotation))°",
                    binding: $userRotation,
                    range: 0...45,
                    stepSize: 1,
                    unlocked: current.difficulty.stepsUnlocked >= 3,
                    isCorrect: abs(target.rotation - userRotation) < 3
                )
                
                Button(action: submitAnswer) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 13))
                        Text("Submit").font(.system(size: 13, weight: .medium)).tracking(2)
                    }
                    .foregroundStyle(Color.tilSimNavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.tilSimGold))
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
    }
    
    // MARK: - Result Phase
    
    private var resultPhase: some View {
        let matchPct = calculateMatch()
        let passed = matchPct >= 0.85
        
        return VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                if passed {
                    StarShape(points: target.points, innerRatio: target.innerRatio)
                        .fill(
                            RadialGradient(
                                colors: [target.palette.primary.opacity(0.6), target.palette.background],
                                center: .center, startRadius: 0, endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    StarShape(points: target.points, innerRatio: target.innerRatio)
                        .stroke(Color.tilSimGold, lineWidth: 2)
                        .frame(width: 120, height: 120)
                }
                
            }
            .scaleEffect(resultScale)
            .padding(.bottom, 20)
            
            Text(passed ? "Masterful!" : "Not quite...")
                .font(.system(size: 28, weight: .light, design: .serif))
                .foregroundStyle(Color.tilSimGold)
                .opacity(resultOpacity)
                .padding(.bottom, 8)
            
            Text("\(Int(matchPct * 100))% match")
                .font(.system(size: 40, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(passed ? .green : Color.tilSimTurquoise)
                .opacity(resultOpacity)
                .padding(.bottom, 16)
            
            Group {
                if passed {
                    VStack(spacing: 4) {
                        Text("You've mastered \(target.name)")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(Color.tilSimIvory.opacity(0.7))
                        Text("+\(Int(matchPct * 100)) points")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.tilSimGold)
                    }
                } else {
                    Text("Study the target pattern and try again.\nMatch the guide overlay to the original.")
                        .font(.system(size: 13, weight: .light))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.tilSimIvory.opacity(0.5))
                        .frame(maxWidth: 280)
                }
            }
            .opacity(resultOpacity)
            .padding(.bottom, 20)
            
            HStack(spacing: 12) {
                comparisonTile(label: "TARGET", points: target.points, ratio: target.innerRatio, rot: target.rotation)
                comparisonTile(label: "YOURS", points: Int(userPoints), ratio: CGFloat(userRatio), rot: userRotation)
            }
            .padding(.horizontal, 24)
            .opacity(resultOpacity)
            .padding(.bottom, 20)
            
            Spacer()
            
            HStack(spacing: 16) {
                if !passed {
                    Button(action: {
                        HapticsEngine.shared.tap()
                        withAnimation(.spring(response: 0.3)) { phase = .building }
                    }) {
                        Text("Try Again")
                            .font(.system(size: 13, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(Color.tilSimIvory)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Capsule().stroke(Color.tilSimGold.opacity(0.4), lineWidth: 0.5))
                    }
                }
                
                Button(action: advanceChallenge) {
                    Text(passed ? "Next Challenge" : "Skip")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(passed ? Color.tilSimNavy : Color.tilSimIvory.opacity(0.4))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            passed ? AnyShapeStyle(Color.tilSimGold) : AnyShapeStyle(Color.clear)
                        )
                        .clipShape(Capsule())
                }
            }
            .opacity(resultOpacity)
            .padding(.bottom, 24)
        }
        .onAppear { animateResult(passed: passed) }
    }
    
    // MARK: - Components
    
    private func challengeInfoRow(icon: String, label: String, unlocked: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: unlocked ? icon : "lock.fill")
                .font(.system(size: 11))
                .foregroundStyle(unlocked ? Color.tilSimGold : Color.tilSimIvory.opacity(0.2))
                .frame(width: 16)
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(unlocked ? Color.tilSimIvory.opacity(0.7) : Color.tilSimIvory.opacity(0.2))
            Spacer()
            if unlocked {
                Image(systemName: "checkmark").font(.system(size: 10)).foregroundStyle(Color.green.opacity(0.6))
            }
        }
        .frame(maxWidth: 200)
    }
    
    private func stepControl(step: Int, label: String, value: String, binding: Binding<Double>, range: ClosedRange<Double>, stepSize: Double, unlocked: Bool, isCorrect: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(isCorrect && unlocked ? Color.green : Color.tilSimGold.opacity(unlocked ? 0.4 : 0.1))
                        .frame(width: 6, height: 6)
                    Text(label.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(Color.white.opacity(unlocked ? 0.5 : 0.15))
                }
                Spacer()
                if unlocked {
                    Text(value)
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .foregroundStyle(isCorrect ? Color.green : Color.tilSimGold.opacity(0.8))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.white.opacity(0.15))
                }
            }
            if unlocked {
                Slider(value: binding, in: range, step: stepSize) { editing in
                    if !editing { HapticsEngine.shared.sliderTick() }
                }
                .tint(isCorrect ? .green : Color.tilSimGold)
            }
        }
        .opacity(unlocked ? 1 : 0.4)
        .disabled(!unlocked)
    }
    
    private func comparisonTile(label: String, points: Int, ratio: CGFloat, rot: Double) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.tilSimGold.opacity(0.4))
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(target.palette.background))
                TessellationRenderer.drawEnhanced(
                    in: context, size: size,
                    points: points, innerRatio: ratio,
                    cellSize: 35, palette: target.palette, lineWidth: 0.5,
                    rotation: .degrees(rot), showConnections: true
                )
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tilSimGold.opacity(0.1), lineWidth: 0.5))
            
            HStack(spacing: 12) {
                Text("\(points)pt").font(.system(size: 9, design: .monospaced))
                Text("\(Int(ratio * 100))%").font(.system(size: 9, design: .monospaced))
                Text("\(Int(rot))°").font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(Color.tilSimIvory.opacity(0.4))
        }
    }
    
    // MARK: - Logic
    
    private func calculateMatch() -> CGFloat {
        let pointsDiff = abs(Double(target.points) - userPoints) / 8.0
        var matchScore = 1.0 - pointsDiff * 0.6
        
        if current.difficulty.stepsUnlocked >= 2 {
            let ratioDiff = abs(Double(target.innerRatio) - userRatio) / 0.33
            matchScore -= ratioDiff * 0.25
        }
        if current.difficulty.stepsUnlocked >= 3 {
            let rotDiff = abs(target.rotation - userRotation) / 45.0
            matchScore -= rotDiff * 0.15
        }
        return CGFloat(max(0, min(1, matchScore)))
    }
    
    private func submitAnswer() {
        let match = calculateMatch()
        if match >= 0.85 {
            HapticsEngine.shared.starComplete()
            score += Int(match * 100)
            streak += 1
            completedIds.insert(current.id)
        } else {
            HapticsEngine.shared.tap(.light)
            streak = 0
        }
        resultScale = 0.8
        resultOpacity = 0
        withAnimation(.spring(response: 0.4)) { phase = .result }
    }
    
    private func animateResult(passed: Bool) {
        if passed {
            HapticsEngine.shared.bloom()
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { resultScale = 1.0 }
        withAnimation(.easeIn(duration: 0.6).delay(0.3)) { resultOpacity = 1.0 }
    }
    
    private func advanceChallenge() {
        HapticsEngine.shared.pageTurn()
        let next = (currentIndex + 1) % challenges.count
        withAnimation(.spring(response: 0.4)) {
            currentIndex = next
            phase = .intro
            showHint = false
            showGhost = true
        }
    }
    
    private func resetUserValues() {
        userPoints = Double([4, 5, 6, 7, 9, 10, 11].filter { $0 != target.points }.randomElement() ?? 6)
        userRatio = Double.random(in: 0.2...0.4)
        userRotation = 0
    }
}
