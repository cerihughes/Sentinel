import SceneKit

class ViewController: UIViewController {
    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let sceneView = self.view as? SCNView else {
            return
        }

        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        sceneView.scene = viewModel.scene
        sceneView.delegate = viewModel

        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:)))
        sceneView.addGestureRecognizer(tapRecogniser)

        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(tapGesture(sender:)))
        longPressRecogniser.isEnabled = false
        sceneView.addGestureRecognizer(longPressRecogniser)

        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
        sceneView.addGestureRecognizer(panRecogniser)

        viewModel.preAnimationBlock = {
            tapRecogniser.isEnabled = false
            longPressRecogniser.isEnabled = false
            panRecogniser.isEnabled = false
        }

        viewModel.postAnimationBlock = {
            tapRecogniser.isEnabled = true
            longPressRecogniser.isEnabled = true
            panRecogniser.isEnabled = true
        }
    }

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        if let sceneView = self.view as? SCNView, let interaction = interaction(for: sender) {
            let point = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(point, options: [:])
            viewModel.process(interaction: interaction, hitTestResults: hitTestResults)
        }
    }

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        let deltaX = Float(translation.x)
        viewModel.processPan(by: deltaX, finished: sender.state == .ended)
    }

    private func interaction(for sender: UIGestureRecognizer) -> UserInteraction? {
        if sender.isKind(of: UITapGestureRecognizer.self) {
            return .tap
        }

        if sender.isKind(of: UILongPressGestureRecognizer.self) {
            return .longPress
        }

        return nil
    }
}
