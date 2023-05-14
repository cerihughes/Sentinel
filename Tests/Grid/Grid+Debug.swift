@testable import Sentinel

extension Grid {
    var slopesDescription: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let piece = piece(at: .init(x: x, z: z)) {
                    desc += "\(piece.slopesDescription) "
                } else {
                    desc += "!"
                }
            }
            desc += "\n"
        }
        return desc
    }

    var floorDescription: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let piece = piece(at: .init(x: x, z: z)) {
                    desc += "\(piece.floorDescription)"
                } else {
                    desc += "!"
                }
            }
            desc += "\n"
        }
        return desc
    }

    var contentsDescription: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let piece = piece(at: .init(x: x, z: z)) {
                    desc += (contentsDescription(at: piece.point))
                } else {
                    desc += "!"
                }
            }
            desc += "\n"
        }
        return desc
    }

    func contentsDescription(at point: GridPoint) -> String {
        if treePositions.contains(point) {
            return "T"
        }
        if allRockPositions().contains(point) {
            return "R"
        }
        if currentPosition == point {
            return "C"
        }
        if synthoidPositions.contains(point) {
            if startPosition == point {
                return "*"
            }
            return "P"
        }
        if sentinelPosition == point {
            return "S"
        }
        if sentryPositions.contains(point) {
            return "s"
        }
        if startPosition == point {
            return "+"
        }
        return "."
    }

}

protocol Slopeable {
    var isFloor: Bool { get }
    var level: Float { get }
    func has(slopeDirection: GridDirection) -> Bool
}

extension Slopeable {
    var slopesString: String {
        GridDirection.allCases
            .map { has(slopeDirection: $0) ? $0.debugString : "*" }
            .joined()
    }

    var slopesDescription: String {
        "\(slopesString):\(level)"
    }

    var floorDescription: String {
        guard isFloor else { return "." }
        return "\(Int(level))"
    }
}

extension GridPiece: Slopeable {}
extension GridPieceBuilder: Slopeable {}

extension GridDirection {
    var debugString: String {
        switch self {
        case .north: return "N"
        case .east: return "E"
        case .south: return "S"
        case .west: return "W"
        }
    }
}
