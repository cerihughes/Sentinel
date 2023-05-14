import Madog
import UIKit

class IntroViewController: UIViewController {
    let navigationContext: ForwardBackNavigationContext

    init(navigationContext: ForwardBackNavigationContext) {
        self.navigationContext = navigationContext
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationContext.showLobby()
    }
}
