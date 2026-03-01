import SwiftUI

struct GalleryView: View {
    @State private var selectedPattern: PatternDefinition? = nil
    @State private var showDetail = false
    @State private var appeared = false
    @StateObject private var motion = MotionParallax()
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var isCompact: Bool { sizeClass == .compact }
    private let patterns = PatternDefinition.presets
    
    var body: some View {
        ZStack {
            LinearGradient.tilSimBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("G A L L E R Y")
                    .font(.system(size: 14, weight: .medium))
                    .tracking(6)
                    .foregroundStyle(Color.tilSimGold.opacity(0.6))
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(patterns.enumerated()), id: \.element.id) { index, pattern in
                            GalleryCard(pattern: pattern, isCompact: isCompact)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.08),
                                    value: appeared
                                )
                                .onTapGesture {
                                    HapticsEngine.shared.tap(.medium)
                                    selectedPattern = pattern
                                    withAnimation(.spring(response: 0.4)) { showDetail = true }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            
            if showDetail, let pattern = selectedPattern {
                PatternDetailView(pattern: pattern, motion: motion) {
                    withAnimation(.spring(response: 0.3)) { showDetail = false }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            if !reduceMotion { motion.start(sensitivity: 10) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
        }
        .onDisappear { motion.stop() }
    }
}

struct GalleryCard: View {
    let pattern: PatternDefinition
    let isCompact: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(pattern.palette.background))
                TessellationRenderer.draw(
                    in: context, size: size,
                    points: pattern.points, innerRatio: pattern.innerRatio,
                    cellSize: pattern.cellSize * (isCompact ? 0.4 : 0.5),
                    strokeColor: pattern.palette.stroke,
                    fillColor: pattern.palette.primary.opacity(0.55),
                    lineWidth: 0.6,
                    rotation: .degrees(pattern.rotation)
                )
            }
            .frame(height: isCompact ? 140 : 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .drawingGroup()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(pattern.name)
                        .font(.system(size: isCompact ? 15 : 17, weight: .light, design: .serif))
                        .foregroundStyle(Color.tilSimIvory)
                    Text(pattern.subtitle)
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Color.tilSimGold.opacity(0.6))
                    Text(pattern.shortDescription)
                        .font(.system(size: 10, weight: .light))
                        .lineSpacing(2)
                        .foregroundStyle(Color.tilSimIvory.opacity(0.4))
                        .lineLimit(2)
                }
                Spacer()
                VStack(spacing: 3) {
                    StarShape(points: pattern.points, innerRatio: pattern.innerRatio)
                        .stroke(pattern.palette.accent.opacity(0.6), lineWidth: 1)
                        .frame(width: 26, height: 26)
                    Text("\(pattern.points)pt")
                        .font(.system(size: 8, weight: .light, design: .monospaced))
                        .foregroundStyle(Color.tilSimGold.opacity(0.4))
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.tilSimGold.opacity(0.08), lineWidth: 0.5))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pattern.name), \(pattern.subtitle)")
        .accessibilityHint("Tap to explore this pattern")
    }
}

struct PatternDetailView: View {
    let pattern: PatternDefinition
    @ObservedObject var motion: MotionParallax
    var onDismiss: () -> Void
    
    @State private var dragRotation: Double = 0
    @State private var infoOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(pattern.palette.background))
                if !reduceMotion {
                    context.translateBy(x: motion.offset.width, y: motion.offset.height)
                }
                TessellationRenderer.drawEnhanced(
                    in: context, size: CGSize(width: size.width + 60, height: size.height + 60),
                    points: pattern.points, innerRatio: pattern.innerRatio,
                    cellSize: pattern.cellSize,
                    palette: pattern.palette, lineWidth: 1.2,
                    rotation: .degrees(pattern.rotation + dragRotation), showConnections: true
                )
            }
            .ignoresSafeArea()
            .gesture(
                DragGesture()
                    .onChanged { v in
                        withAnimation(.interactiveSpring) {
                            dragRotation = Double(v.translation.width) * 0.15
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { dragRotation = 0 }
                    }
            )
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { HapticsEngine.shared.tap(); onDismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.8))
                            .padding(12)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(16)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(pattern.name)
                        .font(.system(size: 22, weight: .light, design: .serif))
                        .foregroundStyle(Color.white)
                    Text(pattern.subtitle)
                        .font(.system(size: 12, weight: .light))
                        .tracking(2)
                        .foregroundStyle(pattern.palette.accent.opacity(0.8))
                    
                    Rectangle().fill(Color.white.opacity(0.2)).frame(width: 40, height: 0.5)
                    
                    Text(pattern.description)
                        .font(.system(size: 12, weight: .light))
                        .lineSpacing(5)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.75))
                        .frame(maxWidth: 320)
                    
                    if let fact = pattern.funFact {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill").font(.system(size: 10)).foregroundStyle(Color.tilSimGold)
                            Text(fact)
                                .font(.system(size: 11, weight: .light, design: .serif))
                                .italic()
                                .foregroundStyle(Color.tilSimGold.opacity(0.7))
                        }
                        .padding(.top, 2)
                        .frame(maxWidth: 300)
                    }
                    
                    HStack(spacing: 24) {
                        specBadge(label: "Points", value: "\(pattern.points)")
                        specBadge(label: "Symmetry", value: pattern.symmetryGroup)
                        specBadge(label: "Century", value: pattern.century)
                    }
                    .padding(.top, 6)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .opacity(infoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).delay(0.2)) { infoOpacity = 1 }
        }
    }
    
    private func specBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 14, weight: .light, design: .monospaced)).foregroundStyle(pattern.palette.accent)
            Text(label.uppercased()).font(.system(size: 8, weight: .medium)).tracking(2).foregroundStyle(Color.white.opacity(0.4))
        }
    }
}
