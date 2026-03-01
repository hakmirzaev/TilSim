import SwiftUI

// MARK: - Samarkand-Inspired Color Palette
extension Color {
    // Primary Palette
    static let tilSimNavy    = Color(red: 0.04, green: 0.08, blue: 0.18)
    static let tilSimBlue    = Color(red: 0.04, green: 0.24, blue: 0.39)
    static let tilSimGold    = Color(red: 0.83, green: 0.63, blue: 0.09)
    static let tilSimTurquoise = Color(red: 0.10, green: 0.67, blue: 0.61)
    static let tilSimIvory   = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let tilSimBurgundy = Color(red: 0.42, green: 0.18, blue: 0.22)
    
    // Extended
    static let tilSimDeepBlue = Color(red: 0.02, green: 0.15, blue: 0.30)
    static let tilSimSand    = Color(red: 0.87, green: 0.78, blue: 0.62)
    static let tilSimEmerald = Color(red: 0.08, green: 0.45, blue: 0.35)
}

// MARK: - Color Palettes for Pattern Creator
struct PatternPalette: Identifiable {
    let id: String
    let name: String
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let stroke: Color
    
    static let registan = PatternPalette(
        id: "registan",
        name: "Registan",
        background: .tilSimNavy,
        primary: .tilSimBlue,
        secondary: .tilSimTurquoise,
        accent: .tilSimGold,
        stroke: .tilSimGold
    )
    
    static let shahIZinda = PatternPalette(
        id: "shahizinda",
        name: "Shah-i-Zinda",
        background: Color(red: 0.02, green: 0.06, blue: 0.14),
        primary: Color(red: 0.08, green: 0.30, blue: 0.55),
        secondary: Color(red: 0.20, green: 0.60, blue: 0.80),
        accent: Color(red: 0.75, green: 0.82, blue: 0.90),
        stroke: Color(red: 0.60, green: 0.75, blue: 0.88)
    )
    
    static let bibiKhanym = PatternPalette(
        id: "bibikhanym",
        name: "Bibi-Khanym",
        background: Color(red: 0.12, green: 0.06, blue: 0.06),
        primary: .tilSimBurgundy,
        secondary: Color(red: 0.72, green: 0.42, blue: 0.15),
        accent: .tilSimGold,
        stroke: Color(red: 0.85, green: 0.65, blue: 0.30)
    )
    
    static let ulughBeg = PatternPalette(
        id: "ulughbeg",
        name: "Ulugh Beg",
        background: Color(red: 0.04, green: 0.03, blue: 0.10),
        primary: Color(red: 0.18, green: 0.10, blue: 0.40),
        secondary: Color(red: 0.10, green: 0.35, blue: 0.50),
        accent: Color(red: 0.90, green: 0.75, blue: 0.30),
        stroke: Color(red: 0.65, green: 0.55, blue: 0.85)
    )
    
    static let samarkandWhite = PatternPalette(
        id: "white",
        name: "Ivory",
        background: .tilSimIvory,
        primary: .tilSimSand,
        secondary: Color(red: 0.85, green: 0.75, blue: 0.60),
        accent: .tilSimBlue,
        stroke: Color(red: 0.30, green: 0.25, blue: 0.20)
    )
    
    static let all: [PatternPalette] = [registan, shahIZinda, bibiKhanym, ulughBeg, samarkandWhite]
}

// MARK: - Gradient Definitions
extension LinearGradient {
    static let tilSimBackground = LinearGradient(
        colors: [.tilSimNavy, Color(red: 0.06, green: 0.12, blue: 0.24)],
        startPoint: .top, endPoint: .bottom
    )
    
    static let tilSimGoldShimmer = LinearGradient(
        colors: [
            .tilSimGold,
            Color(red: 0.95, green: 0.80, blue: 0.30),
            .tilSimGold
        ],
        startPoint: .leading, endPoint: .trailing
    )
}
