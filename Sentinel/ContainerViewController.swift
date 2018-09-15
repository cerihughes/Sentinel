import UIKit

class ContainerViewController: UIViewController {

    private let oppositionContainer = OppositionViewContainer()
    private let mainViewController: ViewController
    private let sentinelViewController: ViewController

    init(viewModel: ViewModel) {
        mainViewController = ViewController(viewModel: viewModel)
        sentinelViewController = ViewController(viewModel: viewModel, viewer: .sentinel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParentViewController: self)

        let mainView: UIView = mainViewController.view
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let mainCenterX = mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let mainCenterY = mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let mainWidth = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let mainHeight = mainView.heightAnchor.constraint(equalTo: view.heightAnchor)

        oppositionContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(oppositionContainer)

        let containerRight = oppositionContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        let containerTop = oppositionContainer.topAnchor.constraint(equalTo: view.topAnchor)
        let containerWidth = NSLayoutConstraint(item: oppositionContainer,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .width,
                                                multiplier: 0.2,
                                                constant: 0)
        let containerHeight = oppositionContainer.heightAnchor.constraint(equalTo: view.heightAnchor)

        NSLayoutConstraint.activate([mainCenterX, mainCenterY, mainWidth, mainHeight,
                                     containerRight, containerTop, containerWidth, containerHeight])

        add(oppositionController: sentinelViewController)
    }

    private func add(oppositionController: UIViewController) {
        addChildViewController(oppositionController)
        oppositionContainer.addSubview(oppositionController.view)
        oppositionController.didMove(toParentViewController: self)
    }

    private func remove(oppositionController: UIViewController) {
        oppositionController.willMove(toParentViewController: nil)
        oppositionController.view.removeFromSuperview()
        oppositionController.removeFromParentViewController()
    }
}

class OppositionViewContainer: UIView {
    private let maxViews: Int = 4
    private let topBottomSpacing: CGFloat = 20.0
    private let aspectRatio: CGFloat = 9.0 / 9.0

    override func layoutSubviews() {
        let availableVerticalSpace = self.frame.height - (topBottomSpacing * 2.0)
        let width = self.frame.width
        let height = width / aspectRatio
        let usedVerticalSpace = height * CGFloat(maxViews)
        let freeVerticalSpace = availableVerticalSpace - usedVerticalSpace
        let spacing = freeVerticalSpace / CGFloat(maxViews - 1)
        let heightPlusSpacing = height + spacing
        let x: CGFloat = 0.0
        var y = topBottomSpacing
        for (index, item) in subviews.enumerated() {
            y += heightPlusSpacing * CGFloat(index)
            item.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}

