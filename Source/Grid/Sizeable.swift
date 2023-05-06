import Foundation

protocol Sizeable {
    var width: Int { get }
    var depth: Int { get }
}

extension Grid: Sizeable {}
extension GridBuilder: Sizeable {}
