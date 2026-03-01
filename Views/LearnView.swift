import SwiftUI

struct LearnView: View {
    @State private var currentStep = 0
    @State private var circleProgress: CGFloat = 0
    @State private var divisionOpacity: CGFloat = 0
    @State private var connectProgress: CGFloat = 0
    @State private var starProgress: CGFloat = 0
    @State private var starFill: CGFloat = 0
    @State private var tessOpacity: CGFloat = 0
    @State private var tessCount: Int = 1
    @State private var dragRotation: Double = 0
    @State private var idleRotation: Double = 0
    @State private var idlePulse: CGFloat = 1.0
    @State private var glowOpacity: CGFloat = 0.3
    @State private var showCompletion = false
    @State private var completionScale: CGFloat = 0.8
    @State private var completionOpacity: CGFloat = 0
    
    var onSwitchToCreate: (() -> Void)? = nil
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var isCompact: Bool { sizeClass == .compact }
    private let steps = ConstructionStep.allCases
    
    var body: some View {
        ZStack {
            LinearGradient.tilSimBackground.ignoresSafeArea()
            
            if showCompletion {
                completionView
                    .transition(.opacity)
            } else {
                constructionView
            }
        }
        .onAppear {
            animateStep(0)
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    idleRotation = 3; idlePulse = 1.015; glowOpacity = 0.6
                }
            }
        }
    }
    
    // MARK: - Main Construction View
    
    private var constructionView: some View {
        VStack(spacing: 0) {
            Text("L E A R N")
                .font(.system(size: 14, weight: .medium))
                .tracking(6)
                .foregroundStyle(Color.tilSimGold.opacity(0.6))
                .padding(.top, 12)
            
            GeometryReader { geo in
                let sz = min(geo.size.width, geo.size.height)
                let cx = geo.size.width / 2
                let cy = geo.size.height / 2
                let radius = sz * (isCompact ? 0.25 : 0.28)
                
                ZStack {
                    if currentStep >= 3 {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.tilSimBlue.opacity(glowOpacity * 0.3), .clear],
                                center: .center, startRadius: 0, endRadius: radius * 2
                            ))
                            .frame(width: radius * 4, height: radius * 4)
                            .position(x: cx, y: cy)
                    }
                    
                    if currentStep >= 0 {
                        Circle()
                            .trim(from: 0, to: circleProgress)
                            .stroke(Color.tilSimGold.opacity(0.4), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                            .frame(width: radius * 2, height: radius * 2)
                            .rotationEffect(.degrees(-90))
                            .position(x: cx, y: cy)
                    }
                    
                    if currentStep >= 1 {
                        ForEach(0..<8, id: \.self) { i in
                            let angle = CGFloat(i) / 8.0 * .pi * 2 - .pi / 2
                            Path { p in
                                p.move(to: CGPoint(x: cx, y: cy))
                                p.addLine(to: CGPoint(x: cx + radius * cos(angle), y: cy + radius * sin(angle)))
                            }
                            .stroke(Color.tilSimGold.opacity(0.15 * divisionOpacity), lineWidth: 0.5)
                            
                            Circle()
                                .fill(Color.tilSimGold)
                                .frame(width: 5, height: 5)
                                .position(x: cx + radius * cos(angle), y: cy + radius * sin(angle))
                                .opacity(divisionOpacity)
                        }
                    }
                    
                    if currentStep >= 2 {
                        squarePath(cx: cx, cy: cy, radius: radius, offset: 0)
                            .trim(from: 0, to: min(1, connectProgress * 2))
                            .stroke(Color.tilSimTurquoise.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                        squarePath(cx: cx, cy: cy, radius: radius, offset: 1)
                            .trim(from: 0, to: max(0, (connectProgress - 0.4) / 0.6))
                            .stroke(Color.tilSimGold.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    }
                    
                    if currentStep >= 3 {
                        StarShape(points: 8, innerRatio: 0.38)
                            .fill(Color.tilSimBlue.opacity(starFill))
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: cx, y: cy)
                        StarShape(points: 8, innerRatio: 0.38)
                            .trim(from: 0, to: starProgress)
                            .stroke(Color.tilSimGold, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: cx, y: cy)
                    }
                    
                    if currentStep >= 4 {
                        let cellSize = radius * 1.6
                        ForEach(-tessCount...tessCount, id: \.self) { row in
                            ForEach(-tessCount...tessCount, id: \.self) { col in
                                if !(row == 0 && col == 0) {
                                    ZStack {
                                        StarShape(points: 8, innerRatio: 0.38)
                                            .fill(Color.tilSimBlue.opacity(0.3 * tessOpacity))
                                        StarShape(points: 8, innerRatio: 0.38)
                                            .stroke(Color.tilSimGold.opacity(0.5 * tessOpacity), lineWidth: 1)
                                    }
                                    .frame(width: radius * 2, height: radius * 2)
                                    .position(x: cx + CGFloat(col) * cellSize, y: cy + CGFloat(row) * cellSize)
                                }
                            }
                        }
                    }
                }
                .rotationEffect(reduceMotion ? .zero : .degrees(dragRotation + idleRotation))
                .scaleEffect(reduceMotion ? 1 : idlePulse)
                .gesture(
                    DragGesture()
                        .onChanged { v in
                            dragRotation = Double(v.translation.width) * -0.5
                            HapticsEngine.shared.dragTexture(intensity: 0.2)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { dragRotation = 0 }
                        }
                )
                .accessibilityLabel("Geometric construction, step \(currentStep + 1) of \(steps.count)")
            }
            
            // Info card
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= currentStep ? Color.tilSimGold : Color.tilSimGold.opacity(0.15))
                            .frame(width: i == currentStep ? 24 : 8, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                
                Text(steps[currentStep].title.uppercased())
                    .font(.system(size: isCompact ? 15 : 17, weight: .light, design: .serif))
                    .tracking(5)
                    .foregroundStyle(Color.tilSimGold)
                    .id("lt_\(currentStep)")
                
                Text(steps[currentStep].description)
                    .font(.system(size: isCompact ? 12 : 13, weight: .light))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.tilSimIvory.opacity(0.7))
                    .frame(maxWidth: isCompact ? 300 : 400)
                    .id("ld_\(currentStep)")
                
                HStack(spacing: 24) {
                    Button(action: prevStep) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.tilSimGold.opacity(currentStep > 0 ? 0.8 : 0.2))
                    }
                    .disabled(currentStep == 0)
                    
                    Button(action: nextStep) {
                        HStack(spacing: 6) {
                            Text(currentStep < steps.count - 1 ? "Next" : "Try Creating")
                                .font(.system(size: 13, weight: .medium))
                                .tracking(2)
                            if currentStep < steps.count - 1 {
                                Image(systemName: "chevron.right").font(.system(size: 11))
                            } else {
                                Image(systemName: "arrow.right").font(.system(size: 11))
                            }
                        }
                        .foregroundStyle(currentStep == steps.count - 1 ? Color.tilSimNavy : Color.tilSimIvory)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(currentStep == steps.count - 1 ? Color.tilSimGold : Color.tilSimGold.opacity(0.15))
                                .overlay(Capsule().stroke(Color.tilSimGold.opacity(0.4), lineWidth: 0.5))
                        )
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                StarShape(points: 8, innerRatio: 0.38)
                    .fill(
                        RadialGradient(
                            colors: [Color.tilSimBlue.opacity(0.6), Color.tilSimDeepBlue.opacity(0.3)],
                            center: .center, startRadius: 0, endRadius: 100
                        )
                    )
                    .frame(width: 160, height: 160)
                
                StarShape(points: 8, innerRatio: 0.38)
                    .stroke(Color.tilSimGold, lineWidth: 2)
                    .frame(width: 160, height: 160)
            }
            .scaleEffect(completionScale)
            .padding(.bottom, 32)
            
            Text("MASTERY ACHIEVED")
                .font(.system(size: 14, weight: .medium))
                .tracking(8)
                .foregroundStyle(Color.tilSimGold)
                .opacity(completionOpacity)
                .padding(.bottom, 8)
            
            Rectangle()
                .fill(Color.tilSimGold.opacity(0.3))
                .frame(width: 60, height: 0.5)
                .opacity(completionOpacity)
                .padding(.bottom, 12)
            
            Text("You've learned the ancient method.\nCircle. Division. Connection. Star. Tessellation.")
                .font(.system(size: isCompact ? 13 : 15, weight: .light))
                .lineSpacing(6)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tilSimIvory.opacity(0.7))
                .frame(maxWidth: 320)
                .opacity(completionOpacity)
                .padding(.bottom, 8)
            
            Text("Now create your own patterns — the tools\nof the ancient masters are in your hands.")
                .font(.system(size: isCompact ? 12 : 13, weight: .light, design: .serif))
                .italic()
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tilSimGold.opacity(0.5))
                .frame(maxWidth: 300)
                .opacity(completionOpacity)
            
            Spacer()
            
            Button(action: {
                HapticsEngine.shared.starComplete()
                onSwitchToCreate?()
            }) {
                HStack(spacing: 10) {
                    Text("Start Creating")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(4)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color.tilSimNavy)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.tilSimGold))
            }
            .opacity(completionOpacity)
            .padding(.bottom, 16)
            
            Button(action: {
                HapticsEngine.shared.tap()
                withAnimation(.easeInOut(duration: 0.4)) {
                    showCompletion = false
                    currentStep = 0
                    resetToStep(0)
                }
            }) {
                Text("Replay Construction")
                    .font(.system(size: 12, weight: .light))
                    .tracking(2)
                    .foregroundStyle(Color.tilSimIvory.opacity(0.4))
            }
            .opacity(completionOpacity)
            .padding(.bottom, 40)
        }
        .onAppear { animateCompletion() }
    }
    
    // MARK: - Helpers
    
    private func squarePath(cx: CGFloat, cy: CGFloat, radius: CGFloat, offset: Int) -> Path {
        Path { path in
            let indices = [0, 2, 4, 6].map { ($0 + offset) % 8 }
            for (j, i) in indices.enumerated() {
                let angle = CGFloat(i) / 8.0 * .pi * 2 - .pi / 2
                let pt = CGPoint(x: cx + radius * cos(angle), y: cy + radius * sin(angle))
                j == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            HapticsEngine.shared.constructionStep()
            withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
            animateStep(currentStep)
        } else {
            HapticsEngine.shared.starComplete()
            withAnimation(.easeInOut(duration: 0.6)) {
                showCompletion = true
            }
        }
    }
    
    private func prevStep() {
        if currentStep > 0 {
            HapticsEngine.shared.tap()
            withAnimation(.easeInOut(duration: 0.3)) { currentStep -= 1 }
            resetToStep(currentStep)
        }
    }
    
    private func animateStep(_ step: Int) {
        let duration: Double
        switch step {
        case 0:
            duration = reduceMotion ? 0.3 : 1.2
            withAnimation(.easeOut(duration: duration)) { circleProgress = 1.0 }
        case 1:
            duration = reduceMotion ? 0.2 : 0.8
            withAnimation(.easeInOut(duration: duration)) { divisionOpacity = 1.0 }
        case 2:
            duration = reduceMotion ? 0.5 : 2.0
            withAnimation(.easeInOut(duration: duration)) { connectProgress = 1.0 }
        case 3:
            duration = reduceMotion ? 0.5 : 1.5
            withAnimation(.easeInOut(duration: duration)) { starProgress = 1.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.3 : 1.2)) {
                withAnimation(.easeIn(duration: reduceMotion ? 0.2 : 0.8)) { starFill = 0.6 }
                HapticsEngine.shared.bloom()
            }
        case 4:
            duration = reduceMotion ? 0.3 : 1.0
            withAnimation(.easeInOut(duration: duration)) { tessOpacity = 1.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.2 : 0.5)) {
                withAnimation(.easeInOut(duration: reduceMotion ? 0.2 : 0.8)) { tessCount = 2 }
                HapticsEngine.shared.starComplete()
            }
        default: break
        }
    }
    
    private func resetToStep(_ step: Int) {
        if step < 4 { tessOpacity = 0; tessCount = 1 }
        if step < 3 { starProgress = 0; starFill = 0 }
        if step < 2 { connectProgress = 0 }
        if step < 1 { divisionOpacity = 0 }
        if step == 0 { circleProgress = 0 }
        animateStep(step)
    }
    
    private func animateCompletion() {
        HapticsEngine.shared.bloom()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            completionScale = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.8)) { completionOpacity = 1.0 }
        }
    }
}
