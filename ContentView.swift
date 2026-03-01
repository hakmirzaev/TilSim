import SwiftUI

enum AppPhase: Equatable {
    case splash, story, main
}

struct ContentView: View {
    @State private var phase: AppPhase = .splash
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.8)) { phase = .story }
                }
                .transition(.opacity)
                
            case .story:
                StoryView {
                    NarratorEngine.shared.stop()
                    withAnimation(.easeInOut(duration: 0.8)) { phase = .main }
                }
                .transition(.opacity)
                
            case .main:
                mainView
                    .transition(.opacity)
            }
        }
        .onAppear {
            MusicPlayer.shared.start()
        }
    }
    
    @State private var musicOn = true
    
    private var mainView: some View {
        TabView(selection: $selectedTab) {
            Tab("Learn", systemImage: "pencil.and.ruler", value: 0) {
                LearnView {
                    withAnimation(.spring(response: 0.4)) { selectedTab = 1 }
                }
            }
            Tab("Create", systemImage: "paintbrush.pointed", value: 1) {
                CreateView()
            }
            Tab("Challenge", systemImage: "trophy", value: 2) {
                ChallengeView()
            }
            Tab("Gallery", systemImage: "square.grid.2x2", value: 3) {
                GalleryView()
            }
        }
        .tint(.tilSimGold)
        .overlay(alignment: .topTrailing) {
            Button(action: {
                MusicPlayer.shared.toggle()
                musicOn = !MusicPlayer.shared.isMuted
                HapticsEngine.shared.tap()
            }) {
                Image(systemName: musicOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.tilSimGold.opacity(0.6))
                    .padding(8)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .padding(.trailing, 52)
            .padding(.top, 8)
        }
    }
}
