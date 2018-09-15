import UIKit

class ContainerViewController: UIViewController {

    private let mainViewController: ViewController

    init(viewModel: ViewModel) {
        mainViewController = ViewController(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainView = addContentController(mainViewController)

        mainView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let heightConstraint = mainView.heightAnchor.constraint(equalTo: view.heightAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    private func addContentController(_ child: UIViewController) -> UIView {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
        return child.view
    }

    private func removeContentController(_ child: UIViewController) {
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
}
