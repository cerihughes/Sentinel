import Foundation

extension CaseIterable {
    static func allCases(
        except exception: Self.AllCases.Element
    ) -> [Self.AllCases.Element] where Self.AllCases.Element: Equatable {
        allCases.filter { $0 != exception }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
