import SwiftUI

struct CreateView: View {
    @State private var starPoints: Double = 8
    @State private var innerRatio: Double = 0.38
    @State private var selectedPaletteIndex: Int = 0
    @State private var cellSize: Double = 90
    @State private var rotation: Double = 0
    @State private var showControls = true
    @State private var showConnections = true
    @State private var panOffset = CGSize.zero
    @State private var dragOffset = CGSize.zero
    @State private var showExportSheet = false
    @State private var exportImage: UIImage?
    @State private var showSavedToast = false
    @StateObject private var motion = MotionParallax()
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var isCompact: Bool { sizeClass == .compact }
    private var palette: PatternPalette { PatternPalette.all[selectedPaletteIndex] }
    
    private let maxPan: CGFloat = 300
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(palette.background))
                
                let totalOffset = CGSize(
                    width: panOffset.width + dragOffset.width + (reduceMotion ? 0 : motion.offset.width),
                    height: panOffset.height + dragOffset.height + (reduceMotion ? 0 : motion.offset.height)
                )
                context.translateBy(x: totalOffset.width, y: totalOffset.height)
                
                let drawSize = CGSize(width: size.width + 400, height: size.height + 400)
                context.translateBy(x: -200, y: -200)
                
                TessellationRenderer.drawEnhanced(
                    in: context, size: drawSize,
                    points: Int(starPoints), innerRatio: CGFloat(innerRatio),
                    cellSize: CGFloat(cellSize), palette: palette,
                    lineWidth: 1.2, rotation: .degrees(rotation),
                    showConnections: showConnections
                )
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.3), value: starPoints)
            .animation(.easeInOut(duration: 0.3), value: innerRatio)
            .animation(.easeInOut(duration: 0.3), value: cellSize)
            .animation(.easeInOut(duration: 0.3), value: rotation)
            .animation(.easeInOut(duration: 0.5), value: selectedPaletteIndex)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        dragOffset = CGSize(
                            width: max(-maxPan - panOffset.width, min(maxPan - panOffset.width, v.translation.width)),
                            height: max(-maxPan - panOffset.height, min(maxPan - panOffset.height, v.translation.height))
                        )
                    }
                    .onEnded { _ in
                        panOffset = CGSize(
                            width: max(-maxPan, min(maxPan, panOffset.width + dragOffset.width)),
                            height: max(-maxPan, min(maxPan, panOffset.height + dragOffset.height))
                        )
                        dragOffset = .zero
                    }
            )
            .accessibilityLabel("Pattern with \(Int(starPoints)) points")
            .accessibilityHint("Drag to pan the pattern")
            
            VStack {
                HStack {
                    Text("C R E A T E")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(6)
                        .foregroundStyle(palette.accent.opacity(0.8))
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) { showControls.toggle() }
                        HapticsEngine.shared.tap()
                    }) {
                        Image(systemName: showControls ? "chevron.down.circle.fill" : "slider.horizontal.3")
                            .foregroundStyle(palette.accent.opacity(0.8))
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
                
                if showControls {
                    controlPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Saved toast
            if showSavedToast {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Pattern saved to Photos")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .padding(.top, 60)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear { if !reduceMotion { motion.start(sensitivity: 8) } }
        .onDisappear { motion.stop() }
        .sheet(isPresented: $showExportSheet) {
            if let img = exportImage {
                ShareSheetView(image: img)
            }
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: isCompact ? 10 : 14) {
            controlSlider(label: "Points", value: "\(Int(starPoints))", binding: $starPoints, range: 4...12, step: 1)
            controlSlider(label: "Depth", value: "\(Int(innerRatio * 100))%", binding: $innerRatio, range: 0.15...0.48, step: 0.01)
            controlSlider(label: "Scale", value: "\(Int(cellSize))", binding: $cellSize, range: 40...160, step: 1)
            controlSlider(label: "Rotate", value: "\(Int(rotation))°", binding: $rotation, range: 0...45, step: 1)
            
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation { showConnections.toggle() }
                    HapticsEngine.shared.tap()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: showConnections ? "checkmark.square.fill" : "square")
                            .font(.system(size: 12))
                        Text("Interlock")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Color.white.opacity(0.5))
                }
                
                Spacer()
                
                actionButton(icon: "square.and.arrow.down", action: saveToPhotos)
                actionButton(icon: "square.and.arrow.up", action: sharePattern)
                actionButton(icon: "sparkles", action: randomize)
            }
            
            // Palette
            HStack(spacing: isCompact ? 6 : 10) {
                ForEach(Array(PatternPalette.all.enumerated()), id: \.element.id) { idx, pal in
                    Button(action: { HapticsEngine.shared.sliderTick(); selectedPaletteIndex = idx }) {
                        VStack(spacing: 3) {
                            HStack(spacing: 2) {
                                Circle().fill(pal.primary).frame(width: 10, height: 10)
                                Circle().fill(pal.accent).frame(width: 10, height: 10)
                            }
                            Text(pal.name).font(.system(size: 8, weight: .light)).foregroundStyle(Color.white.opacity(0.5))
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(idx == selectedPaletteIndex ? 0.12 : 0.04))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(idx == selectedPaletteIndex ? palette.accent.opacity(0.5) : .clear, lineWidth: 1))
                        )
                    }
                }
            }
        }
        .padding(isCompact ? 14 : 18)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func actionButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(palette.accent.opacity(0.2))
                    .overlay(Circle().stroke(palette.accent.opacity(0.4), lineWidth: 0.5)))
        }
    }
    
    private func controlSlider(label: String, value: String, binding: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label.uppercased()).font(.system(size: 9, weight: .medium)).tracking(3).foregroundStyle(Color.white.opacity(0.5))
                Spacer()
                Text(value).font(.system(size: 11, weight: .light, design: .monospaced)).foregroundStyle(palette.accent.opacity(0.8))
            }
            Slider(value: binding, in: range, step: step) { editing in
                if !editing { HapticsEngine.shared.sliderTick() }
            }.tint(palette.accent)
        }
    }
    
    // MARK: - Export
    
    private func renderPatternImage(size: CGSize = CGSize(width: 1200, height: 1200)) -> UIImage {
        let renderer = ImageRenderer(
            content: Canvas { context, canvasSize in
                context.fill(Path(CGRect(origin: .zero, size: canvasSize)), with: .color(palette.background))
                TessellationRenderer.drawEnhanced(
                    in: context, size: canvasSize,
                    points: Int(starPoints), innerRatio: CGFloat(innerRatio),
                    cellSize: CGFloat(cellSize) * (canvasSize.width / 400),
                    palette: palette, lineWidth: 2,
                    rotation: .degrees(rotation),
                    showConnections: showConnections
                )
            }
            .frame(width: size.width, height: size.height)
        )
        renderer.scale = 1.0
        return renderer.uiImage ?? UIImage()
    }
    
    private func saveToPhotos() {
        HapticsEngine.shared.starComplete()
        let image = renderPatternImage()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation(.spring(response: 0.3)) { showSavedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSavedToast = false }
        }
    }
    
    private func sharePattern() {
        HapticsEngine.shared.tap(.medium)
        exportImage = renderPatternImage()
        showExportSheet = true
    }
    
    private func randomize() {
        HapticsEngine.shared.starComplete()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            starPoints = Double(Int.random(in: 5...12))
            innerRatio = Double.random(in: 0.2...0.45)
            cellSize = Double.random(in: 60...130)
            rotation = Double.random(in: 0...45)
            selectedPaletteIndex = Int.random(in: 0..<PatternPalette.all.count)
            showConnections = Bool.random()
            panOffset = .zero
        }
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let image: UIImage
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = "Created with TilSim — The Mathematics of Beauty"
        return UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
