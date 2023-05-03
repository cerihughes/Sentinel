import SceneKit
import UIKit

enum SwipeDirection: CaseIterable {
    case up, down, left, right

    var buildableItem: BuildableItem? {
        switch self {
        case .left:
            return .tree
        case .up:
            return .rock
        case .right:
            return .synthoid
        default:
            return nil
        }
    }
}

enum SwipeState {
    case building(Float)
    case finished(Bool)

    init(scale: Float, finished: Bool) {
        if finished {
            self = .finished(scale == 1.0)
        } else {
            self = .building(scale)
        }
    }
}

private let threshold: CGFloat = 200.0

class SwipeInputHandler: GameInputHandler {
    let playerOperations: PlayerOperations
    let opponentsOperations: OpponentsOperations

    private let nodeManipulator: NodeManipulator
    private let gestureRecognisers: [UIGestureRecognizer]

    private let hitTestOptions: [SCNHitTestOption: Any]

    private var startTapPoint: CGPoint?
    private var floorNode: FloorNode?

    init(
        playerOperations: PlayerOperations,
        opponentsOperations: OpponentsOperations,
        nodeManipulator: NodeManipulator
    ) {
        self.playerOperations = playerOperations
        self.opponentsOperations = opponentsOperations
        self.nodeManipulator = nodeManipulator

        hitTestOptions = [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.rootNode: nodeManipulator.terrainNode
        ]

        let tapRecogniser = UITapGestureRecognizer()
        let doubleTapRecogniser = UITapGestureRecognizer()
        let longPressRecogniser = UILongPressGestureRecognizer()
        let panRecogniser = UIPanGestureRecognizer()

        gestureRecognisers = [tapRecogniser, doubleTapRecogniser, longPressRecogniser, panRecogniser]

        tapRecogniser.addTarget(self, action: #selector(tapGesture(sender:)))

        doubleTapRecogniser.numberOfTapsRequired = 2
        doubleTapRecogniser.addTarget(self, action: #selector(doubleTapGesture(sender:)))

        longPressRecogniser.minimumPressDuration = 0.5
        longPressRecogniser.addTarget(self, action: #selector(longPressGesture(sender:)))
        longPressRecogniser.isEnabled = false

        panRecogniser.addTarget(self, action: #selector(panGesture(sender:)))
        panRecogniser.isEnabled = false
    }

    // MARK: InputHandler

    func addGestureRecognisers(to view: UIView) {
        for gestureRecogniser in gestureRecognisers {
            view.addGestureRecognizer(gestureRecogniser)
        }
    }

    func setGestureRecognisersEnabled(_ isEnabled: Bool) {
        for gestureRecogniser in gestureRecognisers {
            gestureRecogniser.isEnabled = isEnabled
        }
    }

    // MARK: Tap

    @objc
    func tapGesture(sender: UIGestureRecognizer) {
        guard sender.state != .cancelled else {
            return
        }

        if !playerOperations.hasEnteredScene() {
            _ = playerOperations.enterScene()
        }
    }

    // MARK: Double Tap

    @objc
    func doubleTapGesture(sender: UIGestureRecognizer) {
        guard let sceneView = sender.view as? SCNView else {
            return
        }

        let point = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
        if let interactiveNode = hitTestResults.firstInteractiveNode() {
            processDoubleTap(node: interactiveNode)
        }
    }

    private func processDoubleTap(node: SCNNode) {
        if let synthoidNode = node as? SynthoidNode {
            playerOperations.move(to: synthoidNode)
        }
    }

    // MARK: Long Press

    @objc
    func longPressGesture(sender: UILongPressGestureRecognizer) {
        guard let sceneView = sender.view as? SCNView else {
            return
        }

        let point = sender.location(in: sceneView)
        let state = sender.state

        if state == .began {
            let hitTestResults = sceneView.hitTest(point, options: hitTestOptions)
            if let floorNode = floorNode(for: hitTestResults) {
                startTapPoint = point
                self.floorNode = floorNode
                processBuildStart(floorNode: floorNode)
            } else {
                startTapPoint = nil
                floorNode = nil

                // Toggle the state to "cancel" the gesture
                sender.isEnabled = false
                sender.isEnabled = true
            }
        } else if state == .changed || state == .ended {
            if let startTapPoint = startTapPoint,
                let floorNode = floorNode {
                let swipe = self.swipe(from: startTapPoint, to: point)
                processSwipe(floorNode: floorNode,
                             swipeDirection: swipe.direction,
                             delta: swipe.delta,
                             finished: state == .ended)
            }
        }

        if state == .ended || state == .cancelled || state == .failed, let floorNode {
            processBuildEnd(floorNode: floorNode)
        }
    }

    private func swipe(from point1: CGPoint, to point2: CGPoint) -> (direction: SwipeDirection, delta: CGFloat) {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        let absDeltaX = deltaX < 0 ? -deltaX : deltaX
        let absDeltaY = deltaY < 0 ? -deltaY : deltaY

        if absDeltaX > absDeltaY {
            // Horizontal change is greater
            if absDeltaX == deltaX {
                return (.right, absDeltaX)
            } else {
                return (.left, absDeltaX)
            }
        } else {
            // Vertical change is greater
            if absDeltaY == deltaY {
                return (.down, absDeltaY)
            } else {
                return (.up, absDeltaY)
            }
        }
    }

    private func floorNode(for hitTestResults: [SCNHitTestResult]) -> FloorNode? {
        if let interactiveNode = hitTestResults.firstInteractiveNode() {
            if let floorNode = interactiveNode as? FloorNode {
                return floorNode
            }
            if let rockNode = interactiveNode as? RockNode {
                return rockNode.floorNode
            }
        }
        return nil
    }

    private func processSwipe(floorNode: FloorNode, swipeDirection: SwipeDirection, delta: CGFloat, finished: Bool) {
        let scale: Float
        if delta < threshold {
            scale = Float(delta / threshold)
        } else {
            scale = 1.0
        }

        let swipeState = SwipeState(scale: scale, finished: finished)

        switch swipeDirection {
        case .down:
            cancelBuild(floorNode: floorNode)
            processAbsorb(floorNode: floorNode, swipeState: swipeState)
        default:
            cancelAbsorb(floorNode: floorNode)
            if let buildableItem = swipeDirection.buildableItem {
                if validBuildSwipeDirections(for: floorNode).contains(swipeDirection) {
                    processBuild(buildableItem, floorNode: floorNode, swipeState: swipeState)
                }
            }
        }
    }

    private func validBuildSwipeDirections(for floorNode: FloorNode) -> [SwipeDirection] {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return SwipeDirection.allCases
            } else {
                return []
            }
        }

        return [.left, .up, .right]
    }

    private func processAbsorb(floorNode: FloorNode, swipeState: SwipeState) {
        switch swipeState {
        case let .building(scale):
            processInProgressAbsorb(floorNode: floorNode, scale: scale)
        case let .finished(removeIt):
            processCompleteAbsorb(floorNode: floorNode, removeIt: removeIt)
        }
    }

    private func processInProgressAbsorb(floorNode: FloorNode, scale: Float) {
        if let topmostNode = floorNode.topmostNode {
            topmostNode.scaleAllDimensions(by: 1.0 - scale)
        }
    }

    private func processCompleteAbsorb(floorNode: FloorNode, removeIt: Bool) {
        if let topmostNode = floorNode.topmostNode {
            if removeIt,
                let point = nodeManipulator.point(for: floorNode),
                playerOperations.absorbTopmostNode(at: point) {
                topmostNode.removeFromParentNode()
            } else {
                topmostNode.scaleAllDimensions(by: 1.0, animated: true)
            }
        }
    }

    private func cancelAbsorb(floorNode: FloorNode) {
        floorNode.topmostNode?.scaleAllDimensions(by: 1.0, animated: true)
    }

    private func processBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, swipeState: SwipeState) {
        switch swipeState {
        case let .building(scale):
            processInProgressBuild(buildableItem, floorNode: floorNode, scale: scale)
        case let .finished(buildIt):
            processCompleteBuild(buildableItem, floorNode: floorNode, buildIt: buildIt)
        }
    }

    private func processBuildStart(floorNode: FloorNode) {
        let height = buildHeight(for: floorNode)
        floorNode.selectionNode = nodeManipulator.nodeFactory.createSelectionNode(height: height)
    }

    private func processInProgressBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, scale: Float) {
        let temporaryNode: TemporaryNode
        if let node = floorNode.temporaryNode {
            temporaryNode = node
        } else {
            let height = buildHeight(for: floorNode)
            temporaryNode = nodeManipulator.nodeFactory.createTemporaryNode(height: height)
            floorNode.temporaryNode = temporaryNode
        }

        if let existingItem = temporaryNode.buildableItem, existingItem == buildableItem {
        } else {
            temporaryNode.contents = createNode(for: buildableItem)
        }

        temporaryNode.scaleAllDimensions(by: scale)
    }

    private func buildHeight(for floorNode: FloorNode) -> Int {
        if let topmostNode = floorNode.topmostNode {
            if topmostNode is RockNode {
                return floorNode.rockNodes.count
            }
        }
        return 0
    }

    private func processCompleteBuild(_ buildableItem: BuildableItem, floorNode: FloorNode, buildIt: Bool) {
        if let point = nodeManipulator.point(for: floorNode),
            let temporaryNode = floorNode.temporaryNode {
            temporaryNode.removeFromParentNode(animated: !buildIt)

            if buildIt {
                switch buildableItem {
                case .rock:
                    if let contents = temporaryNode.contents as? RockNode {
                        let w = contents.rotation.w
                        playerOperations.buildRock(at: point, rotation: w)
                    }
                case .tree:
                    playerOperations.buildTree(at: point)
                case .synthoid:
                    playerOperations.buildSynthoid(at: point)
                }

                opponentsOperations.timeMachine.start()
            }
        }
    }

    private func cancelBuild(floorNode: FloorNode) {
        floorNode.temporaryNode?.removeFromParentNode(animated: true)
    }

    private func processBuildEnd(floorNode: FloorNode) {
        floorNode.selectionNode?.removeFromParentNode()
    }

    private func createNode(for buildableItem: BuildableItem) -> (SCNNode & PlaceableNode) {
        let node: SCNNode & PlaceableNode
        switch buildableItem {
        case .tree:
            node = nodeManipulator.nodeFactory.createTreeNode(height: 0)
        case .rock:
            node = nodeManipulator.nodeFactory.createRockNode(height: 0)
        case .synthoid:
            node = nodeManipulator.nodeFactory.createSynthoidNode(height: 0, viewingAngle: 0.0)
        }
        node.position = SCNVector3Make(0, 0, 0)
        return node
    }

    // MARK: Panning

    @objc
    func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        processPan(by: translation, finished: sender.state == .ended)
    }

    private func processPan(by point: CGPoint, finished: Bool) {
        let deltaX = Float(point.x)
        let deltaY = Float(point.y)
        let deltaXDegrees = deltaX / 10.0
        let deltaXRadians = deltaXDegrees * Float.pi / 180.0
        let deltaYDegrees = deltaY / 10.0
        let deltaYRadians = deltaYDegrees * Float.pi / 180.0
        nodeManipulator.rotateCurrentSynthoid(
            rotationDelta: deltaXRadians,
            elevationDelta: deltaYRadians,
            persist: finished
        )
    }
}

private class TemporaryNode: SCNNode {
    var contents: (SCNNode & PlaceableNode)? {
        didSet {
            oldValue?.removeFromParentNode()
            if let contents {
                addChildNode(contents)
            }
        }
    }

    var buildableItem: BuildableItem? {
        if let contents = contents {
            if contents is TreeNode {
                return .tree
            }
            if contents is RockNode {
                return .rock
            }
            if contents is SynthoidNode {
                return .synthoid
            }
        }
        return nil
    }
}

private class SelectionNode: SCNNode {
    override init() {
        super.init()

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        material.specular.contents = UIColor.white

        let sideLength = CGFloat(floorSize)
        let box = SCNBox(width: CGFloat(sideLength),
                         height: sideLength / 50,
                         length: CGFloat(sideLength),
                         chamferRadius: sideLength)
        box.firstMaterial = material
        geometry = box
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SCNNode {
    func scaleAllDimensions(by scale: Float) {
        let angle = Float.pi * 8.0 * scale
        let position = self.position
        transform = SCNMatrix4MakeRotation(angle, 0, 1, 0)
        self.position = position
        self.scale = SCNVector3Make(scale, scale, scale)
    }

    func scaleAllDimensions(by scale: Float, animated: Bool) {
        if !animated {
            scaleAllDimensions(by: scale)
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3

        scaleAllDimensions(by: scale)

        SCNTransaction.commit()
    }

    func removeFromParentNode(animated: Bool) {
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            SCNTransaction.completionBlock = {
                self.removeFromParentNode()
            }

            scaleAllDimensions(by: 0.0)

            SCNTransaction.commit()
        } else {
            removeFromParentNode()
        }
    }
}

private let temporaryNodeName = "temporaryNodeName"
private let selectionNodeName = "selectionNodeName"

private extension NodeFactory {
    func createTemporaryNode(height: Int) -> TemporaryNode {
        let node = TemporaryNode()
        node.name = temporaryNodeName
        node.position = nodePositioning.calculateObjectPosition(height: height)
        return node
    }

    func createSelectionNode(height: Int) -> SelectionNode {
        let node = SelectionNode()
        node.name = selectionNodeName
        node.position = nodePositioning.calculateSelectionPosition(height: height)
        return node
    }
}

private extension NodePositioning {
    func calculateSelectionPosition(height: Int = 0) -> SCNVector3 {
        let position = calculateObjectPosition(height: height)
        return SCNVector3Make(
            position.x,
            position.y * 1.1,
            position.z
        )
    }
}

private extension FloorNode {
    var temporaryNode: TemporaryNode? {
        get {
            return get(name: temporaryNodeName) as? TemporaryNode
        }
        set {
            set(instance: newValue, name: temporaryNodeName)
        }
    }

    var selectionNode: SelectionNode? {
        get {
            get(name: selectionNodeName) as? SelectionNode
        }
        set {
            set(instance: newValue, name: selectionNodeName)
        }
    }
}
