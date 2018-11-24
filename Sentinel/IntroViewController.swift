import Madog
import UIKit

class IntroViewController: UIViewController {
    let navigationContext: NavigationContext

    init(navigationContext: NavigationContext) {
        self.navigationContext = navigationContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let rl = RegistrationLocator(identifier: lobbyIdentifier, level: nil)
        _ = navigationContext.navigateForward(with: rl, animated: true)
    }
}
