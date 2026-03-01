<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift" />
  <img src="https://img.shields.io/badge/iOS-18.1+-blue?style=flat-square&logo=apple" />
  <img src="https://img.shields.io/badge/Frameworks-5-purple?style=flat-square" />
  <img src="https://img.shields.io/badge/Dependencies-Zero-green?style=flat-square" />
</p>

<h1 align="center">✦ TilSim</h1>
<h3 align="center"><em>The Mathematics of Beauty</em></h3>

<p align="center">
An interactive journey through the geometric art of Uzbekistan's Silk Road architecture.<br/>
Discover how a single circle and a few lines can create infinite beauty.
</p>

---

## The Story

For over 2,500 years, the artisans of Samarkand transformed simple geometric rules into one of humanity's greatest artistic achievements. Their patterns — carved into the walls of the Registan, Shah-i-Zinda, and Bibi-Khanym Mosque — encode symmetry groups, tessellations, and the golden ratio, centuries before Europe formalized these concepts.

**TilSim** (meaning *talisman* in Uzbek) preserves this endangered heritage digitally. It doesn't just show you the patterns — it teaches you to *build* them, the same way ancient masters did: compass, straightedge, and infinite patience.

## Experience

**Learn** — Watch an 8-pointed star construct itself step by step: circle → division → connection → star → tessellation. Drag to rotate. Feel each construction step through haptics.

**Create** — Design your own patterns in real time. Adjust points, depth, rotation, and palette. Pan and zoom across an infinite tessellated canvas. Toggle interlocking geometry.

**Challenge** — Can you recreate the Registan Star? Three difficulty tiers (Apprentice → Artisan → Master) progressively unlock parameters. A translucent ghost overlay guides your construction. Track your streak and score.

**Sandbox** — A freeform symmetry-mirror drawing canvas. Draw with your finger and watch strokes replicate across 4–12 axes of symmetry in real time. Pick any color with the built-in color picker, adjust stroke width, and save your creation to Photos. Every stroke is rendered with smooth Catmull-Rom curves for precise, natural-looking lines.

**Gallery** — Explore five historically significant patterns with architectural context, symmetry classifications, and fun facts. Tilt your device to see patterns shift with parallax depth.

## Built With

| | Framework | Purpose |
|---|-----------|---------|
| 🎨 | **SwiftUI** | UI, Canvas rendering, gesture system, animations |
| 📳 | **CoreHaptics** | Seven distinct haptic textures for construction, bloom, and interaction |
| 🎙️ | **AVFoundation** | Pre-recorded narration during onboarding story |
| 🎵 | **AVFAudio** | Ambient background music with fade transitions |
| 🧭 | **CoreMotion** | Device-tilt parallax in Gallery and Create views |

Every pattern is generated algorithmically — zero image assets, pure mathematics. The entire app works offline with no external dependencies.

## Design Philosophy

- **Samarkand color palettes** — Five curated themes drawn from real buildings: Registan, Shah-i-Zinda, Bibi-Khanym, Ulugh Beg, and Ivory
- **Interlocking tessellation** — Gap-fill diamonds and connecting lines replicate authentic *girih* tilework
- **Responsive** — Adapts seamlessly between iPhone and iPad
- **Accessible** — Full VoiceOver support with labels and hints; respects `accessibilityReduceMotion`

## Run

Open `My App.swiftpm` in **Swift Playgrounds 4.6+** or **Xcode 16+** → Build & Run on an iOS 18.1+ device or simulator.

No external dependencies. No network required. Just geometry.

---

<p align="center">
  <em>"From one simple rule, infinite beauty emerges."</em>
</p>
