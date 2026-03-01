import SwiftUI

struct StoryView: View {
    var onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var bgRotation: Double = 0
    @State private var narratorOn = true
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let pages = StoryPage.pages
    private var isCompact: Bool { sizeClass == .compact }
    
    var body: some View {
        ZStack {
            LinearGradient.tilSimBackground.ignoresSafeArea()
            
            // Animated background star
            StarShape(points: pages[currentPage].starPoints, innerRatio: pages[currentPage].starRatio)
                .stroke(Color.tilSimGold.opacity(0.05), lineWidth: 1)
                .frame(width: 500, height: 500)
                .rotationEffect(.degrees(bgRotation))
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: toggleNarrator) {
                        Image(systemName: narratorOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.tilSimIvory.opacity(0.4))
                            .padding(8)
                    }
                    .accessibilityLabel(narratorOn ? "Mute narrator" : "Unmute narrator")
                    
                    Spacer()
                    
                    Button(action: {
                        NarratorEngine.shared.stop()
                        onComplete()
                    }) {
                        Text("Skip")
                            .font(.system(size: 13))
                            .tracking(2)
                            .foregroundStyle(Color.tilSimIvory.opacity(0.4))
                            .padding(8)
                    }
                }
                .padding(.horizontal, isCompact ? 12 : 24)
                .padding(.top, 8)
                
                // Swipeable pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        storyPageContent(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom navigation
                HStack(spacing: 20) {
                    Button(action: {
                        HapticsEngine.shared.pageTurn()
                        withAnimation { currentPage = max(0, currentPage - 1) }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(Color.tilSimGold.opacity(currentPage > 0 ? 0.8 : 0.2))
                    }
                    .disabled(currentPage == 0)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentPage ? Color.tilSimGold : Color.tilSimGold.opacity(0.2))
                                .frame(width: i == currentPage ? 8 : 5, height: i == currentPage ? 8 : 5)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    Button(action: {
                        if currentPage == pages.count - 1 {
                            HapticsEngine.shared.starComplete()
                            NarratorEngine.shared.stop()
                            onComplete()
                        } else {
                            HapticsEngine.shared.pageTurn()
                            withAnimation { currentPage += 1 }
                        }
                    }) {
                        if currentPage == pages.count - 1 {
                            HStack(spacing: 6) {
                                Text("Discover")
                                    .font(.system(size: 14, weight: .medium))
                                    .tracking(2)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(Color.tilSimIvory)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Color.tilSimGold.opacity(0.2))
                                    .overlay(Capsule().stroke(Color.tilSimGold.opacity(0.5), lineWidth: 0.5))
                            )
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(Color.tilSimGold.opacity(0.8))
                        }
                    }
                }
                .padding(.bottom, isCompact ? 30 : 40)
            }
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                    bgRotation = 360
                }
            }
            speakCurrentPage()
        }
        .onChange(of: currentPage) { _, _ in
            HapticsEngine.shared.pageTurn()
            speakCurrentPage()
        }
    }
    
    private func storyPageContent(page: StoryPage) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(systemName: page.iconName)
                .font(.system(size: isCompact ? 26 : 32, weight: .light))
                .foregroundStyle(Color.tilSimGold)
                .padding(.bottom, isCompact ? 16 : 24)
            
            Text(page.title.uppercased())
                .font(.system(size: isCompact ? 26 : 34, weight: .ultraLight, design: .serif))
                .tracking(isCompact ? 6 : 10)
                .foregroundStyle(Color.tilSimIvory)
                .padding(.bottom, 6)
                .accessibilityAddTraits(.isHeader)
            
            Rectangle()
                .fill(Color.tilSimGold.opacity(0.3))
                .frame(width: 60, height: 0.5)
                .padding(.bottom, 10)
            
            Text(page.subtitle)
                .font(.system(size: isCompact ? 12 : 14, weight: .light))
                .tracking(3)
                .foregroundStyle(Color.tilSimTurquoise.opacity(0.8))
                .padding(.bottom, isCompact ? 18 : 28)
            
            Text(page.body)
                .font(.system(size: isCompact ? 14 : 16, weight: .light))
                .lineSpacing(isCompact ? 5 : 8)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tilSimIvory.opacity(0.7))
                .frame(maxWidth: isCompact ? 300 : 380)
                .padding(.horizontal, isCompact ? 16 : 24)
            
            Spacer()
        }
    }
    
    private func toggleNarrator() {
        narratorOn.toggle()
        NarratorEngine.shared.isEnabled = narratorOn
        if !narratorOn { NarratorEngine.shared.stop() }
        HapticsEngine.shared.tap()
    }
    
    private func speakCurrentPage() {
        if narratorOn {
            NarratorEngine.shared.playStoryAudio(index: currentPage)
        }
    }
}
