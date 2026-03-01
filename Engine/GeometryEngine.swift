import SwiftUI

// MARK: - Star Shape
struct StarShape: Shape {
    var points: Int
    var innerRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        var path = Path()
        let total = points * 2
        
        for i in 0..<total {
            let angle = (CGFloat(i) / CGFloat(total)) * .pi * 2 - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Rosette Shape
struct RosetteShape: Shape {
    var points: Int
    var innerRatio: CGFloat
    var petalRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * innerRatio
        var path = Path()
        let total = points * 2
        
        for i in 0..<total {
            let angle = (CGFloat(i) / CGFloat(total)) * .pi * 2 - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        
        // Petal arcs
        for i in 0..<points {
            let a1 = (CGFloat(i * 2) / CGFloat(total)) * .pi * 2 - .pi / 2
            let a2 = (CGFloat(i * 2 + 2) / CGFloat(total)) * .pi * 2 - .pi / 2
            let mid = (a1 + a2) / 2
            let p1 = CGPoint(x: center.x + outer * cos(a1), y: center.y + outer * sin(a1))
            let p2 = CGPoint(x: center.x + outer * cos(a2), y: center.y + outer * sin(a2))
            let cp = CGPoint(x: center.x + outer * petalRatio * cos(mid), y: center.y + outer * petalRatio * sin(mid))
            path.move(to: p1)
            path.addQuadCurve(to: p2, control: cp)
        }
        return path
    }
}

// MARK: - Enhanced Tessellation Renderer (with interlocking geometry)
struct TessellationRenderer {
    
    /// Basic tessellation — stars only
    static func draw(
        in context: GraphicsContext, size: CGSize,
        points: Int, innerRatio: CGFloat, cellSize: CGFloat,
        strokeColor: Color, fillColor: Color,
        lineWidth: CGFloat = 1, rotation: Angle = .zero
    ) {
        let cols = Int(size.width / cellSize) + 3
        let rows = Int(size.height / cellSize) + 3
        
        for row in -1..<rows {
            for col in -1..<cols {
                let x = CGFloat(col) * cellSize + cellSize / 2
                let y = CGFloat(row) * cellSize + cellSize / 2
                let rect = CGRect(x: x - cellSize * 0.4, y: y - cellSize * 0.4,
                                  width: cellSize * 0.8, height: cellSize * 0.8)
                let star = StarShape(points: points, innerRatio: innerRatio).path(in: rect)
                context.fill(star, with: .color(fillColor))
                context.stroke(star, with: .color(strokeColor), lineWidth: lineWidth)
            }
        }
    }
    
    /// Enhanced tessellation — stars + gap-fill diamonds + connecting lines, with rotation
    static func drawEnhanced(
        in context: GraphicsContext, size: CGSize,
        points: Int, innerRatio: CGFloat, cellSize: CGFloat,
        palette: PatternPalette, lineWidth: CGFloat = 1,
        rotation: Angle = .zero, showConnections: Bool = true
    ) {
        let cols = Int(size.width / cellSize) + 3
        let rows = Int(size.height / cellSize) + 3
        
        // Layer 1: Main stars (with rotation applied per-star)
        for row in -1..<rows {
            for col in -1..<cols {
                let x = CGFloat(col) * cellSize + cellSize / 2
                let y = CGFloat(row) * cellSize + cellSize / 2
                var ctx = context
                ctx.translateBy(x: x, y: y)
                ctx.rotate(by: rotation)
                ctx.translateBy(x: -x, y: -y)
                let rect = CGRect(x: x - cellSize * 0.4, y: y - cellSize * 0.4,
                                  width: cellSize * 0.8, height: cellSize * 0.8)
                let star = StarShape(points: points, innerRatio: innerRatio).path(in: rect)
                ctx.fill(star, with: .color(palette.primary.opacity(0.55)))
                ctx.stroke(star, with: .color(palette.stroke), lineWidth: lineWidth)
            }
        }
        
        guard showConnections else { return }
        
        // Layer 2: Gap-fill diamonds at intersections (rotated)
        for row in -1..<rows {
            for col in -1..<cols {
                let x = CGFloat(col) * cellSize + cellSize
                let y = CGFloat(row) * cellSize + cellSize
                var ctx = context
                ctx.translateBy(x: x, y: y)
                ctx.rotate(by: rotation)
                ctx.translateBy(x: -x, y: -y)
                let gs = cellSize * 0.2
                let gRect = CGRect(x: x - gs, y: y - gs, width: gs * 2, height: gs * 2)
                let gap = StarShape(points: 4, innerRatio: 0.4).path(in: gRect)
                ctx.fill(gap, with: .color(palette.secondary.opacity(0.3)))
                ctx.stroke(gap, with: .color(palette.accent.opacity(0.4)), lineWidth: lineWidth * 0.5)
            }
        }
        
        // Layer 3: Connecting lines (horizontal)
        for row in -1..<rows {
            for col in -1..<cols {
                let x1 = CGFloat(col) * cellSize + cellSize / 2 + cellSize * 0.4
                let x2 = CGFloat(col + 1) * cellSize + cellSize / 2 - cellSize * 0.4
                let y = CGFloat(row) * cellSize + cellSize / 2
                if x2 > x1 {
                    var line = Path()
                    line.move(to: CGPoint(x: x1, y: y))
                    line.addLine(to: CGPoint(x: x2, y: y))
                    context.stroke(line, with: .color(palette.accent.opacity(0.2)), lineWidth: lineWidth * 0.4)
                }
            }
        }
        
        // Layer 4: Connecting lines (vertical)
        for row in -1..<rows {
            for col in -1..<cols {
                let x = CGFloat(col) * cellSize + cellSize / 2
                let y1 = CGFloat(row) * cellSize + cellSize / 2 + cellSize * 0.4
                let y2 = CGFloat(row + 1) * cellSize + cellSize / 2 - cellSize * 0.4
                if y2 > y1 {
                    var line = Path()
                    line.move(to: CGPoint(x: x, y: y1))
                    line.addLine(to: CGPoint(x: x, y: y2))
                    context.stroke(line, with: .color(palette.accent.opacity(0.2)), lineWidth: lineWidth * 0.4)
                }
            }
        }
    }
}

// MARK: - Construction Step Definitions
enum ConstructionStep: Int, CaseIterable {
    case circle = 0, divide, connect, star, tessellate
    
    var title: String {
        switch self {
        case .circle:     return "The Foundation"
        case .divide:     return "Divine Division"
        case .connect:    return "Hidden Connections"
        case .star:       return "The Star Emerges"
        case .tessellate: return "Infinite Repetition"
        }
    }
    
    var description: String {
        switch self {
        case .circle:
            return "Every masterpiece begins with a circle — the symbol of unity and perfection. Uzbek artisans started each design this way over a thousand years ago."
        case .divide:
            return "Divide the circle into eight equal parts. These guide marks determine every line that follows."
        case .connect:
            return "Connect alternating points. Two squares emerge, rotated 45° from each other — a dance of geometry."
        case .star:
            return "Where the squares intersect, the eight-pointed star, the Khatai, is born. The heart of Uzbek geometric art."
        case .tessellate:
            return "Repeat the star across the plane. From one simple rule, infinite beauty emerges. Drag to explore."
        }
    }
    
    var narratorText: String {
        switch self {
        case .circle:
            return "Every masterpiece begins with a circle. The symbol of unity and perfection."
        case .divide:
            return "Divide the circle into eight equal parts. These marks guide every line that follows."
        case .connect:
            return "Connect alternating points. Two squares emerge. A dance of geometry."
        case .star:
            return "The eight-pointed star is born. The Khatai. The heart of Uzbek art."
        case .tessellate:
            return "Repeat the star. From one simple rule, infinite beauty emerges."
        }
    }
}
