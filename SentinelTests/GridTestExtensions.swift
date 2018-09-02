
private let flatString = "__"
private let upXString = "+x"
private let downXString = "-x"
private let upZString = "+z"
private let downZString = "-z"

extension GridShape: Equatable {

    static func create(with string: String) -> GridShape? {
        switch string {
        case flatString:
            return .flat
        case upXString:
            return .slopeUpX
        case downXString:
            return .slopeDownX
        case upZString:
            return .slopeUpZ
        case downZString:
            return .slopeDownZ
        default:
            return nil
        }
    }

    func stringValue() -> String {
        switch self {
        case .flat:
            return flatString
        case .slopeUpX:
            return upXString
        case .slopeDownX:
            return downXString
        case .slopeUpZ:
            return upZString
        case .slopeDownZ:
            return downZString
        }
    }

    func intValue() -> Int {
        switch self {
        case .flat:
            return 0
        case .slopeUpX:
            return 1
        case .slopeDownX:
            return 2
        case .slopeUpZ:
            return 3
        case .slopeDownZ:
            return 4
        }
    }

    static func sortFunction() -> (GridShape, GridShape) -> Bool {
        return {shape1, shape2 in
            return shape1.intValue() < shape2.intValue()
        }
    }
}
