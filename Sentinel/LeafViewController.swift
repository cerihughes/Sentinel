import UIKit

protocol LeafViewController {
    associatedtype CompletionData

    var completionData: CompletionData {get}
}
