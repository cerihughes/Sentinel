import UIKit

class IntroViewController: UIViewController {
    let ui: UIContext

    init(ui: UIContext) {
        self.ui = ui
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let rl = RegistrationLocator(identifier: lobbyIdentifier, level: nil)
        _ = ui.navigate(with: rl, animated: true)
    }
}
