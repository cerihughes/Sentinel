import UIKit

class ContainerViewController: UIViewController {
    private let viewModel: ViewModel
    private let oppositionContainer = OppositionViewContainer()
    private let mainViewController: ViewController

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        mainViewController = ViewController(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParent: self)

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

        let sentinelViewController = ViewController(viewModel: viewModel, viewer: .sentinel)
        add(oppositionController: sentinelViewController)

        let rawValueOffset = Viewer.sentry1.rawValue
        for i in 0 ..< viewModel.levelConfiguration.sentryCount {
            if let viewer = Viewer(rawValue: i + rawValueOffset) {
                let sentryViewController = ViewController(viewModel: viewModel, viewer: viewer)
                add(oppositionController: sentryViewController)
            }
        }
    }

    override func viewWillLayoutSubviews() {
        let size = view.frame.size
        oppositionContainer.aspectRatio = size.width / size.height
    }

    private func add(oppositionController: UIViewController) {
        addChild(oppositionController)
        oppositionContainer.addSubview(oppositionController.view)
        oppositionController.didMove(toParent: self)
    }

    private func remove(oppositionController: UIViewController) {
        oppositionController.willMove(toParent: nil)
        oppositionController.view.removeFromSuperview()
        oppositionController.removeFromParent()
    }
}

class OppositionViewContainer: UIView {
    private let maxViews: Int = 4
    private let topBottomSpacing: CGFloat = 20.0

    var aspectRatio: CGFloat = 4.0 / 3.0 {
        didSet {
            setNeedsLayout()
        }
    }

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
        for subview in subviews {
            subview.frame = CGRect(x: x, y: y, width: width, height: height)
            y += heightPlusSpacing
        }
    }
}

