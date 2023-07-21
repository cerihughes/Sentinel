import Madog
import UIKit

class GamePreviewViewControllerProvider: TypedViewControllerProvider {
    // MARK: TypedViewControllerProvider

    override func createViewController(token: Navigation, context: AnyContext<Navigation>) -> UIViewController? {
        guard case let .gamePreview(level) = token else { return nil }
        let worldBuilder = WorldBuilder.createDefault(level: level)
        let viewModel = GamePreviewViewModel(level: level, worldBuilder: worldBuilder)
        return GamePreviewViewController(context: context, viewModel: viewModel)
    }
}
