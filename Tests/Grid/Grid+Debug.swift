@testable import Sentinel

extension Grid {
    var description: String {
        var desc = ""
        for z in 0 ..< depth {
            for x in 0 ..< width {
                if let piece = get(point: GridPoint(x: x, z: z)) {
                    desc += "\(piece) "
                }
            }
            desc += "\n"
        }
        return desc
    }
}

extension GridPiece {
    var slopesString: String {
        GridDirection.allCases
            .map { has(slopeDirection: $0) ? $0.debugString : "*" }
            .joined()
    }

    var description: String {
        "\(slopesString):\(level)"
    }
}

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
