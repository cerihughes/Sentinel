import Madog
import UIKit

class IntroViewController: UIViewController {
    let forwardNavigationContext: ForwardNavigationContext

    init(forwardNavigationContext: ForwardNavigationContext) {
        self.forwardNavigationContext = forwardNavigationContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let rl = RegistrationLocator(identifier: lobbyIdentifier, level: nil)
        _ = forwardNavigationContext.navigate(with: rl, from: self, animated: true)
    }
}
