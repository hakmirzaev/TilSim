import SwiftUI

// MARK: - Pattern Definition
struct PatternDefinition: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let shortDescription: String
    let funFact: String?
    let symmetryGroup: String
    let century: String
    let points: Int
    let innerRatio: CGFloat
    let palette: PatternPalette
    let cellSize: CGFloat
    let rotation: Double
}

extension PatternDefinition {
    static let presets: [PatternDefinition] = [
        PatternDefinition(
            id: "registan_star",
            name: "Registan Star",
            subtitle: "Samarkand, 15th century",
            description: "The iconic eight-pointed star adorning the Registan square — the jewel of the Timurid Empire. Built from two overlapping squares, it represents the union of the earthly and the divine. This pattern has been replicated on mosques from Morocco to Malaysia.",
            shortDescription: "Two overlapping squares forming the heart of Timurid art.",
            funFact: "The Registan was once a public market square, and its geometric tiles were designed to be read from 100 meters away.",
            symmetryGroup: "p4m",
            century: "15th",
            points: 8,
            innerRatio: 0.38,
            palette: .registan,
            cellSize: 90,
            rotation: 0
        ),
        PatternDefinition(
            id: "bibi_rosette",
            name: "Bibi-Khanym Rosette",
            subtitle: "Samarkand, 1404 CE",
            description: "A ten-pointed rosette from the Bibi-Khanym Mosque, commissioned by Timur after his Indian campaign. Once the largest mosque in the Islamic world, its geometry encodes the golden ratio — the same proportion found in galaxies, sunflowers, and DNA.",
            shortDescription: "Ten-fold symmetry encoding the golden ratio.",
            funFact: "Legend says Timur's architect fell in love with Bibi-Khanym herself, and the minarets lean as a result of divine punishment.",
            symmetryGroup: "cmm",
            century: "15th",
            points: 10,
            innerRatio: 0.35,
            palette: .bibiKhanym,
            cellSize: 100,
            rotation: 0
        ),
        PatternDefinition(
            id: "shahizinda_lattice",
            name: "Shah-i-Zinda Lattice",
            subtitle: "Samarkand, 14th century",
            description: "A delicate six-pointed lattice from the Avenue of Mausoleums — a UNESCO World Heritage site. The cool majolica tiles create a sense of spiritual transcendence. Each mausoleum uses slightly different patterns, like variations on a musical theme.",
            shortDescription: "Six-fold lattice from the Avenue of Mausoleums.",
            funFact: "Shah-i-Zinda means 'The Living King' — legend says a cousin of Prophet Muhammad is buried here and never died.",
            symmetryGroup: "p6m",
            century: "14th",
            points: 6,
            innerRatio: 0.42,
            palette: .shahIZinda,
            cellSize: 75,
            rotation: 0
        ),
        PatternDefinition(
            id: "ulugh_beg_cosmos",
            name: "Ulugh Beg's Cosmos",
            subtitle: "Samarkand, 1420 CE",
            description: "Inspired by the observatory of Ulugh Beg, grandson of Timur and one of history's greatest astronomers. This twelve-pointed star represents the zodiac constellations. His star catalog — calculated without a telescope — remained the most accurate for 200 years.",
            shortDescription: "Twelve-pointed star representing the zodiac.",
            funFact: "Ulugh Beg calculated the length of a year to within 58 seconds of the modern value — in 1437.",
            symmetryGroup: "p4m",
            century: "15th",
            points: 12,
            innerRatio: 0.45,
            palette: .ulughBeg,
            cellSize: 110,
            rotation: 15
        ),
        PatternDefinition(
            id: "khiva_diamond",
            name: "Khiva Diamond",
            subtitle: "Khiva, 18th century",
            description: "A five-pointed pattern from the Itchan Kala fortress — the walled inner city of Khiva. Pentagonal symmetry is the most challenging to tessellate perfectly, and its presence here demonstrates the extraordinary mathematical mastery of Khorezm's artisans.",
            shortDescription: "Pentagonal symmetry from the fortress of Khiva.",
            funFact: "Khiva's Itchan Kala was the first entire city inscribed as a UNESCO World Heritage site in Central Asia.",
            symmetryGroup: "p4g",
            century: "18th",
            points: 5,
            innerRatio: 0.30,
            palette: .samarkandWhite,
            cellSize: 85,
            rotation: 0
        )
    ]
}

// MARK: - Story Pages
struct StoryPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let body: String
    let iconName: String
    let starPoints: Int
    let starRatio: CGFloat
}

extension StoryPage {
    static let pages: [StoryPage] = [
        StoryPage(
            title: "Samarkand",
            subtitle: "Crossroads of the World",
            body: "For over 2,500 years, Samarkand stood at the heart of the Silk Road. Where mathematics, art, and cultures converged from China to Rome. Its blue domes and golden minarets inspired awe in travelers from Marco Polo to Alexander the Great.",
            iconName: "building.columns.fill",
            starPoints: 8,
            starRatio: 0.38
        ),
        StoryPage(
            title: "The Artisans",
            subtitle: "Masters of Geometry",
            body: "Medieval craftsmen discovered that breathtaking patterns could emerge from simple geometric rules: a circle, a few divisions, and a steady hand. No computers. No calculators. Just a compass, a straightedge, and centuries of inherited wisdom.",
            iconName: "pencil.and.ruler.fill",
            starPoints: 6,
            starRatio: 0.42
        ),
        StoryPage(
            title: "The Secret",
            subtitle: "Mathematics as Art",
            body: "These patterns encode deep mathematical principles, including symmetry groups, tessellations, and the golden ratio, centuries before Europe formalized them. Every tile is a theorem. Every wall is a proof.",
            iconName: "function",
            starPoints: 10,
            starRatio: 0.35
        ),
        StoryPage(
            title: "Your Turn",
            subtitle: "Continue the Legacy",
            body: "Now discover how a single circle and a few lines can create infinite beauty. The tools of the ancient masters are in your hands. Touch, drag, and explore the mathematics of beauty.",
            iconName: "sparkles",
            starPoints: 12,
            starRatio: 0.45
        )
    ]
}
